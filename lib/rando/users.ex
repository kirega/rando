defmodule Rando.Users do
  import Ecto.Query, only: [from: 2]
  alias Rando.User
  alias Rando.Repo
  require Logger

  @chunk 16_380

  @moduledoc """
  Rando.Users modules is the context manager for the Rando.User module.
  """

  @doc """
  update_all()
  It fetches and updates all the users in the database. It relies on `insert_all/3`
  """
  def update_all_user_points() do
    Logger.debug("Started updating the users table")
    start_time = NaiveDateTime.utc_now()
    placeholders = %{timestamp: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)}

    Repo.all(User)
    |> Enum.map(fn user ->
      %{
        id: user.id,
        points: :rand.uniform(100),
        inserted_at: {:placeholder, :timestamp},
        updated_at: {:placeholder, :timestamp}
      }
    end)
    |> Enum.chunk_every(@chunk)
    |> Enum.each(fn user_chunk ->
      Repo.insert_all(
        User,
        user_chunk,
        placeholders: placeholders,
        on_conflict: :replace_all,
        conflict_target: [:id]
      )
    end)

    end_time = NaiveDateTime.utc_now()
    diff = Time.diff(end_time, start_time)
    Logger.debug("Completed updating the users table in #{diff} seconds")
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
