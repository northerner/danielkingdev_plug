defmodule DanielkingdevPlug.Blog.Search do
  def build_index(posts) do
    Stream.with_index(posts)
    |> Enum.reduce(%{}, fn ({post, current_post_index}, word_index) ->
      String.downcase(post.body)
      |> String.split(" ")
      |> Enum.filter(fn x -> String.match?(x, ~r/^[[:word:]]+$/) end)
      |> Enum.uniq
      |> add_words_to_index(current_post_index, word_index)
    end)
  end

  defp add_words_to_index(words, current_post_index, word_index) do
    Enum.reduce(words, word_index, fn word, acc ->
      Map.get_and_update(acc, word, fn post_ids_for_word ->
        { word, [ current_post_index | post_ids_for_word || []] }
      end)
      |> elem(1)
    end)
  end
end
