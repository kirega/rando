defmodule RandoWeb.UserGenServerHandlerTest do
  use Rando.DataCase, async: false
  import Rando.Factory

  alias Rando.Repo
  alias Rando.UserGenServer
  alias Rando.User

  describe "Asynchronous Tests " do
    setup do
      {:ok, pid} = UserGenServer.start_link({0, nil})

      on_exit(fn ->
        Process.exit(pid, :normal)
        Repo.delete_all(Rando.User)
      end)

      {:ok, %{pid: pid}}
    end

    test ":update_users handle_cast updates all the users in the db", %{pid: pid} do
      timestamp =
        DateTime.now!("Etc/UTC")
        |> DateTime.add(-15, :second)
        |> DateTime.truncate(:second)
        |> DateTime.to_naive()

      insert_many(5, :user, updated_at: timestamp)

      Ecto.Adapters.SQL.Sandbox.checkout(Repo, sandbox: true)
      Ecto.Adapters.SQL.Sandbox.mode(Repo, :auto)

      assert :ok = GenServer.cast(pid, :update_users)
      # a hack to ensure cast completes

      assert {_min, _timer} = :sys.get_state(pid)

      Repo.all(User)
      |> Enum.each(fn user ->
        assert %User{updated_at: updated_at} = Repo.get!(User, user.id)
        assert updated_at != timestamp
      end)

      on_exit(fn ->
        Repo.delete_all(Rando.User)
      end)
    end
  end
end
