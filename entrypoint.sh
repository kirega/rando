#!/bin/bash

DB_USER=${POSTGRES_USER:-postgres}

# # wait until Postgres is ready
while ! pg_isready -h $DATABASE_HOST -U $POSTGRES_USER
do
  echo "$(date) - waiting for database to start user -> ${POSTGRES_USER} host -> ${DATABASE_HOST} "
  sleep 2
done

bin="/app/bin/rando"
# start the elixir application
echo 'connected to db'

eval "$bin eval \"Rando.Release.seed\""

echo "starting the server"
exec "$bin" "start"
