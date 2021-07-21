use Mix.Config

config :ex_sanity,
  file_base: "https://cdn.sanity.io",
  project_id: "xxx",
  dataset: "xxx",
  api_key: "xxx",
  version: "xxx",
  endpoint: "xxx"

import_config "#{Mix.env}.exs"
