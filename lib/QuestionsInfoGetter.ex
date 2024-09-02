defmodule QuestionsInfoGetter do
  @moduledoc """
    Este módulo foi feito para recuperar as informações pela API Open Trivia DB.
    Informações recuperadas:
      - Perguntas
      - Opções
      - Respostas
    O número de questões requisitadas é definida pelo usuário na execução da aplicação.
  """

  @url "https://opentdb.com/api.php?amount="


  #definindo um mapa das categorias.
  @categoria %{
    "conhecimento gerais" => 9,
    "livros" => 10,
    "filmes" => 11,
    "música" => 12,
    "musicais e teatros" => 13,
    "televisão" => 14,
    "jogos digitais" => 15,
    "jogos de mesa" => 16,
    "ciência" => 17,
    "computadores" => 18,
    "matemática" => 19,
    "mitologia" => 20,
    "esportes" => 21,
    "geografia" => 22,
    "história" => 23,
    "política" => 24,
    "arte" => 25,
    "celebridades" => 26,
    "animais" => 27,
    "veículos" => 28,
    "quadrinhos" => 29,
    "gadgets" => 30,
    "anime e mangá" => 31,
    "desenhos" => 32
  }

  @dificulade %{
    "fácil" => "easy",
    "médio" => "medium",
    "difícil" => "hard"
  }

  @tipo %{
    "múltipla" => "multiple",
    "vouf" => "boolean"
  }

  #retorna o valor da chave passada.
  def consultar_categoria(categ) do
    categoria = Map.get(@categoria, categ)
    Integer.to_string(categoria)#transforma em string, ja que o valor eh um numero
  end

  def consultar_dificuldade(difi) do
    Map.get(@dificulade, difi)
  end

  def consultar_tipo(tip) do
    Map.get(@tipo, tip)
  end

  def getQuestions() do

    IO.puts("Você deseja que as questões sejam aleátorias? Se sim, digite s, se não, digite n: ")
    resposta = IO.gets("") |> String.trim() # Remove a nova linha do final

    #trata a resposta dada pelo usuario.
    if resposta == "s" do
      IO.puts("Digite a quantidade de questões que você deseja, sendo o limite de 50: ")
      q = IO.gets("") |> String.trim()
      urlAleat = @url <> q

      with {:ok, json} <- HTTPoison.get(urlAleat) |> process_response do
        questoes = filtra_questoes({:ok, json})
        opcoes = filtra_opcoes({:ok, json})
        respostas = filtra_respostas({:ok, json})
        mostrar_questoes(questoes, opcoes, respostas)
      else
        {:error, _reason} ->
          IO.puts("Erro ao obter questões.")
          {:error, "Não foi possível obter as questões."}
      end
    else
      IO.puts("Digite a quantidade de questões que voce quer, sendo o limite de 50: ")
      q = IO.gets("") |> String.trim()

      IO.puts("Digite a categoria que você deseja, são elas: ")
      Enum.each(@categoria, fn {numero, _cate} -> IO.puts "#{numero}" end)
      categ = IO.gets("") |> String.trim()
      c = consultar_categoria(categ)

      IO.puts("Digite a dificuldade, são elas: ")
      Enum.each(@dificulade, fn {original, _digitada} -> IO.puts "#{original}" end)
      difi = IO.gets("") |> String.trim()
      d = consultar_dificuldade(difi)

      IO.puts("Digite o tipo, são eles: ")
      Enum.each(@tipo, fn {original, _digitada} -> IO.puts "#{original}" end)
      tip = IO.gets("") |> String.trim()
      t = consultar_tipo(tip)

       #s = string
      sCategoria = "&category="
      sDificuldade = "&dificulty="
      sTipo = "&type="

      urlCompleta = @url <> q <> sCategoria <> c <> sDificuldade <> d <> sTipo <> t
      with {:ok, json} <- HTTPoison.get(urlCompleta) |> process_response do
        questoes = filtra_questoes({:ok, json})
        opcoes = filtra_opcoes({:ok, json})
        respostas = filtra_respostas({:ok, json})
        mostrar_questoes(questoes, opcoes, respostas)
      else
        {:error, _reason} ->
          IO.puts("Erro ao obter questões.")
          {:error, "Não foi possível obter as questões."}
      end
    end
  end

  #funcao para mostrar uma questao do trivia por vez
  defp mostrar_questoes(questoes, opcoes, respostas) do
    #usei o Enum.zip para combinar a lista de opcoes e repostas em uma lista de tuplas
    #depois combinei essa lista de tuplas com a lista questoes usando Enum.zip novamente
    #enum.each serve para iterar sobre cada tupla, para exibir uma questao por vez
    #depois uso enum.each novamente com enum.with_index para que cada opcao de resposta tenha um indice
    #as opcoes sao exibidas com seu indice respectivo
    Enum.each Enum.zip(questoes, Enum.zip(opcoes, respostas)), fn {questao, {opcoes_questao, resposta_certa}} ->
      IO.puts("Questão: #{questao}")#mostra a questao ao usuario

      Enum.each(Enum.with_index(opcoes_questao), fn {opcao, index} ->
        IO.puts("#{index + 1}. #{opcao}")
      end)

      #recebe a resposta do usuario, que necessariamente vai ser um numero
      #esse numero vai servir para representar a escolha do usuario
      resposta_usuario = IO.gets("Digite o número da sua resposta: ") |> String.trim()
      resposta_usuario_index = String.to_integer(resposta_usuario) - 1

      #verifica se a resposta dada pelo usuario combina com o indice da resposta certa
      if Enum.at(opcoes_questao, resposta_usuario_index) == resposta_certa do
        IO.puts("Correto!")
      else
        IO.puts("Incorreto! A resposta correta é: #{resposta_certa}")
      end

      IO.puts("") # Espaço em branco para melhor visualização
    end
  end

  defp process_response({:ok, %HTTPoison.Response{status_code: 200, body: b}}) do
    {:ok, b}
  end
  defp process_response({:error, r}), do: {:error, r}
  defp process_response({:ok, %HTTPoison.Response{status_code: _, body: b}}), do: {:error, b}

  defp filtra_questoes({:error, _}), do: IO.puts("Erro ao filtrar questões.")
  defp filtra_questoes({:ok, json}) do
    {:ok, resp} = Poison.decode(json)
    respMaps = resp["results"]
    questoes = for map <- respMaps, do: map["question"]
    questoes
  end

  defp filtra_respostas({:error, _}), do: IO.puts("Erro ao filtrar respostas.")
  defp filtra_respostas({:ok, json}) do
    {:ok, resp} = Poison.decode(json)
    respMaps = resp["results"]
    respostas = for map <- respMaps, do: map["correct_answer"]
    respostas
  end

  defp filtra_opcoes({:error, _}), do: IO.puts("Erro ao filtrar opcoes.")
  defp filtra_opcoes({:ok, json}) do
    {:ok, resp} = Poison.decode(json)
    respMaps = resp["results"]
    opcoes = for map <- respMaps do
      opcao_correta = map["correct_answer"]
      opcoes_incorretas = map["incorrect_answers"]
      [opcao_correta | opcoes_incorretas] |> Enum.shuffle() # Embaralha as opções
    end
    opcoes
  end
end
