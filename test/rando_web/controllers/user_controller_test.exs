defmodule RandoWeb.UserControllerTest do
  alias Mix.Tasks.Phx.Routes
  use RandoWeb.ConnCase
  alias Rando.UserGenServer
  import Rando.Factory

  describe "get users" do
    setup do
      {:ok, pid} = UserGenServer.start_link({0, nil})
      on_exit(fn -> Process.exit(pid, :normal) end)
      :ok
    end

    test "index, renders correctly when we do not have data", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      result = json_response(conn, 200)
      assert %{"timestamp" => nil, "users" => []} = result
    end

    test "index, fetches the correct user data ", %{conn: conn} do
      insert_many(10, :user, points: 25)
      user1 = insert!(:user, points: 100)
      user2 = insert!(:user, points: 54)

      conn = get(conn, Routes.user_path(conn, :index))
      result = json_response(conn, 200)

      assert %{
               "timestamp" => nil,
               "users" => [
                 %{"id" => user1.id, "points" => user1.points},
                 %{"id" => user2.id, "points" => user2.points}
               ]
             } == result
    end
  end
end
