defmodule DanielkingdevPlug.Router do
  use Plug.Router

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
    posts = DanielkingdevPlug.Blog.all_posts
    render(conn, "index.html", [{:posts, posts}])
  end

  get "/about" do
    render(conn, "about.html")
  end

  get "/posts/:id" do
    post = DanielkingdevPlug.Blog.get_post_by_id!(id)
    [prev_post, post, next_post] = DanielkingdevPlug.Blog.get_post_and_adjacent_posts_by_id!(id)
    render(conn, "posts/show.html", [
      {:post, post},
      {:prev_post, prev_post},
      {:next_post, next_post}
    ])
  end

  match _ do
    send_resp(conn, 404, "ya wot m8?")
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