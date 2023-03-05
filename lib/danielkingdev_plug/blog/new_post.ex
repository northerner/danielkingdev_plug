defmodule DanielkingdevPlug.Blog.NewPost do
  @enforce_keys [:id, :author, :title, :html_body, :markdown_body, :description, :tags, :date]
  defstruct [:id, :author, :title, :html_body, :markdown_body, :description, :tags, :date]

  def build_posts do
    paths =
      Application.app_dir(:danielkingdev_plug, "priv/posts/**/*.md")
      |> Path.wildcard()
      |> Enum.sort()

    for path <- paths do
      {attrs, markdown_body} = parse_contents(path, File.read!(path))
      html_body = Earmark.as_html!(markdown_body)

      build(path, attrs, html_body, markdown_body)
    end
  end

  def parse_contents(path, contents) do
    case :binary.split(contents, ["\n---\n", "\r\n---\r\n"]) do
      [_] ->
        {:error, "could not find separator --- in #{inspect(path)}"}

      [code, body] ->
        case Code.eval_string(code, []) do
          {%{} = attrs, _} ->
            {attrs, body}

          {other, _} ->
            {:error,
             "expected attributes for #{inspect(path)} to return a map, got: #{inspect(other)}"}
        end
    end
  end

  def build(filename, attrs, html_body, markdown_body) do
    [year, month_day_id] = filename |> Path.rootname() |> Path.split() |> Enum.take(-2)
    [month, day, id] = String.split(month_day_id, "-", parts: 3)
    {:ok, date, _} = DateTime.from_iso8601("#{year}-#{month}-#{day}T00:00:00Z")
    struct!(__MODULE__, [id: id, date: date, html_body: html_body, markdown_body: markdown_body] ++ Map.to_list(attrs))
  end
end
