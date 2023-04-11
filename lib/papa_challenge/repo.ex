defmodule PapaChallenge.Repo do
  use Ecto.Repo,
    otp_app: :papa_challenge,
    adapter: Ecto.Adapters.Postgres
end
