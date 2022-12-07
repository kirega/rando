# Rando
Welcome to Rando, an Elixir Phoenix service to provide you with all your user randomization needs.

# Prerequisites 
Before you can run this project, you will need to have the following: 

1. Postgres - our database you may find instructions on how to set it up [](here)
2. Asdf - the flexible package manager, find it [](here)

## How to start the project

To start the Rando server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`


Now you can visit [`localhost:4000`](http://localhost:4000) from your browser, postman or curl.

## Available Endpoints
This service only implements a single endpoint, `http://localhost:4000/` that returns a max of 2 users(may sometimes return 1 user) with 
the highest points from a randomized draw.

## You

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
