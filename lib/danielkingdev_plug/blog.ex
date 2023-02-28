defmodule DanielkingdevPlug.Blog do
  alias DanielkingdevPlug.Blog.Post
  alias DanielkingdevPlug.Blog.Feed, as: Feed
  alias DanielkingdevPlug.Blog.Search, as: Search

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:danielkingdev_plug, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  # The @posts variable is first defined by NimblePublisher.
  # Let's further modify it by sorting all posts by descending date.
  @posts Enum.sort_by(@posts, & &1.date, {:desc, DateTime})

  # Let's also get all tags
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  @feed Feed.build(@posts)

  @search_index Search.build_index(@posts)

  # And finally export them
  def all_posts, do: @posts
  def all_tags, do: @tags
  def feed, do: @feed

  def get_post_by_id!(id) do
    Enum.find(all_posts(), &(&1.id == id))
  end

  def get_posts_by_tag(tag) do
    Enum.filter(all_posts(), &(Enum.member?(&1.tags, tag)))
  end

  def get_posts_by_term(term) do
    case Map.fetch(@search_index, term) do
      {:ok, posts} ->
        Enum.map(posts, fn id -> Enum.at(@posts, id) end)
      _ ->
        []
    end
  end

  def get_post_and_adjacent_posts_by_id!(id) do
    index = Enum.find_index(all_posts, &(&1.id == id))
    prev_post = Enum.fetch(all_posts, index + 1)
    next_post = Enum.fetch(all_posts, index - 1)

    [prev_post, get_post_by_id!(id), next_post]
  end
end
