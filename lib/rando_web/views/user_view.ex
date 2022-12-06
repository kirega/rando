defmodule RandoWeb.UserView do
  use RandoWeb, :view

  def render("users.json", %{users: users}) do
    %{
      users: render_many(users.users, __MODULE__, "user.json"),
      timestamp: users.timestamp
    }
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      points: user.points
    }
  end
end
