defmodule ExSanity do
  def config do
    %{
      file_base: Application.get_env(:ex_sanity, :file_base),
      project_id: Application.get_env(:ex_sanity, :project_id, "xxxx"),
      dataset: Application.get_env(:ex_sanity, :project_id, "production"),
      api_key: Application.get_env(:ex_sanity, :api_key, "xxxx"),
      version: Application.get_env(:ex_sanity, :version, "v2021-06-07"),
      endpoint: Application.get_env(:ex_sanity, :endpoint, "api")
    }
  end
end
