defmodule DanielkingdevPlug.Blog.Mastodon do
  def fetch do
    resp = Req.get!(
      "https://antiquated.systems/api/v1/accounts/108233374888035311/statuses?limit=5",
      auth: {:bearer, System.get_env("MASTODON_TOKEN")}
    )

    Enum.map(resp.body, fn item -> Map.take(item, ["content", "created_at", "url"]) end)
  end
end
