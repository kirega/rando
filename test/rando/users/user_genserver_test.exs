defmodule Rando.UserGenServerTest do
  use Rando.DataCase, async: false
  import Rando.Factory

  alias Rando.UserGenServer

  describe "start_link/1" do
    setup do
      {:ok, pid} = UserGenServer.start_link(%UserGenServer{min_number: 0, timestamp: nil})

      on_exit(fn -> Process.exit(pid, :normal) end)
      {:ok, %{pid: pid}}
    end

    test "accepts a measurement count on start", %{pid: pid} do
      assert %UserGenServer{min_number: 0, timestamp: nil} = :sys.get_state(pid)
    end

    test "get_user/0 in the first call returns an empty list and timestamp as nil", %{pid: pid} do
      assert %{
               timestamp: nil,
               users: []
             } = GenServer.call(pid, :get_users)
    end

    test "get_user/0 returns an empty list and timestamp as set when only called twice before 60secs",
         %{pid: pid} do
      %{users: [], timestamp: nil} = UserGenServer.get_users()

      %UserGenServer{timestamp: timer} = :sys.get_state(pid)

      %{users: users, timestamp: timestamp} = UserGenServer.get_users()
      assert users == []
      assert timer == timestamp
    end

    test "get_user/0 returns the previous timestamp", %{pid: pid} do
      # first make sure that we have our own timestamp in the genserver first
      :sys.replace_state(pid, fn _ ->
        %UserGenServer{min_number: 40, timestamp: "my own timestamp"}
      end)

      # set the state of the genserver, it should match was the previous timestamp
      %{users: [], timestamp: prev_stamp} = UserGenServer.get_users()

      # Get users agains, this time the timestamp shall be a new timestamp
      %{users: [], timestamp: latest_stamp} = UserGenServer.get_users()

      assert prev_stamp == "my own timestamp"
      assert prev_stamp != latest_stamp
    end

    test "get_user/0 returns list of user and timestamp as set" do
      users = insert_many(2, :user)

      assert %{
               timestamp: nil,
               users: ^users
             } = UserGenServer.get_users()
    end
  end
end
