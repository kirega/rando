defmodule Rando.UserGenServer do
  use GenServer
  require Logger
  alias Rando.Users

  # TODO make the state a struct
  # defstruct [:min_number, :timestamp]

  def start_link(default) do
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

  @impl true
  def handle_call(:get_users, _from, {min_number, timestamp}) do
    case Users.get_two_highest_users(min_number) do
      {:ok, user} ->
        {:reply,
         %{
           users: user,
           timestamp: timestamp
         }, {min_number, NaiveDateTime.utc_now()}}

      _ ->
        {:reply, %{}, {min_number, NaiveDateTime.utc_now()}}
    end
  end

  @impl true
  def handle_cast(:update_users, state) do
    %Task{} = Task.Supervisor.async(Rando.TaskSupervisor, fn ->
      case Users.update_all_user_points() do
        {:ok, _} -> :completed_user_update
        {:error, _} -> :failed_user_update
      end
    end)

    {:noreply, state}
  end

  @impl true
  def handle_info(:cron, {_min_number, timestamp}) do
    GenServer.cast(__MODULE__, :update_users)
    {:noreply, {:rand.uniform(100), timestamp}}
  end

  @impl true
  # The task completed successfully
  def handle_info({ref, :completed_user_update}, state) do
    Logger.info("Task: Update all users point completeds")
    Process.demonitor(ref, [:flush])
    {:noreply, state}
  end

  @impl true
  # The task completed successfully
  def handle_info({ref, :failed_user_update}, state) do
    Logger.info("Task: Failed to update users' points")
    Process.demonitor(ref, [:flush])
    {:noreply, state}
  end

  defp schedule do
    Process.send_after(self(), :cron, :timer.seconds(60))
  end
end
