defmodule Rando.UsersTest do
  use ExUnit.Case, async: false
  alias Rando.Users
  alias Rando.Repo
  import Rando.Factory

  describe "Users" do
    test "update_all_data_points" do
      Ecto.Adapters.SQL.Sandbox.checkout(Repo, sandbox: true)
      Ecto.Adapters.SQL.Sandbox.mode(Rando.Repo, :auto)

      timestamp = Users.timestamp()

      insert_many(10, :user, %{inserted_at: timestamp, updated_at: timestamp})

      # Ensure that all user points were updated without error
      {:ok, [ok: {10, nil}]} = Users.update_all_user_points()
      updated_users = Repo.all(Rando.User)

      for user <- updated_users do
        assert user.inserted_at != timestamp
      end

      on_exit(fn ->
        Repo.delete_all(Rando.User)
      end)
    end
  end
end
