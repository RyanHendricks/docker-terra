# Docker-Terra

Dockerized Terra Node with Optional Bootstrap for Fast Syncing

* * *

[![CircleCI (all branches)](https://img.shields.io/circleci/build/github/RyanHendricks/docker-terra?token=e4ff41141d22bc71c6b2ad5118fd202d98dfb2dd&label=build&logo=circleci&logoColor=white)](https://circleci.com/gh/RyanHendricks/docker-terra)
[![Codacy grade](https://img.shields.io/codacy/grade/049014a16fd948edaaa0773c246517e9.svg?logo=codacy)](https://www.codacy.com?utm_source=github.com&utm_medium=referral&utm_content=RyanHendricks/docker-terra&utm_campaign=Badge_Grade)

[![MicroBadger Version](https://images.microbadger.com/badges/version/ryanhendricks/docker-terra.svg)](https://microbadger.com/images/ryanhendricks/docker-terra)
[![Docker Pulls](https://img.shields.io/docker/pulls/ryanhendricks/docker-terra.svg?logo=docker&logoColor=white)](https://hub.docker.com/r/ryanhendricks/docker-terra)
[![MicroBadger Layers (latest)](https://img.shields.io/microbadger/layers/ryanhendricks/docker-terra/latest.svg?logo=docker&logoColor=white)](https://microbadger.com/images/ryanhendricks/docker-terra)

* * *

## Prerequisites

-   Docker
-   Docker-Compose (optional)

## Quick Start

The image can be run without any configuration and defaults to mainnet

```bash

docker  run --rm -it -P --env SEEDS='447ba60df6fdc2466e1ab4c328e100d6bc5765f8@seed-only.terra-columbus-3.bas.network:26656,6be0856f6365559fdc2e9e97a07d609f754632b0@terra-columbus-3-seed.nodes.polychainlabs.com:26656,b416f0b04e2c71b8d76f993468352030e2dcf2a9@public-seed-node.columbus.certus.one:26656,87048bf71526fb92d73733ba3ddb79b7a83ca11e@public-seed.terra.dev:26656,b5205baf1d52b6f91afb0da7d7b33dcebc71755f@public-seed2.terra.dev:26656,535222fdb795df6653934f22b8e5f16fdfacc9f6@seed.terra.de-light.io:26656,bae08cc880c20aeda68a5a890a71a9b44ac73cb4@terra-seed-eu.chorus.one:28657,925ecc3de9e2ac65a203beb2333ced1a00c135ed@terra-seed-us.chorus.one:28657' ryanhendricks/docker-terra:latest
# Feel free to use an alternate seed node although without one the node will have issues starting

```

## Configuration

### Config.toml Parameters

-   The config.toml is created dynamically when starting the container.
-   All parameters specified in the standard config.toml file can be set using environmental variables with the same name as the config parameter but in all caps. See [entrypoint script](./scripts/entrypoint.sh) for more details.
-   If left unset the default values will be used.
-   Parameters can be set directly by modifying the config.toml portion of ./scripts/entrypoint.sh if you are cloning and building the image yourself.

### Environment Variables

```bash
# EXAMPLES

MONIKER=nonamenode
CHAIN_ID=columbus-3
GENESIS_URL=https://columbus-genesis.s3-ap-northeast-1.amazonaws.com/genesis.json
SEEDS=447ba60df6fdc2466e1ab4c328e100d6bc5765f8@seed-only.terra-columbus-3.bas.network:26656,6be0856f6365559fdc2e9e97a07d609f754632b0@terra-columbus-3-seed.nodes.polychainlabs.com:26656,b416f0b04e2c71b8d76f993468352030e2dcf2a9@public-seed-node.columbus.certus.one:26656,87048bf71526fb92d73733ba3ddb79b7a83ca11e@public-seed.terra.dev:26656,b5205baf1d52b6f91afb0da7d7b33dcebc71755f@public-seed2.terra.dev:26656,535222fdb795df6653934f22b8e5f16fdfacc9f6@seed.terra.de-light.io:26656,bae08cc880c20aeda68a5a890a71a9b44ac73cb4@terra-seed-eu.chorus.one:28657,925ecc3de9e2ac65a203beb2333ced1a00c135ed@terra-seed-us.chorus.one:28657
PERSISTENT_PEERS=e6325ba7c490ba371135c9f3fcead66da1bd8cf1@terra-sentry01.dokia.cloud:26656,dba5defd7b120937da37aea7f37d06870637558d@terra-sentry02.dokia.cloud:26656,eb4ce12133c450ba6665e06309570ea2843e21d8@167.86.104.33:26656,7277be5ce17d60cf26c92a7cafbb9fc7da7f2be5@51.38.103.128:26656,1cb3e13efe7ca25fb68249169a15e85e53c3b3e9@terra-main.peer.nodeateam.kr:26656,46bc5183ef3b6ea9ffa84df16d6a5aa4a642427a@node.terra.forbole.com:26656,


```

You can set ENV variables either in a docker-compose file or in the docker run command if running the container directly. If left unchanged they will default to the standard value except for the following:

-   MONIKER
    -   defaults to "nonamenode"
-   CHAIN_ID
    -   defaults to columbus-3
-   GENESIS_URL
    -   defaults to columbus-3 github [genesis file url](https://columbus-genesis.s3-ap-northeast-1.amazonaws.com/genesis.json)

### Bootstrapping

  The entrypoint script allows for the node to be bootstrapped upon creation. This drastically reduces the time required to fully sync with the network. The start up time is increased relative to the amount of time it takes the host machine to download ~20GB of data and extract it into the data directory.

  Set the ENV variable `BOOTSTRAP=TRUE` to enable bootstrapping.

## Build

The following command will build the image.

```bash
docker build --rm -f Dockerfile -t docker-terra:latest .
```

## Running

### Mainnet

```sh
docker-compose up -d --build
```

### Testnet

```sh
docker-compose docker-compose-testnet.yml up -d --build
```

## Supervisor

The image uses Supervisor to run both terrad and gaiacli simultaneously at container runtime. Supervisor also restarts either process should it fail for some reason.

### Gaiad

After starting the container you can check the status here: <http://127.0.0.1:26657/status>.

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

-   The current SEEDS (nodes I am running and supplying here since the ones from terra/launch repo all are not working as of this update) may not be around forever so consider overriding the defaults. If the badges above have do not have block numbers for either chain that means the seed nodes are no longer with us.
-   You probably should not run a validator with this setup.

## Contributing

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?)](http://makeapullrequest.com)

### Contributors

[![Keybase PGP](https://img.shields.io/keybase/pgp/ryanhendricks.svg?label=keybase&logo=keybase&logoColor=white)](https://keybase.io/ryanhendricks)

## License

![GitHub](https://img.shields.io/github/license/ryanhendricks/docker-terra.svg)
