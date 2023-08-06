defmodule DanielkingdevPlug.Blog do
  alias DanielkingdevPlug.Blog.NewPost, as: Post
  alias DanielkingdevPlug.Blog.Feed, as: Feed
  alias DanielkingdevPlug.Blog.Search, as: Search

  @posts Enum.sort_by(Post.build_posts, & &1.date, {:desc, DateTime})

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

  def get_posts_by_term(term) when is_binary(term) do
    stem = Stemmer.stem(term)
    Search.find_by_frequency(@search_index, stem)
    |> Enum.map(fn id -> Enum.at(@posts, id) end)
  end

  def get_posts_by_term(term) when is_list(term) and length(term) > 1 do
    intersection = Enum.reduce(term, MapSet.new(all_posts()), fn word, acc ->
      get_posts_by_term(word)
      |> MapSet.new
      |> MapSet.intersection(acc)
    end)

    MapSet.to_list(intersection)
  end

  def get_posts_by_term(term) when is_list(term) do
    get_posts_by_term(hd(term))
  end

  def get_post_and_adjacent_posts_by_id!(id) do
    index = Enum.find_index(all_posts(), &(&1.id == id))
    prev_post = Enum.fetch(all_posts(), index + 1)
    next_post = Enum.fetch(all_posts(), index - 1)

    [prev_post, get_post_by_id!(id), next_post]
  end
end
