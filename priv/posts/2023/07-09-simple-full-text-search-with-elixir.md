%{
  title: "Simple full-text search with Elixir",
  author: "Daniel King",
  tags: ~w(elixir search software simplicity stemming),
  description: "How to add in-memory full-text search to any site with Elixir"
}
---

This blog really doesn't need a search feature. It has just five posts so far, and I'm guessing even fewer readers. But why should that stop me!

Inspired by a post I discovered about building a [full-text search engine in 150 lines of Python](https://bart.degoe.de/building-a-full-text-search-engine-150-lines-of-code/), I thought it could be an interesting exercise in Elixir. Since this simple blog [compiles all the markdown pages and loads the HTML into memory](/posts/building-a-not-quite-static-site-with-elixir), all the search indexing could be done ahead of time too.

Elixir is a functional language, where piping data between functions is as easy as "|>", so it makes this sort of indexing task quite easy to follow too.

Most of the work is done in this 12 line function when the blog first loads:

```elixir
def build_index(posts) do
  Stream.with_index(posts)
  |> Enum.reduce(%{}, fn ({post, current_post_index}, word_index) ->
    extract_text_from_markdown(post.markdown_body)
    |> String.replace(~r/[.,":;()<>?\\\/]+/, " ")
    |> String.downcase
    |> String.split(~r/\s+/)
    |> Enum.uniq
    |> Stemmer.stem
    |> add_words_to_index(current_post_index, word_index)
  end)
end
```

The function takes an array of posts, written in the Markdown format, and reduces over the collection to build up an index of each word used with a list of pages it appears in, just like the index you'd find in the back of any reference book:

```elixir
"alongsid" => [0],
"along" => [4, 3],
"rubi" => [4, 2, 0],
"game" => [3, 3, 3],
"work" => [4, 4, 4, 3, 3, 2, 1, 0, 0, 0],
"sourc" => [3, 0],
"run" => [4, 4, 3, 3, 1, 1, 0, 0],
"understand" => [4]
```

By passing in just the Markdown, rather than the generated HTML, I can make sure to just index the text nodes. We still need to filter out some extra characters though, along with stemming each word.

The stemming process is why the words in the example above look a little strange. Take the "sourc" example, it is the stem of "source", "sourced", "sourcing" and "sources". By just storing the stem now we can later stem the input search terms and find all similar uses of the word.

When you search for a word we then find it in the index and order the results by the frequency that the term appears in the post:

```elixir
def find_by_frequency(index, stem) do
  case Map.fetch(index, stem) do
    {:ok, post_ids} ->
      Enum.frequencies(post_ids)
      |> Enum.sort_by(&(elem(&1, 1)), :desc)
      |> Enum.map(&(elem(&1, 0)))
    _ ->
      []
  end
end
```

The ordering by frequency could have been done at the earlier indexing step too, it will make no difference to performance for such a small index as it works now, but I'm sure the slight inefficiency will eventually motivate me to change this.

That seems like enough for now, but if you ever find yourself implementing this for a larger data set it would definitely be worth investigating ranking by [inverse document frequency](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) too.
