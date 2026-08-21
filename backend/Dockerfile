FROM elixir:1.20

WORKDIR /app

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    git \
    inotify-tools \
    && rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && \
    mix local.rebar --force

EXPOSE 4000
