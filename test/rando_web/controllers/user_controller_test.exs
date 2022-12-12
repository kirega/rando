defmodule RandoWeb.UserControllerTest do
  alias Mix.Tasks.Phx.Routes
  use RandoWeb.ConnCase
  alias Rando.UserGenServer
  import Rando.Factory

  describe "get users" do
    setup do
      {:ok, pid} = UserGenServer.start_link({0, nil})
      on_exit(fn -> Process.exit(pid, :normal) end)
      {:ok, pid: pid}
    end

    test "index, renders correctly when we do not have data", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      result = json_response(conn, 200)
      assert %{"timestamp" => nil, "users" => []} = result
    end

    test "index, fetches the correct user data, points are also greater than the minimum", %{
      conn: conn,
      pid: pid
    } do
      insert_many(10, :user, points: 25)
      {min_number, _timestamp} = :sys.get_state(pid)

      conn = get(conn, Routes.user_path(conn, :index))
      result = json_response(conn, 200)

      assert %{
               "timestamp" => nil,
               "users" => [
                 %{"id" => _, "points" => point1},
                 %{"id" => _, "points" => point2}
               ]
             } = result

      assert point1 >= min_number
      assert point2 >= min_number
    end
  end
end
