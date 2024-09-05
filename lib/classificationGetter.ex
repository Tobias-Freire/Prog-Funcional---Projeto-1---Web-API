defmodule ClassificationGetter do
  @moduledoc """
    Esse módulo foi feito para abrigar a função que retorna a classificação
    do jogador com base nos seus acertos
  """

  @doc """
    A função getClassification recebe o número de questões totais e o número de acertos
    como parâmetro. Retorna a porcentagem de acertos e uma classificação com base na
    porcentagem de acertos.
  """
  def getClassification(nQT, nA) do
    perc = nA/nQT
    result = "#{perc*100}%\n"
    cond do
      perc < 0.4 -> result <> "NOOB (˘︹˘)"
      perc >= 0.4 and perc < 0.8 -> result <> "Dá pro gasto ¯\\_(ツ)_/¯ "
      perc >= 0.8 -> result <> "PRO ( ͡° ͜ʖ ͡°)"
    end
  end
end
