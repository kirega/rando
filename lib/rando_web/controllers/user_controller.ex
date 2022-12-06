defmodule RandoWeb.UserController do
  use RandoWeb, :controller
  alias Rando.UserGenServer

  def index(conn, _params) do
    users = UserGenServer.get_users()
    render(conn, "users.json", users: users)
  end
end
