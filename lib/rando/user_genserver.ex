defmodule Rando.UserGenServer do
  use GenServer
  require Logger
  alias Rando.UserGenServer
  alias Rando.Users

  defstruct min_number: :rand.uniform(Application.compile_env(:rando, :max_range)), timestamp: nil
  @type t :: %__MODULE__{min_number: integer(), timestamp: nil | String.t()}

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
  def handle_call(:get_users, _from, %UserGenServer{min_number: min_number} = state) do
    timestamp = Users.timestamp()

    {:reply,
     %{
       users: Users.get_two_highest_users(min_number),
       timestamp: state.timestamp
     }, %{state | timestamp: timestamp}}
  end

  @impl true
  def handle_cast(:update_users, state) do
    %Task{} =
      Task.Supervisor.async(Rando.TaskSupervisor, fn ->
        case Users.update_all_user_points() do
          {:ok, _} -> :completed_user_update
          {:error, _} -> :failed_user_update
        end
      end)

    {:noreply, state}
  end

  @impl true
  def handle_info(:cron, %UserGenServer{} = state) do
    GenServer.cast(__MODULE__, :update_users)
    {:noreply, %{state | min_number: random_points()}}
  end

  @impl true
  def handle_info({ref, :completed_user_update}, state) do
    Logger.info("#{__MODULE__}: Updated all users with new random points")
    Process.demonitor(ref, [:flush])
    {:noreply, state}
  end

  @impl true
  def handle_info({ref, :failed_user_update}, state) do
    Logger.error("#{__MODULE__}: Failed to update all users with random points")
    Process.demonitor(ref, [:flush])
    {:noreply, state}
  end

  defp schedule do
    Process.send_after(self(), :cron, :timer.seconds(60))
  end

  defp random_points() do
    range = Application.get_env(:rando, :max_range)
    :rand.uniform(range)
  end
end
