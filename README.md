# Quickstart

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/portward/quickstart/ci.yaml?style=flat-square)](https://github.com/portward/quickstart/actions/workflows/ci.yaml)
[![built with nix](https://img.shields.io/badge/builtwith-nix-7d81f7?style=flat-square)](https://builtwithnix.org)

**Quickstart guide and demo for Portward.**

> [!WARNING]
> **Project is under development. Backwards compatibility is not guaranteed.**

## Prerequisites

- Docker (with Compose)
- A registry client:
    - [skopeo](https://github.com/containers/skopeo)
    - [regclient](https://github.com/regclient/regclient)
- [just](https://github.com/casey/just) _optional_

Download an image archive (for example `alpine`) that you can push to registries.

Using `skopeo`:

```shell
mkdir -p var/
skopeo --insecure-policy copy -a docker://docker.io/library/alpine:latest oci-archive://$PWD/var/alpine.tar.gz
```

Using `regctl`:

```shell
mkdir -p var/
regctl image export docker.io/library/alpine:latest $PWD/varalpine.tar.gz
```

**For an optimal developer experience, it is recommended to install [Nix](https://nixos.org/download.html) and [direnv](https://direnv.net/docs/installation.html).**

## Usage

Create a `config.yaml` file:

```shell
cp config.example.yaml config.yaml
```

> [!IMPORTANT]
> Restart `portward` using `docker compose restart portward` if you change anything in `config.yaml`.

Start Docker Compose:

```shell
docker compose up -d
```

> [!NOTE]
> Check the `docker-compose.yaml` file for ports and make sure they are not in use.

Make sure containers are started:

```shell
docker compose ps
```

Decide which registry you want to use:

- [Distribution](https://github.com/distribution/distribution): `export REGISTRY=127.0.0.1:5000`
- [Zot](https://github.com/project-zot/zot): `export REGISTRY=127.0.0.1:5001`

Log in to the registry as **admin**:

```shell
# Using skopeo
skopeo login --tls-verify=false -u admin -p password $REGISTRY

# Using regctl
regctl registry set --tls=disabled $REGISTRY
regctl registry login -u user -p password $REGISTRY
```

Push images to the registry:

```shell
# Using skopeo
skopeo --insecure-policy copy --dest-tls-verify=false -a oci-archive://$PWD/var/alpine.tar.gz docker://$REGISTRY/alpine
skopeo --insecure-policy copy --dest-tls-verify=false -a oci-archive://$PWD/var/alpine.tar.gz docker://$REGISTRY/product1/alpine

# Using regctl
regctl image import $REGISTRY/alpine $PWD/var/alpine.tar.gz
regctl image import $REGISTRY/product1/alpine $PWD/var/alpine.tar.gz
```

Logout as **admin** from the registry:

```shell
# Using skopeo
skopeo logout $REGISTRY

# Using regctl
regctl registry logout $REGISTRY
```

Log in to the registry as **user**:

```shell
# Using skopeo
skopeo login --tls-verify=false -u user -p password $REGISTRY

# Using regctl
regctl registry set --tls=disabled $REGISTRY
regctl registry login -u user -p password $REGISTRY
```

Inspect and pull images in the registry:

```shell
# Using skopeo
skopeo --insecure-policy --override-os linux --override-arch amd64 inspect --tls-verify=false docker://$REGISTRY/alpine
skopeo --insecure-policy copy --src-tls-verify=false -a docker://$REGISTRY/alpine oci-archive:///dev/null

# Using regctl
regctl image inspect $REGISTRY/alpine
regctl image export $REGISTRY/alpine /dev/null
```

Try pulling an image **user** does not have access to:


```shell
# Using skopeo
skopeo --insecure-policy --override-os linux --override-arch amd64 inspect --tls-verify=false docker://$REGISTRY/product1/alpine
skopeo --insecure-policy copy --src-tls-verify=false -a docker://$REGISTRY/product1/alpine oci-archive:///dev/null

# Using regctl
regctl image inspect $REGISTRY/product1/alpine
regctl image export $REGISTRY/product1/alpine /dev/null
```

Logout as **user** from the registry:

```shell
# Using skopeo
skopeo logout $REGISTRY

# Using regctl
regctl registry logout $REGISTRY
```

## Cleanup

Tear down the Docker Compose setup:

```shell
docker compose down -v
```

Remove files:

```shell
rm -rf var/
```

## License

The project is licensed under the [MIT License](LICENSE).
