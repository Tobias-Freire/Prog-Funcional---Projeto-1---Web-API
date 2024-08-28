defmodule Projeto1 do
  @moduledoc """
  Projeto de requisições à API para buscar informações
  """

  @url "https://opentdb.com/api.php?amount=10"

  def getQuestions() do
    HTTPoison.get(@url)
    |> process_response
  end
  
  defp process_response({:ok, %HTTPoison.Response{status_code: 200, body: b}}) do
    {:ok, b}
  end
  defp process_response({:error, r}), do: {:erro, r}
  defp process_response({:ok, %HTTPoison.Response{status_code: _, body: b}}), do: {:error, b}


end
