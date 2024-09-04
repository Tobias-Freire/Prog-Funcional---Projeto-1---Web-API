defmodule QuestionsInfoGetter do
  @moduledoc """
    Este módulo foi feito para recuperar as informações pela API Open Trivia DB.
    Informações recuperadas:
      - Perguntas
      - Opções
      - Respostas
    O número de questões requisitadas é definida pelo usuário na execução da aplicação.
  """

  import ClassificationGetter

  @url "https://opentdb.com/api.php?amount="

  # Definindo um mapa das categorias.
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

  @dificuldade %{
    "fácil" => "easy",
    "médio" => "medium",
    "difícil" => "hard"
  }

  @tipo %{
    "múltipla" => "multiple",
    "vouf" => "boolean"
  }

  # Retorna o valor da chave passada.
  def consultar_categoria(categ) do
    categoria = Map.get(@categoria, categ)
    Integer.to_string(categoria) # Transforma em string, já que o valor é um número
  end

  def consultar_dificuldade(difi) do
    Map.get(@dificuldade, difi)
  end

  def consultar_tipo(tip) do
    Map.get(@tipo, tip)
  end

  def getQuestions() do
    IO.puts("Você deseja que as questões sejam aleatórias? [s/n]: ")
    resposta = IO.gets("") |> String.trim() # Remove a nova linha do final

    # Tratamento da resposta dada pelo usuário.
    if resposta == "s" do
      IO.puts("\nDigite a quantidade de questões que você deseja, sendo o limite de 50: ")
      q = IO.gets("") |> String.trim()
      urlAleat = @url <> q

      with {:ok, json} <- HTTPoison.get(urlAleat) |> process_response do
        questoes = filtra_questoes({:ok, json})
        questoes = conserta_caracteres(questoes)
        opcoes = filtra_opcoes({:ok, json})
        opcoes = conserta_caracteres_opcoes(opcoes)
        respostas = filtra_respostas({:ok, json})
        respostas = conserta_caracteres(respostas)
        mostrar_questoes(questoes, opcoes, respostas)
      else
        {:error, _reason} ->
          IO.puts("Erro ao obter questões.")
          {:error, "Não foi possível obter as questões."}
      end
    else
      IO.puts("\nDigite a quantidade de questões que você quer, sendo o limite de 50: ")
      q = IO.gets("") |> String.trim()

      IO.puts("\nDigite a categoria que você deseja, são elas: ")
      Enum.each(@categoria, fn {numero, _cate} -> IO.puts "-#{numero}" end)
      categ = IO.gets("") |> String.trim()
      c = consultar_categoria(categ)

      IO.puts("\nDigite a dificuldade, são elas: ")
      Enum.each(@dificuldade, fn {original, _digitada} -> IO.puts "#{original}" end)
      difi = IO.gets("") |> String.trim()
      d = consultar_dificuldade(difi)

      IO.puts("\nDigite o tipo, são eles: ")
      Enum.each(@tipo, fn {original, _digitada} -> IO.puts "#{original}" end)
      tip = IO.gets("") |> String.trim()
      t = consultar_tipo(tip)

      # s = string
      sCategoria = "&category="
      sDificuldade = "&difficulty="
      sTipo = "&type="

      urlCompleta = @url <> q <> sCategoria <> c <> sDificuldade <> d <> sTipo <> t
      with {:ok, json} <- HTTPoison.get(urlCompleta) |> process_response do
        questoes = filtra_questoes({:ok, json})
        questoes = conserta_caracteres(questoes)
        opcoes = filtra_opcoes({:ok, json})
        opcoes = conserta_caracteres_opcoes(opcoes)
        respostas = filtra_respostas({:ok, json})
        respostas = conserta_caracteres(respostas)
        mostrar_questoes(questoes, opcoes, respostas)
      else
        {:error, _reason} ->
          IO.puts("Erro ao obter questões.")
          {:error, "Não foi possível obter as questões."}
      end
    end
  end

  # Função para mostrar uma questão do trivia por vez
  defp mostrar_questoes(questoes, opcoes, respostas) do
    total_questoes = length(questoes)

    # Função auxiliar para processar as questões e contar os acertos
    {acertos, _} = Enum.reduce(Enum.zip(questoes, Enum.zip(opcoes, respostas)), {0, []}, fn {questao, {opcoes_questao, resposta_certa}}, {acumulador, questoes_restantes} ->
      IO.puts("\nQuestão: #{questao}") # Mostra a questão ao usuário

      Enum.each(Enum.with_index(opcoes_questao), fn {opcao, index} ->
        IO.puts("#{index + 1}. #{opcao}")
      end)

      resposta_usuario = IO.gets("Digite o número da sua resposta: ") |> String.trim()
      resposta_usuario_index = String.to_integer(resposta_usuario) - 1

      novo_acumulador =
        if Enum.at(opcoes_questao, resposta_usuario_index) == resposta_certa do
          IO.puts("Correto!")
          acumulador + 1
        else
          IO.puts("Incorreto! A resposta correta é: #{resposta_certa}")
          acumulador
        end

      IO.puts("") # Espaço em branco para melhor visualização
      {novo_acumulador, questoes_restantes}
    end)

    classification_result = getClassification(total_questoes, acertos)
    IO.puts("\n#{classification_result}")
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

  defp filtra_opcoes({:error, _}), do: IO.puts("Erro ao filtrar opções.")
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

  defp conserta_caracteres(lista) do
    Enum.map(lista, fn x ->
      x
      |> String.replace("&#039;", "'")
      |> String.replace("&quot;", "\"")
      |> String.replace("&amp;", "&")
    end)
  end

  defp conserta_caracteres_opcoes(mega_lista) do
    mega_lista
    |> Enum.with_index()
    |> Enum.reduce(mega_lista, fn {sub_lista, contador}, acumulador ->
      nova_sub_lista = Enum.map(sub_lista, fn y ->
        y
        |> String.replace("&#039;", "'")
        |> String.replace("&quot;", "\"")
        |> String.replace("&amp;", "&")
      end)
      List.replace_at(acumulador, contador, nova_sub_lista)
    end)
  end
end