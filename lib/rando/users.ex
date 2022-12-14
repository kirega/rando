defmodule Rando.Users do
  @moduledoc """
  Rando.Users modules is the context manager for the Rando.User module.
  """

  import Ecto.Query
  alias Rando.User
  alias Rando.Repo
  require Logger

  @chunk 5_000
  @type user_t :: %User{}
  @doc """
  update_all_user_points()
  It fetches and updates all the users points in the database.
  """
  @spec update_all_user_points() :: {:ok, [map()]} | {:error, map()}
  def update_all_user_points() do
    placeholders = %{
      timestamp: naive_timestamp()
    }

    Repo.transaction(fn ->
      Repo.stream(from(u in User))
      |> Stream.map(&build_user(&1))
      |> Stream.chunk_every(@chunk)
      |> Task.async_stream(&insert_user_chunk(&1, placeholders),
        max_concurrency: get_max_concurrency(),
        ordered: false
      )
      |> Enum.to_list()
    end)
  end

  defp build_user(user) do
    %{
      id: user.id,
      points: random_points(),
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

  @spec get_two_highest_users(number()) :: [user_t()] | []
  def get_two_highest_users(min_number) do
    from(u in User,
      where: u.points >= ^min_number,
      limit: 2,
      order_by: fragment("RANDOM()")
    )
    |> Repo.all()
  end

  defp get_max_concurrency do
    Application.get_env(:rando, Rando.Repo) |> Keyword.get(:pool_size)
  end

  defp random_points() do
    Application.get_env(:rando, :max_range)
    |> :rand.uniform()
  end

  def timestamp() do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.to_naive()
    |> NaiveDateTime.to_string()
  end

  def naive_timestamp() do
    DateTime.utc_now()
    |> DateTime.truncate(:second)
    |> DateTime.to_naive()
  end
end
