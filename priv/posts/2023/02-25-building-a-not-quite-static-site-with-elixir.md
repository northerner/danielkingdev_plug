%{
  title: "Building a not-quite-static site with Elixir",
  author: "Daniel King",
  tags: ~w(elixir),
  description: "How this site was constructed with Elixir, Plug, and NimblePublisher"
}
---
Instant page loading has always been the main appeal of static sites to me, with this rebuild of my blog in Elixir it averages around 13ms loading from fly.io's CDN.

But this is not a traditional static site with a bunch of HTML files served direct from disk, like you might generate with [Jekyll](https://jekyllrb.com/) or [Hugo](https://gohugo.io/). It uses some of the same conventions like posts written in markdown with metadata attached, but no HTML files are written at the build stage, just a small Elixir app.

## Keeping it simple

I had been meaning to move this blog off Wordpress for a while, but it was listening to [Derek Sivers talk on a recent Remote Ruby episode](https://remoteruby.com/216) that finally nudged me to make the effort. Derek's philosophy of keeping the software he builds and maintains as simple as possible means most of his sites use just two gems, Sinatra and pg.

Coming from the Rails world in my day job, that seems quite extreme. That's not to say I liberally add in [dependencies](https://www.npmjs.com/package/left-pad) for any new feature I write, I do try to be conservative with adding gems. But hearing "just two gems" will probably make most developers conclude he ends up rolling his own templating, authentication, translations, API clients, etc...

And that may be the case with some projects, but it is rarely the case that you need **all** the features of each dependency you add. How many developers importing the popular [Devise](https://github.com/heartcombo/devise) gem into their Ruby project use all of its authentication features?

The benefit of building each of these features yourself is you can add the **minimal** version you need for your use case. That keeps the software [simple](https://www.youtube.com/watch?v=rI8tNMsozo0), and hopefully maintainable. Although for larger team projects, with regular employee turnover, I expect reaching for well-known libraries remains the better long-term option.

This is not the part where I advocate for the one developer at every company that will always "roll their own" on every new feature they add, but I do have more sympathy for them these days. More often than not the problem in these cases is the lack of documentation and tests produced alongside the code, rather than the fact it was custom-built over a popular open source alternative.

## You were saying something about Wordpress?

Yes, back to this blog, I'm not trying to be negative towards Wordpress here, it is still a solid option for just focusing on writing and publishing your thoughts, without obsessing about all the tech stack in-between.

When I started this iteration of my blog back in 2020 (sadly only 4 posts before I went AWOL this time) I decided on Wordpress specifically because all my previous blogs were way more focused on the tech than actually writing. Trying out the endless options for static site generators, or building my own in one case, was usually the motivation.

In some sense this post is a sign I'm back to bad habits.

## Elixir, Plug and NimblePublisher

In the spirit of Derek Sivers building everything with Sinatra I wanted to just stick with [Plug](https://github.com/elixir-plug/plug), a simple, adaptable library for routing web requests through Elixir functions, and no database. Although I'm still bringing in a few extra dependencies in some cases, like NimblePublisher, my hope is to eventually remove them when I zone in on the minimum feature set I'm using from each and rewrite.

[NimblePublisher](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made) allows you to compile a bunch of markdown pages into memory and quickly serve them from a lightweight app at runtime. Paired with plug this means my app just consumes 72MB on a free Fly.io app. True, that is not as kind to the environment as static pages on shared hosting, but it allows for a few extra features since we can do any extra processing we want at run time.

![This site consuming 72MB on fly.io](/images/fly-memory.png)

The obvious extras you might want for a blog are tagging and search. You can implement tagging with static generators, but this is achieved in a very verbose style, essentially generating copies of all the pages tagged with a specific tag in a folder named for that tag. This is often why static generators only let you filter by a single tag at once, since each extra tag starts to grow the nested folder structure exponentially.

I've still not added tagging yet as I write this, but plan to work on it next. My other goal is to write a simple search function, since all the posts are in memory I can parse them at build time to create an index which can be ranked for relevancy. My inspiration for this is Bart de Goede's great post on a [full text-search engine in 150 lines of Python](https://bart.degoe.de/building-a-full-text-search-engine-150-lines-of-code/).

I know adding search to a blog with only 5 posts sounds like a joke, but I really just want to try out how achievable this small feature is without extra dependencies, and hopefully learn something.

## Feeling less guilty about "shortcuts"

The code is [public](https://github.com/northerner/danielkingdev_plug/blob/main/lib/danielkingdev_plug/router.ex), definitely not ready to be public yet, but I figure I'd use that excuse to keep the repo private forever if I considered perfect idiomatic Elixir to be my standard. After not writing much Elixir for a few years I'm enjoying having such powerful pattern matching syntax again, it works so well for routing web requests.

Here's the full routing file of 58 lines, where most of the logic lives:

```elixir
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
```

I particularly like my hacky solution for adding a wrapping "layout" template in the render function above. After some searching I discovered there's no built-in option for this with EEx templating, that sort of behaviour is custom to frameworks like [Phoenix](https://github.com/phoenixframework/phoenix/blob/6aef3e20072135d681e7e01ed67a9f0f4ca3344f/lib/phoenix/controller.ex#L617).

So I took the simple approach, just rendering the template first, then passing that rendered HTML as input for rendering the parent layout file. It initially seemed wrong to me, like it could lead to escaping issues (and maybe it does) but it seems to work fine for now. Perhaps there is a cleaner way to do it, with Elixir's quote/unquote metaprogramming that means I only call `eval_file` once, but this "just works" for the small use case I have here and can always be revisited if layouts get more complex.

## Deploying to fly.io

The site is deployed on [fly.io](https://fly.io/)'s free tier. I know they are the big VC-backed giant in the post-Heroku world, and self-hosting might fit better with the philosophy I'm advocating here, but they really do have that simplicity that made early Heroku so pleasant to use.

Although their Elixir docs are mostly Phoenix focused, their `fly deploy` command worked quite well for me, generating a TOML config file, then building and pushing a release. The one gotcha for me was not setting the port my app is running on internally (4000), this has to be configured or the app is left in a permanent unreachable state.

## Next steps

This has been a fun distraction for a few days, and it has me excited about Elixir again. The next steps will be to look at tag filtering and the full-text search I mentioned, perhaps some ActivityPub integration too. But my main goal is to keep the blogging more regular, at least more often that once every 3 years.
