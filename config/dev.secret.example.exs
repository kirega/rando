import Config

# Configure your database
config :rando, Rando.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "rando_dev",
  stacktrace: false,
  show_sensitive_data_on_connection_error: false,
  pool_size: 10

config :logger, level: :warn
