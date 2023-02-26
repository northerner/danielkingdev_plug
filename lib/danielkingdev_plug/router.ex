defmodule DanielkingdevPlug.Router do
  use Plug.Router
  alias DanielkingdevPlug.Blog, as: Blog

  @template_dir "lib/danielkingdev_plug/templates"

  plug Plug.Logger, log: :debug
  plug Plug.Head
  plug Plug.Static,
    at: "/",
    from: :danielkingdev_plug,
    only: ~w(favicon.ico style.css images fonts)
  plug :match
  plug :dispatch

  get "/" do
    posts = Blog.all_posts
    render(conn, "index.html", [{:posts, posts}])
  end

  get "/about" do
    render(conn, "about.html")
  end

  get "/feed" do
    put_resp_content_type(conn, "application/atom+xml")
    |> send_resp(200, Blog.feed)
  end

  get "/posts" do
    case get_tag(conn) do
      :no_tag ->
        send_resp(conn, :not_found, "Missing tag")
      tag ->
        posts = Blog.get_posts_by_tag(tag)
        render(conn, "posts/index.html", [{:posts, posts}, {:tag, tag}])
    end
  end

  get "/posts/:id" do
    post = Blog.get_post_by_id!(id)
    [prev_post, post, next_post] = Blog.get_post_and_adjacent_posts_by_id!(id)

    render(conn, "posts/show.html", [
      {:post, post},
      {:prev_post, prev_post},
      {:next_post, next_post}
    ])
  end

  match _ do
    send_resp(conn, 404, "ya wot m8?")
  end

  defp get_tag(conn) do
    case Plug.Conn.fetch_query_params(conn).query_params do
      %{"tag" => tag} ->
        case Regex.scan(~r/[a-zA-Z-]+/, tag) do
          [] ->
            :no_tag
          matches ->
            matches |> hd |> hd |> String.downcase
        end
      _ ->
        :no_tag
    end
  end

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".html.eex")
      |> EEx.eval_file(assigns)

    layout =
      @template_dir
      |> Path.join("layout.html.eex")
      |> EEx.eval_file([{:content, body}])

    send_resp(conn, (status || 200), layout)
  end
end
