# Build on the official elixir docker image
FROM elixir:1.16.3

# The working directory to build from
WORKDIR /app
COPY . .

# Install hex & rebar
RUN mix local.hex --force && \
    mix local.rebar --force

RUN mix deps.get

ENV MIX_ENV=prod

RUN mix release unix

ENTRYPOINT ["_build/prod/rel/unix/bin/unix", "start"]
