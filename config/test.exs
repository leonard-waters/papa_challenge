import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :papa_challenge, PapaChallenge.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "papa_challenge_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :papa_challenge, PapaChallengeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "yY2POh/n3zXEDv7Kkp5w6yIy0HpUBeNIa72zQYwegvc7kWsq0F3Ty+tkg51pwhNo",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
