# CISO360AI Docker Images

Multi-platform Docker images for Temporal workflow engine.

## Images

- `ghcr.io/ciso360ai/temporal-server:latest` - Temporal server with AWS RDS SSL support
- `ghcr.io/ciso360ai/temporal-ui:latest` - Temporal Web UI
- `ghcr.io/ciso360ai/bbot:latest` - BBOT worker

## Build

```bash

# Temporal Server
cd temporal-server
docker buildx build --load --tag ciso360ai/temporal-server .

# Temporal UI
cd temporal-ui
docker buildx build --load --tag ciso360ai/temporal-ui .

# BBOT
cd bbot
docker buildx build --load --tag ciso360ai/bbot .

```

## Debug
```bash
docker run --rm -it ciso360ai/temporal-server:latest sh

docker run --rm -it ciso360ai/bbot:latest

```

## Pull

```bash
docker pull ghcr.io/ciso360ai/temporal-server:latest
docker pull ghcr.io/ciso360ai/temporal-ui:latest
docker pull ghcr.io/ciso360ai/bbot:latest
```

## Version Update

Edit Dockerfile ARGs:
- `temporal-server/Dockerfile`: `TEMPORAL_VERSION=X.Y.Z`
- `temporal-ui/Dockerfile`: `TEMPORALUI_VERSION=X.Y.Z`