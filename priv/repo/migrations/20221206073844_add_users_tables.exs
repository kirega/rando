defmodule Rando.Repo.Migrations.AddUsersTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :points, :integer, default: 0
      timestamps()
    end
  end
end
