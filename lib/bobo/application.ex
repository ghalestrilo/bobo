defmodule Bobo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BoboWeb.Telemetry,
      Bobo.Repo,
      {DNSCluster, query: Application.get_env(:bobo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Bobo.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Bobo.Finch},
      # Start a worker by calling: Bobo.Worker.start_link(arg)
      # {Bobo.Worker, arg},
      # Start to serve requests, typically the last entry
      BoboWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bobo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BoboWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
