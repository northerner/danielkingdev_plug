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
      "https://antiquated.systems/api/v1/accounts/108233374888035311/statuses?limit=5&exclude_replies=true&exclude_reblogs=true",
      auth: {:bearer, System.get_env("MASTODON_TOKEN")},
      cache: true
    )

    Enum.map(resp.body, fn item ->
      Map.take(item, ["content", "created_at", "url", "media_attachments"])
    end)
  end
end
