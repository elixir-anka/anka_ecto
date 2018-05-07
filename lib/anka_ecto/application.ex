defmodule Anka.Ecto.Application do
    # See https://hexdocs.pm/elixir/Application.html
    # for more information on OTP Applications
    @moduledoc false

    use Application

    def start(_type, _args) do
        # List all child processes to be supervised
        children = [
            # Starts a worker by calling: AnkaEcto.Worker.start_link(arg)
            # {Anka.Ecto.Worker, arg},
        ]

        # See https://hexdocs.pm/elixir/Supervisor.html
        # for other strategies and supported options
        opts = [
            name: Anka.Ecto.Supervisor,
            strategy: :one_for_one,
        ]
        Supervisor.start_link(children, opts)
    end

end
