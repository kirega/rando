defmodule Rando.User do
  use Ecto.Schema

  schema "users" do
    field :points, :integer, default: 0
    timestamps()
  end
end
