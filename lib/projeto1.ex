defmodule Projeto1 do
  @moduledoc """
  Projeto de requisições à API para buscar informações
  """
  import QuestionsInfoGetter # Importação do módulo que requisita as questões e informações à API

  def start() do
    getQuestions()
  end
end
