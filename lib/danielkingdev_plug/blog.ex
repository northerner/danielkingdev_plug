defmodule DanielkingdevPlug.Blog do
  alias DanielkingdevPlug.Blog.Post

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:danielkingdev_plug, "priv/posts/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_erlang]

  # The @posts variable is first defined by NimblePublisher.
  # Let's further modify it by sorting all posts by descending date.
  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})

  # Let's also get all tags
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  # And finally export them
  def all_posts, do: @posts
  def all_tags, do: @tags
  def get_post_by_id!(id) do
    Enum.find(all_posts(), &(&1.id == id))
  end

  def get_post_and_adjacent_posts_by_id!(id) do
    index = Enum.find_index(all_posts, &(&1.id == id))
    prev_post = Enum.fetch(all_posts, index + 1)
    next_post = Enum.fetch(all_posts, index - 1)

    [prev_post, get_post_by_id!(id), next_post]
  end
end
