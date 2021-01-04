# Docker

![Docker Image Version (latest semver)](https://img.shields.io/docker/v/zero88/ghrd?sort=semver&style=flat-square)

Docker Registry for GitHub action cache.

## Reference

- From [GitHub repository](https://github.com/zero88/gh-release-downloader)

## Usage

- One line

      ```bash
      docker run --rm -v /tmp:/tmp zero88/ghrd:latest -h
      ```

- Register as alias in `~/.bash_alias` or `~/.bash_rc`

      ```bash
      cat >> ~/.bash_alias <<EOL
      #### GHRD
      GHRD_VERSION=1.1.1
      alias ghrd="docker run --rm -v /tmp:/tmp zero88/ghrd:$GHRD_VERSION"
      EOL

      source ~/.bashrc
      ```
