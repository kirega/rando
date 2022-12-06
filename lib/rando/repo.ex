defmodule Rando.Repo do
  use Ecto.Repo,
    otp_app: :rando,
    adapter: Ecto.Adapters.Postgres
end
