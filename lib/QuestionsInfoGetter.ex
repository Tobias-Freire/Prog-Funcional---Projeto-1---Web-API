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

  def getQuestions() do
    IO.puts("Digite a quantidade de questões que você quer:")
    q = IO.gets("") |> String.trim() # Remove a nova linha do final
    urlOpt = @url <> q

    with {:ok, json} <- HTTPoison.get(urlOpt) |> process_response do
      questoes = filtra_questoes({:ok, json})
      opcoes = filtra_opcoes({:ok, json})
      respostas = filtra_respostas({:ok, json})
      [{:questoes, questoes}, {:opcoes, opcoes}, {:respostas, respostas}]
    else
      {:error, _reason} ->
        IO.puts("Erro ao obter questões.")
        {:error, "Não foi possível obter as questões."}
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
      [opcao_correta | opcoes_incorretas]
    end
    opcoes
  end
end
