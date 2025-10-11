# CISO360AI Docker Images

Multi-platform Docker images [CISO360AI](https://ciso360.ai)

## Images

- `ghcr.io/ciso360ai/backend-base:latest` - Backend base
- `ghcr.io/ciso360ai/bbot:latest` - BBOT worker
- `ghcr.io/ciso360ai/temporal-server:latest` - Temporal server with AWS RDS SSL support
- `ghcr.io/ciso360ai/temporal-ui:latest` - Temporal Web UI
- `ghcr.io/ciso360ai/zitadel:latest` - Zitadel identity provider with AWS RDS SSL support

## Build

```bash

# Backend Base
cd backend-base
docker buildx build --load --tag ghcr.io/ciso360ai/backend-base:latest .

# Temporal Server
cd temporal-server
docker buildx build --load --tag ghcr.io/ciso360ai/temporal-server:latest .

# Temporal UI
cd temporal-ui
docker buildx build --load --tag ghcr.io/ciso360ai/temporal-ui:latest .

# BBOT
cd bbot
docker buildx build --load --tag ghcr.io/ciso360ai/bbot:latest .

# Zitadel
cd zitadel
docker buildx build --load --tag ghcr.io/ciso360ai/zitadel:latest .

```

## Debug
```bash
docker run --rm -it ghcr.io/ciso360ai/backend-base:latest bash

docker run --rm -it ghcr.io/ciso360ai/temporal-server:latest sh

docker run --rm -it ghcr.io/ciso360ai/temporal-ui:latest sh

docker run --rm -it ghcr.io/ciso360ai/bbot:latest bash

docker run --rm -it ghcr.io/ciso360ai/zitadel:latest sh

```

## Pull

```bash
docker pull ghcr.io/ciso360ai/backend-base:latest
docker pull ghcr.io/ciso360ai/temporal-server:latest
docker pull ghcr.io/ciso360ai/temporal-ui:latest
docker pull ghcr.io/ciso360ai/bbot:latest
docker pull ghcr.io/ciso360ai/zitadel:latest
```

## Version Update

Edit Dockerfile ARGs:
- `temporal-server/Dockerfile`: `TEMPORAL_VERSION=X.Y.Z`
- `temporal-ui/Dockerfile`: `TEMPORALUI_VERSION=X.Y.Z`
- `zitadel/Dockerfile`: `ZITADEL_VERSION=X.Y.Z`