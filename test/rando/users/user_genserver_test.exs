defmodule Rando.UserGenServerTest do
  use Rando.DataCase, async: false
  import Rando.Factory

  alias Rando.UserGenServer

  describe "start_link/1" do
    setup do
      {:ok, pid} = UserGenServer.start_link({0, nil})

      on_exit(fn -> Process.exit(pid, :normal) end)
      {:ok, %{pid: pid}}
    end

    test "accepts a measurement count on start", %{pid: pid} do
      assert {0, nil} = :sys.get_state(pid)
    end

    test "get_user/0 in the first call returns an empty list and timestamp as nil", %{pid: pid} do
      assert %{
               timestamp: nil,
               users: []
             } = GenServer.call(pid, :get_users)
    end

    test "get_user/0 in the returns an empty list and timestamp as set when only called twice before 60secs",
         %{pid: pid} do
      %{users: [], timestamp: nil} = UserGenServer.get_users()

      {_min, timer} = :sys.get_state(pid)

      %{users: users, timestamp: timestamp} = UserGenServer.get_users()
      assert users == []
      assert %NaiveDateTime{} = timestamp
      assert timer == timestamp
    end

    test "get_user/0 returns list of user and timestamp as set" do
      users = insert_many(2, :user)

      assert %{
               timestamp: nil,
               users: ^users
             } = UserGenServer.get_users()
    end

    test "get_user/0 returns the previous timestamp" do
    end
  end
end
