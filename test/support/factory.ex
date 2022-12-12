defmodule Rando.Factory do
  alias Rando.User
  alias Rando.Repo

  def build(:user) do
    %User{
      points: 0
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end

  def insert_many(count, factory_name, attributes \\ []) do
    Enum.to_list(1..count)
    |> Enum.map(fn _ ->
      factory_name |> build(attributes)
    end)
    |> Enum.map(fn obj ->
      Repo.insert!(obj)
    end)
  end
end
