defmodule Rando.Users do
  @moduledoc """
  Rando.Users modules is the context manager for the Rando.User module.
  """

  import Ecto.Query
  alias Rando.User
  alias Rando.Repo
  require Logger

  @chunk 5_000

  @doc """
  update_all()
  It fetches and updates all the users in the database.
  """
  def update_all_user_points() do
    Logger.debug("Started updating the users table")
    start_time = NaiveDateTime.utc_now()
    placeholders = %{timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)}
    stream = Repo.stream(from(u in User))

    Repo.transaction(fn ->
      stream
      |> Stream.map(&build_user(&1))
      |> Stream.chunk_every(@chunk)
      |> Task.async_stream(&insert_user_chunk(&1, placeholders),
        max_concurrency: 10,
        ordered: false
      )
      |> Enum.to_list()
    end)

    end_time = NaiveDateTime.utc_now()
    diff = Time.diff(end_time, start_time, :microsecond)

    Logger.debug(
      "Completed updating the users table in #{diff} microseconds #{diff / 1_000_000} seconds"
    )

    # runs in ~4s
  end

  defp build_user(user) do
    %{
      id: user.id,
      points: :rand.uniform(100),
      inserted_at: {:placeholder, :timestamp},
      updated_at: {:placeholder, :timestamp}
    }
  end

  defp insert_user_chunk(user_chunk, placeholders) do
    Repo.insert_all(
      User,
      user_chunk,
      placeholders: placeholders,
      on_conflict: :replace_all,
      conflict_target: [:id]
    )
  end

  def get_two_highest_users(min_number) do
    stream = from(u in User,
      where: u.points >= ^min_number,
      limit: 2,
      select: %{id: u.id, points: u.points}
    )
    |> Repo.stream()
    Repo.transaction(fn ->  
      stream |> Enum.to_list()
    end)
    |> case do 
      {:ok, users} -> users
      {:error, error} -> :error
    end
  end
end

# batch = 5000
# max_concurrency = 5
# Completed updating the users table in 3266225 microseconds 3.266225 seconds

# batch = 5000
# max_concurrency = 5
# Completed updating the users table in 3266225 microseconds 3.266225 seconds
