# Rando :game_die:

Welcome to Rando, an Elixir Phoenix service to provide you with randomized users.

## About

This service only implements a single public endpoint, that returns a max of 2 users with more than a random number of points.

---

## How to start the project

## Prerequisites

The prerequisites to run this project will depend on the mode you choose:

#### 1. From build

Before you can run this project, you will need to have the following:

1. `postgres` - our database you may find instructions on how to set it up [here](https://www.postgresql.org/)
2. `asdf` - the flexible runtime version manager, find it [here](https://asdf-vm.com/). This will ensure that everyone runs the same version of erlang and elixir.
3. `git` - package manager

To start the Rando server:

- Asdf requires you add a couple of plugins, which can easily be added using
  - `asdf plugin add erlang`
  - `asdf plugin add elixir`
- clone the repo
  - `git clone git@github.com:kirega/rando.git`
- Change in the directory
  - `cd rando`
- Run asdf to setup the environment
  - `asdf install`
- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
- For testing, run `MIX_ENV=test mix test`

### 2. With docker-compose

Depending on the platform you are running, you may find the required docker installation instructions [here](https://docs.docker.com/get-docker/)
Once you have docker and docker-compose setup follow the below instruction:

```
git clone git@github.com:kirega/rando.git
cd rando
docker-compose up
```

## Configuration

You may add and override the default configurations of this project by creating your custom configuration file within the `config` folder.

The config file should be named in the format, `#{placeholder}.secret.exs` where the placeholder is the name of the enviroment. There is a provided `config/dev.secret.example.exs` to illustrate how to setup the custom config.

## Available Endpoints

One public endpoint as root `/`

`GET` http://localhost:4000/

When you GET the endpoint above, you should receive a response like the one below
(if the server started successfully)

```elixir
{
  'users': [{id: 1, points: 30}, {id: 72, points: 30}],
  'timestamp': `2020-07-30 17:09:33`
}
```
### Author
kirega