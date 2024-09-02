defmodule ClassificationGetter do
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
