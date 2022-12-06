defmodule Rando.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :points, :integer, default: 0
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:points])
    |> validate_number(:points, greater_than: 0, less_than: 100)
  end
end
