defmodule Countdown do
  def countdown(n) when n >= 0 do
    Enum.each(n..0, fn i ->
      # Constrói a string com espaços para limpar a linha
      IO.write("\r#{i}    ")
      :timer.sleep(1000)  # Atraso de 1 segundo
    end)

    IO.write("\rDone!    \n")  # Imprime "Done!" e limpa a linha
  end
end
