ARG ARGBASH_VERSION=2.10.0
FROM matejak/argbash:$ARGBASH_VERSION as builder

WORKDIR /app
COPY ghrd.m4 ./
RUN argbash ghrd.m4 -o ghrd \
    && chmod +x ghrd

FROM alpine:3.17

ARG MAINTAINER="zero88 <sontt246@gmail.com>"

WORKDIR /app

RUN apk add --no-cache curl jq bash \
    && addgroup -S -g 1000 bot \
    && adduser -S -u 1001 -G bot runner \
    && chown -R runner:bot /app

COPY --chown=runner:bot --from=builder /app/ghrd ./

USER runner:bot

ENV PATH="/app:${PATH}"

ENTRYPOINT [ "ghrd" ]
