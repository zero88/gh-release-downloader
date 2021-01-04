# GitHub release downloader

![Docker Image Version (latest semver)](https://img.shields.io/docker/v/zero88/ghrd?sort=semver&style=flat-square)
![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/zero88/gh-release-downloader?sort=semver)

GitHub release downloader CLI

## Installation

1. Use [`docker`](https://hub.docker.com/r/zero88/ghrd)

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

2. Download latest release then unzip

## Usage

If you want to use `ghrd` locally, please make sure you have these programs before using

- `curl`
- `jq`
- `grep` | `awk` | `td` | `fold`

```bash
$ ghrd -h
<GitHub release downloader>
Usage: ./ghrd [-r|--release <arg>] [-t|--pat <arg>] [-a|--artifact <arg>] [-x|--(no-)regex] [-p|--parser <arg>] [-s|--source <SOURCE>] [-o|--output <arg>] [--(no-)debug] [-h|--help] [-v|--version] <repo>
        <repo>: GitHub repository. E.g: zero88/gh-release-downloader
        -r, --release: A release version (default: 'latest')
        -t, --pat: GitHub Personal access token (no default)
        -a, --artifact: Artifact name (no default)
        -x, --regex, --no-regex: Use regex to search artifact (off by default)
        -p, --parser: Use custom jq parser instead of search by artifact name (no default)
        -s, --source: Download Repository Source instead of release artifact. Can be one of: 'zip', 'tar' and '' (no default)
        -o, --output: Downloaded directory (default: '/app')
        --debug, --no-debug: Debug option (off by default)
        -h, --help: Prints help
        -v, --version: Prints version
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

This project is licensed under the Apache License - see the [LICENSE](./LICENSE) file for details

## References

Awesome bash arguments from [Argbash](https://argbash.io)
