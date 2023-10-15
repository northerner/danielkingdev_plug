%{
  title: "Holding state in Elixir",
  author: "Daniel King",
  tags: ~w(elixir software state functional-programming otp),
  description: "Using Elixir's Agent module to cache an API call"
}
---

Sharing state in Elixir (like Erlang) can be a little strange for those coming from other languages, just assigning to a global variable is not possible here. In Elixir all your code is running in isolated processes with no shared state, so the main option for sharing state is built on long-lived processes and message passing.

In adding some caching for the [Mastodon](/statuses) page of this site I reached for Elixir's very useful [Agent](https://elixir-lang.org/getting-started/mix-otp/agent.html) module, a simple wrapper around the more complex GenServer abstraction that can store and share state.

The code is shared below. The `start_link` function is to create the process with some initial state, and tags it with a global name so other processes can find it.

The API call is done in `fetch`, I want to avoid calling it too often, so the public `statuses` function will return the cached state with `Agent.get()` and only try to fetch statuses again if the current list is empty or hasn't been refreshed today.


## Caching an API response with an Agent

```elixir
defmodule DanielkingdevPlug.Blog.Mastodon do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> {NaiveDateTime.utc_now(), []} end, name: __MODULE__)
  end

  def statuses do
    {time, statuses} = Agent.get(__MODULE__, &(&1))

    if statuses == [] || (NaiveDateTime.before?(time, beginning_of_today())) do
      new_statuses = fetch()
      Agent.update(__MODULE__, fn _ -> {NaiveDateTime.utc_now(), new_statuses} end)
      new_statuses
    else
      statuses
    end
  end
  
  defp beginning_of_today() do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.beginning_of_day()
  end

  defp fetch do
    IO.puts "Fetching toots..."

    resp = Req.get!(
      "https://PATH_TO_MASTODON_API",
      auth: {:bearer, System.get_env("MASTODON_TOKEN")},
      cache: true
    )

    Enum.map(resp.body, fn item ->
      Map.take(item, ["content", "created_at", "url", "media_attachments"])
    end)
  end
end
```

With this in place I just need to add the agent to my supervision tree with a line in the `children` array, that will make sure the process is always running, available to any other process by calling `Blog.Mastodon.statuses()`.


```elixir
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
```
