use Mix.Config

config :anka_ecto,
	ecto_repos: [
		Anka.Ecto.Repo,
	]

config :anka_ecto, Anka.Ecto.Repo,
	adapter: Ecto.Adapters.MySQL,
	username: System.get_env("DATABASE_USERNAME") || "root",
	password: System.get_env("DATABASE_PASSWORD") || "",
	database: System.get_env("DATABASE_NAME") || "anka_test",
	hostname: System.get_env("DATABASE_HOST") || "localhost",
	port: System.get_env("DATABASE_PORT") || 32768,
	pool: Ecto.Adapters.SQL.Sandbox

config :pbkdf2_elixir,
	rounds: 4

config :logger, :console, level: :error
