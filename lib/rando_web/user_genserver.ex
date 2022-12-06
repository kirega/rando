defmodule Rando.UserGenServer do
  use GenServer
  require Logger
  alias Rando.Users

  def start_link(default) do
    Logger.error("Started with state #{inspect(default)}")
    GenServer.start_link(__MODULE__, default, name: Rando.UserGenServer)
  end

  def get_users() do
    GenServer.call(__MODULE__, :get_users)
  end

  @impl true
  def init(state) do
    schedule()
    {:ok, state}
  end

  def handle_call(:get_users, _from, {min_number, timestamp}) do
    users = Users.get_two_highest_user(min_number)
    {:reply, %{users: users, timestamp: timestamp}, {min_number, NaiveDateTime.utc_now()}}
  end

  @impl true
  def handle_info(:cron, {min_number, timestamp}) do
    Logger.error("Last updated at timestamp #{inspect(timestamp)}")
    schedule()
    :ok = Users.update_all_user_points()

    {:noreply, {:rand.uniform(100), timestamp}}
  end

  defp schedule do
    Process.send_after(self(), :cron, :timer.seconds(60))
  end
end
