defmodule Rando.Release do
  @app :rando
  @repo Rando.Repo

  def migrate do
    case load_app() do
      :ok ->
        {:ok, _, _} = Ecto.Migrator.with_repo(@repo, &Ecto.Migrator.run(&1, :up, all: true))

      {:error, {:already_loaded, :rando}} ->
        {:ok, _, _} = Ecto.Migrator.with_repo(@repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    case load_app() do
      :ok ->
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))

      {:error, {:already_loaded, :rando}} ->
        {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    end
  end

  def seed do
    case load_app() do
      :ok ->
        seed_file = Path.join(:code.priv_dir(@app), "/repo/seeds.exs")

        {:ok, _} = Application.ensure_all_started(@app)

        {:ok, _, _} = Ecto.Migrator.with_repo(@repo, &Ecto.Migrator.run(&1, :up, all: true))

        Code.eval_file(seed_file)

      {:error, {:already_loaded, :rando}} ->
        seed_file = Path.join(:code.priv_dir(@app), "/repo/seeds.exs")
        {:ok, _} = Application.ensure_all_started(@app)

        {:ok, _, _} = Ecto.Migrator.with_repo(@repo, &Ecto.Migrator.run(&1, :up, all: true))

        Code.eval_file(seed_file)
    end
  end

  defp load_app do
    Application.load(@app)
  end
end
