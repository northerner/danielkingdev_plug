defmodule DanielkingdevPlug.Blog.Bluesky do
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
    IO.puts "Fetching posts..."

    resp = Req.get!(
      "https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed?actor=did:plc:nmtxkowa2h27yvdqjq7wi6sq",
      cache: true
    )

    Enum.map(resp.body["feed"], fn %{"post" => %{"record" => record, "uri" => uri, "author" => author}} ->
      created_at = DateTime.from_iso8601(record["createdAt"])
      |> elem(1)
      |> Calendar.strftime("%A, %B %d %Y")

      %{
        "content" => record["text"],
        "created_at" => created_at,
        "url" => uri,
        "name" => author["displayName"],
        "avatar" => author["avatar"]
      }
    end)
  end
end
