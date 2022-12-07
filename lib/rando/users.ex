defmodule Rando.Users do
  import Ecto.Query
  alias Rando.User
  alias Rando.Repo
  require Logger

  @chunk 5_000

  @moduledoc """
  Rando.Users modules is the context manager for the Rando.User module.
  """

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
      |> Stream.map(fn user ->
        %{
          id: user.id,
          points: :rand.uniform(100),
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      end)
      |> Stream.chunk_every(@chunk)
      |> Task.async_stream(
        fn user_chunk ->
          Repo.insert_all(
            User,
            user_chunk,
            placeholders: placeholders,
            on_conflict: :replace_all,
            conflict_target: [:id]
          )
        end,
        max_concurrency: 5,
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

  def create_updated_user(user) do
    %{
      id: user.id,
      points: :rand.uniform(100),
      inserted_at: {:placeholder, :timestamp},
      updated_at: {:placeholder, :timestamp}
    }
  end

  def get_two_highest_user(min_number) do
    from(u in User,
      where: u.points >= ^min_number,
      limit: 2,
      select: %{id: u.id, points: u.points}
    )
    |> Repo.all()
  end
end

# batch = 5000
# max_concurrency = 5
# Completed updating the users table in 3266225 microseconds 3.266225 seconds

# batch = 5000
# max_concurrency = 5
# Completed updating the users table in 3266225 microseconds 3.266225 seconds
