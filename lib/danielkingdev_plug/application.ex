defmodule DanielkingdevPlug.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Bandit, plug: DanielkingdevPlug.Router, scheme: :http},
      {DanielkingdevPlug.Blog.Mastodon, []}
    ]

    opts = [strategy: :one_for_one, name: DanielkingdevPlug.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
