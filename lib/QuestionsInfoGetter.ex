defmodule QuestionsInfoGetter do
  @moduledoc """
    Este módulo foi feito para recuperar as informações pela API Open Trivia DB.
    Informações recuperadas:
      - Perguntas
      - Opções
      - Respostas
    O número de questões, categoria, dificuldade e tipo de questão
    são parâmetros definidos pelo usuário na execução da aplicação.
  """

  import ClassificationGetter

  # Url base
  @url "https://opentdb.com/api.php?amount="

  # Definindo um mapa das categorias.
  @categoria %{
    "conhecimentos gerais" => 9,
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


  @doc """
    A função getQuestions é aquela que inicia toda a lógica da aplicação.
    Ao ser executada, segue o seguinte fluxo:
      1 - Pergunta se as questões devem ser aleatórias ou não
        1.1 - Caso não, pergunta que categoria o usuário quer, a quantidade de questões, a dificuldade e o tipo de questão
        1.2 - Caso sim, pergunta diretamente a quantidade de questões
      2 - Url é montada com os parâmetros passados pelo usuário
      3 - Requisição é feita à API do trivia
      4 - Resposta é tratada para ficar em formato JSON
      5 - São recolhidas as informações das questões como a pergunta, opções, resposta correta, etc
      6 - Cada pergunta é mostrada ao usuário e é requisitada uma resposta
      7 - Ao final das respostas é mostrado o percentual de acertos e uma classificação com base nesse percentual
  """
  def getQuestions() do
    IO.puts("\nVocê deseja que as questões sejam aleatórias? [s/n]: ")
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
      IO.puts("\nQuestão: \e[33m#{questao}\e[0m") # Mostra a questão ao usuário

      Enum.each(Enum.with_index(opcoes_questao), fn {opcao, index} ->
        IO.puts("#{index + 1}. #{opcao}")
      end)

      resposta_usuario = IO.gets("Digite o número da sua resposta: ") |> String.trim()
      resposta_usuario_index = String.to_integer(resposta_usuario) - 1

      novo_acumulador =
        if Enum.at(opcoes_questao, resposta_usuario_index) == resposta_certa do
          IO.puts("\e[32mCorreto!\e[0m")
          acumulador + 1
        else
          IO.puts("\e[31mIncorreto!\e[0m A resposta correta é: \e[32m#{resposta_certa}\e[0m")
          acumulador
        end

      IO.puts("") # Espaço em branco para melhor visualização
      {novo_acumulador, questoes_restantes}
    end)

    classification_result = getClassification(total_questoes, acertos)
    IO.puts("\n#{classification_result}")
  end


  # A função process_response recebe a resposta completa da requisição da API e
  # retorna apenas o body
  defp process_response({:ok, %HTTPoison.Response{status_code: 200, body: b}}) do
    {:ok, b}
  end
  defp process_response({:error, r}), do: {:error, r}
  defp process_response({:ok, %HTTPoison.Response{status_code: _, body: b}}), do: {:error, b}

  # A função filtra_questes recebe o body da resposta e retorna as questões
  defp filtra_questoes({:ok, json}) do
    case Poison.decode(json) do
      {:ok, %{"results" => results}} ->
        Enum.map(results, fn result ->
          case result do
            %{"question" => question} -> question
            _ -> nil
          end
        end)
      _ -> nil
    end
  end

  # A função filtra_respostas recebe o body da resposta e retorna as respostas corretas de cada questão
  defp filtra_respostas({:ok, json}) do
    case Poison.decode(json) do
      {:ok, %{"results" => results}} ->
        Enum.map(results, fn result ->
          case result do
            %{"correct_answer" => correct_answer} -> correct_answer
            _ -> nil
          end
        end)
      _ -> nil
    end
  end

  # A função filtra_opções recebe o body da resposta e retona as opções da resposta (resposta correta + respostas incorretas)
  defp filtra_opcoes({:ok, json}) do
    case Poison.decode(json) do
      {:ok, %{"results" => results}} ->
        Enum.map(results, fn result ->
          case result do
            %{"incorrect_answers" => incorrect_answers, "correct_answer" => correct_answer} ->
              [correct_answer | incorrect_answers] |> Enum.shuffle()
            _ -> nil
          end
        end)
      _ -> nil
    end
  end

  defp conserta_caracteres(lista) do
    Enum.map(lista, fn x ->
      x
      |> String.replace("&#039;", "'")
      |> String.replace("&quot;", "\"")
      |> String.replace("&rsquo;", "’")
      |> String.replace("&amp;", "&")
      |> String.replace("&aacute;", "á")
      |> String.replace("&eacute;", "é")
      |> String.replace("&iacute;", "í")
      |> String.replace("&oacute;", "ó")
      |> String.replace("&uacute;", "ú")
      |> String.replace("&ntilde;", "ñ")
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
        |> String.replace("&rsquo;", "’")
        |> String.replace("&amp;", "&")
        |> String.replace("&aacute;", "á")
        |> String.replace("&eacute;", "é")
        |> String.replace("&iacute;", "í")
        |> String.replace("&oacute;", "ó")
        |> String.replace("&uacute;", "ú")
        |> String.replace("&ntilde;", "ñ")
      end)
      List.replace_at(acumulador, contador, nova_sub_lista)
    end)
  end
end
