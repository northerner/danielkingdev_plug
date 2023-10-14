defmodule DanielkingdevPlug.Blog.Mastodon do
  use Agent

  def start_link(_) do
    initial_statuses = fetch()
    Agent.start_link(fn -> {NaiveDateTime.utc_now(), initial_statuses} end, name: __MODULE__)
  end

  def statuses do
    {time, statuses} = Agent.get(__MODULE__, &(&1))
    beginning_of_today = NaiveDateTime.beginning_of_day(NaiveDateTime.utc_now())

    if (NaiveDateTime.before?(time, beginning_of_today)) do
      new_statuses = fetch()
      Agent.update(__MODULE__, fn _ -> {NaiveDateTime.utc_now, new_statuses} end)
      new_statuses
    else
      statuses
    end
  end

  defp fetch do
    IO.puts "Fetching toots..."

    resp = Req.get!(
      "https://antiquated.systems/api/v1/accounts/108233374888035311/statuses?limit=5&exclude_replies=true&exclude_reblogs=true",
      auth: {:bearer, System.get_env("MASTODON_TOKEN")},
      cache: true
    )

    Enum.map(resp.body, fn item -> Map.take(item, ["content", "created_at", "url"]) end)
  end
end
