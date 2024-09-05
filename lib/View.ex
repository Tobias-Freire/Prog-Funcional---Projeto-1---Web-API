defmodule View do
  def viewJSON() do
    {:ok, resposta} = HTTPoison.get("https://opentdb.com/api.php?amount=1")
    json = Poison.decode(resposta.body)
    json
  end
end
