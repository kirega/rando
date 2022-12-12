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
  @spec update_all_user_points() :: {:ok, [map()]} | {:error, map()}
  def update_all_user_points() do
    placeholders = %{
      timestamp: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_naive()
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

  @spec get_two_highest_users(number()) ::
          {:ok, [%User{}] | []} | {:error, map()}
  def get_two_highest_users(min_number) do
    stream =
      from(u in User,
        where: u.points >= ^min_number,
        order_by: [desc: u.points],
        limit: 2
      )
      |> Repo.stream()

    Repo.transaction(fn ->
      stream |> Enum.to_list()
    end)
  end

  defp get_max_concurrency do
    db_config = Application.get_env(:rando, Rando.Repo)
    db_config[:pool_size]
  end
end
