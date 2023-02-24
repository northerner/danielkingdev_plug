defmodule DanielkingdevPlug.Blog.Feed do
  alias Atomex.{Feed, Entry}

  def build(posts) do
    Feed.new("https://danielking.dev", DateTime.utc_now, "A blog about software")
    |> Feed.author("Daniel King")
    |> Feed.link("https://danielking.dev/feed", rel: "self")
    |> Feed.entries(Enum.map(posts, &get_entry/1))
    |> Feed.build()
    |> Atomex.generate_document()
  end

  defp get_entry(%{id: id, body: body, date: date, title: title}) do
    Entry.new("https://danielking.dev/posts/#{id}", date, title)
    |> Entry.author("Daniel King")
    |> Entry.content(body, type: "html")
    |> Entry.build()
  end
end
