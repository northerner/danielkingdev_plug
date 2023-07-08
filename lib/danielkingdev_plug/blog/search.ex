defmodule DanielkingdevPlug.Blog.Search do
  def build_index(posts) do
    Stream.with_index(posts)
    |> Enum.reduce(%{}, fn ({post, current_post_index}, word_index) ->
      extract_text_from_markdown(post.markdown_body)
      |> String.replace(~r/![[:word:]]+/, " ")
      |> String.downcase
      |> String.split(~r/\s+/)
      |> Enum.uniq
      |> Stemmer.stem
      |> add_words_to_index(current_post_index, word_index)
    end)
  end

  defp extract_text_from_markdown(md) when is_binary(md) do
    {:ok, ast, _} = Earmark.as_ast(md)
    String.trim(extract_text_from_ast(ast, ""))
  end

  defp extract_text_from_ast(ast, result) when is_list(ast) and is_binary(result) do
    Enum.reduce(ast, result, fn
      {_html_tag, _atts, children, _m}, acc ->
        extract_text_from_ast(children, acc)

      text_leaf, acc when is_binary(text_leaf) ->
        acc <> " " <> text_leaf
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
