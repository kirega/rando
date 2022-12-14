defmodule Rando.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        # Start the Ecto repository
        Rando.Repo,
        # Start the Telemetry supervisor
        RandoWeb.Telemetry,
        # Start the PubSub system
        {Phoenix.PubSub, name: Rando.PubSub},
        # Start the Endpoint (http/https)
        RandoWeb.Endpoint,
        # Start a worker by calling: Rando.Worker.start_link(arg)
        # {Rando.Worker, arg}
        {Task.Supervisor, name: Rando.TaskSupervisor}
      ] ++
        if System.get_env("MIX_ENV", "") != "test" do
          [
            {Rando.UserGenServer, struct(Rando.UserGenServer)}
          ]
        else
          []
        end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rando.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RandoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
