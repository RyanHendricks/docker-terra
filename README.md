# Docker-Terra

Dockerized Terra Node with Optional Bootstrap for Fast Syncing

---

[![MicroBadger Version](https://images.microbadger.com/badges/version/ryanhendricks/docker-terra.svg)](https://microbadger.com/images/ryanhendricks/docker-terra)
[![CircleCI (all branches)](https://img.shields.io/circleci/project/github/RyanHendricks/docker-terra.svg?label=build&logo=circleci&logoColor=white)](https://circleci.com/gh/RyanHendricks/docker-terra)
[![Docker Pulls](https://img.shields.io/docker/pulls/ryanhendricks/docker-terra.svg?logo=docker&logoColor=white)](https://hub.docker.com/r/ryanhendricks/docker-terra)

[![MicroBadger Layers (latest)](https://img.shields.io/microbadger/layers/ryanhendricks/docker-terra/latest.svg?logo=docker&logoColor=white)](https://microbadger.com/images/ryanhendricks/docker-terra)
[![MicroBadger Image-Size (latest)](https://img.shields.io/microbadger/image-size/ryanhendricks/docker-terra:latest.svg?logo=docker&logoColor=white)](https://microbadger.com/images/ryanhendricks/docker-terra)

[![Codacy grade](https://img.shields.io/codacy/grade/c35da045d95b4f07b09948d19bacaa47.svg?logo=codacy)](https://www.codacy.com?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=RyanHendricks/docker-terra&amp;utm_campaign=Badge_Grade)

---

## Prerequisites

- Docker
- Docker-Compose (optional)

## Quick Start

The image can be run without any configuration and defaults to mainnet

```bash
docker  run --rm -it -P --env SEEDS='0141b28d81db4e5b55736a6367cf044c35a8c29e@35:245:96:132:26656' ryanhendricks/docker-terra:latest
# Feel free to use an alternate seed node although without one the node will have issues starting

```

## Configuration

### Config.toml Parameters

- The config.toml is created dynamically when starting the container.
- All parameters specified in the standard config.toml file can be set using environmental variables with the same name as the config parameter but in all caps. See [entrypoint script](./scripts/entrypoint.sh) for more details.
- If left unset the default values will be used.
- Parameters can be set directly by modifying the config.toml portion of ./scripts/entrypoint.sh if you are cloning and building the image yourself.

### Environment Variables

```bash
# EXAMPLES

MONIKER=nonamenode
CHAIN_ID=columbus-2
GENESIS_URL=https://raw.githubusercontent.com/terra/launch/master/genesis.json
BOOTSTRAP=TRUE
SEEDS=
PROMETHEUS=true

```

You can set ENV variables either in a docker-compose file or in the docker run command if running the container directly. If left unchanged they will default to the standard value except for the following:

- MONIKER
  - defaults to "nonamenode"
- CHAIN_ID
  - defaults to columbus-2
- GENESIS_URL
  - defaults to columbus-2 github [genesis file url](https://raw.githubusercontent.com/terra/launch/master/genesis.json)

### Bootstrapping

  The entrypoint script allows for the node to be bootstrapped upon creation. This drastically reduces the time required to fully sync with the network. The start up time is increased relative to the amount of time it takes the host machine to download ~20GB of data and extract it into the data directory.

  Set the ENV variable ```BOOTSTRAP=TRUE``` to enable bootstrapping.

## Build

The following command will build the image.

```bash
docker build --rm -f Dockerfile -t docker-terra:latest .
```

## Running

### Mainnet

[![image](https://img.shields.io/badge/dynamic/json.svg?color=blue&label=Columbus-2&query=result.sync_info.latest_block_height&url=http%3A%2F%2Fcryptocurrencyswaps.com:26657%2Fstatus&prefix=Block%2B)](https://img.shields.io/badge/dynamic/json.svg?color=blue&label=Columbus-2&query=result.sync_info.latest_block_height&url=http%3A%2F%2Fcryptocurrencyswaps.com:26657%2Fstatus&prefix=Block%2B)

```sh
docker-compose up -d --build
```

### Testnet

[![image](https://img.shields.io/badge/dynamic/json.svg?color=blue&label=Gaia-13003&query=result.sync_info.latest_block_height&url=http%3A%2F%2Fdigiderivatives.com:26657%2Fstatus&prefix=Block%2B)](https://img.shields.io/badge/dynamic/json.svg?color=blue&label=Gaia-13003&query=result.sync_info.latest_block_height&url=http%3A%2F%2Fdigiderivatives.com:26657%2Fstatus&prefix=Block%2B)

```sh
docker-compose docker-compose-testnet.yml up -d --build
```

## Supervisor

The image uses Supervisor to run both terrad and gaiacli simultaneously at container runtime. Supervisor also restarts either process should it fail for some reason.

### Gaiad

After starting the container you can check the status here: [http://127.0.0.1:26657/status](http://127.0.0.1:26657/status).

or from the terminal

```bash
curl -X GET \
  http://127.0.0.1:26657/status? \
  -H 'cache-control: no-cache'
```

## Gaiacli Rest-Server

Supervisor starts the rest-server with the following command:

```bash
gaiacli rest-server --trust-node --cors * --home $GAIAD_HOME --laddr tcp://0.0.0.0:1317

```

You can verify that the rest-server is running using the following example

```bash
curl -X GET \
  http://127.0.0.1:1317/blocks/latest \
  -H 'cache-control: no-cache'
```

## NOTES

- The current SEEDS (nodes I am running and supplying here since the ones from terra/launch repo all are not working as of this update) may not be around forever so consider overriding the defaults. If the badges above have do not have block numbers for either chain that means the seed nodes are no longer with us.
- You probably should not run a validator with this setup.

## Contributing

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?)](http://makeapullrequest.com)

### Contributors

[![Keybase PGP](https://img.shields.io/keybase/pgp/ryanhendricks.svg?label=keybase&logo=keybase&logoColor=white)](https://keybase.io/ryanhendricks)

## License

![GitHub](https://img.shields.io/github/license/ryanhendricks/docker-terra.svg)
