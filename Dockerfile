ARG BUILDER_IMAGE="elixir:1.14.0-alpine"

FROM ${BUILDER_IMAGE} as builder
ENV MIX_ENV="prod"

WORKDIR /app
# install build dependencies
RUN apk update \
    && apk --no-cache --update add alpine-sdk \
    && mix local.rebar --force \
    && mix local.hex --force

# prepare build dir
COPY . .

# install mix dependencies
RUN mix deps.get --only $MIX_ENV && mix deps.compile

RUN mix release

# # start a new build stage so that the final image will only contain
# # the compiled release and other runtime necessities
FROM ${BUILDER_IMAGE}
WORKDIR /app

RUN  apk update \
    && apk --no-cache --upgrade add bash ca-certificates openssl-dev libstdc++ ncurses-dev ncurses-libs postgresql-client

EXPOSE 8080

# Only copy the final release from the build stage

COPY --from=builder /app/_build/prod/rel/rando .
COPY ./entrypoint.sh ./entrypoint.sh

# USER nobody
# RUN "chmod +x ./entrypoint.sh"

CMD ["bash", "entrypoint.sh"]
