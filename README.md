# DanielkingdevPlug

The code behind my blog at danielking.dev.

Written in Elixir, and compiling posts from markdown into memory at runtime, this blog follows the not-quite-a-static-site-generator pattern of the [NimblePublisher](https://github.com/dashbitco/nimble_publisher) library.

This allows for the simplicity of posts in single markdown files, like you would have with traditional static site generators, without needing to generate all the extra/duplicate pages you would need for features like tag filtering and search.

## Installation

1. Install Elixir and dependencies.
2. Pull the repo and run `mix deps.get`
3. Start the server with `mix run --no-halt`
4. View the site at http://localhost:4000

## Deploy

1. Install the fly.io CLI tool.
2. Run `fly deploy`
