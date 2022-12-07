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
    # Task.Supervisor.async_nolink(Rando.TaskSupervisor, fn -> Users.update_all_user_points() end)
    {:ok, state}
  end

  @impl true
  def handle_call(:get_users, _from, {min_number, timestamp}) do
    users = Users.get_two_highest_user(min_number)
    {:reply, %{users: users, timestamp: timestamp}, {min_number, NaiveDateTime.utc_now()}}
  end

  @impl true
  def handle_info(:cron, {_min_number, timestamp}) do
    Logger.error("Last updated at timestamp #{inspect(timestamp)}")
    schedule()

    Task.Supervisor.async_nolink(Rando.TaskSupervisor, fn ->
      case Users.update_all_user_points() do
        :ok -> :completed_user_update
      end
    end)

    Logger.error("Niko hapa #{inspect(timestamp)}")

    {:noreply, {:rand.uniform(100), timestamp}}
  end

  @impl true
  # The task completed successfully
  def handle_info({ref, answer}, state) do
    Logger.error("Answer from users update #{inspect(answer)}")
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(ref, [:flush])
    # Do something with the result and then return
    {:noreply, state}
  end

  defp schedule do
    Process.send_after(self(), :cron, :timer.seconds(60))
  end
end
