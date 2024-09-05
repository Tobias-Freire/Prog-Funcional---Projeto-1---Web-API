defmodule Projeto1 do
  @moduledoc """
  Projeto de requisições à API para buscar informações

  API usada: Open Trivia Database
  Link: https://opentdb.com/api_config.php

  PARTICIPANTES: TOBIAS FREIRE, GUILHERME ARANHA, EMANUEL LLARENA
  """
  import QuestionsInfoGetter # Importação do módulo que requisita as questões e informações à API

  def start() do
    getQuestions()
  end
end
