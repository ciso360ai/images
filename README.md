# CISO360AI Docker Images

Multi-platform Docker images for Temporal workflow engine.

## Images

- `ghcr.io/ciso360ai/temporal-server:latest` - Temporal server with AWS RDS SSL support
- `ghcr.io/ciso360ai/temporal-ui:latest` - Temporal Web UI

## Build Multi-Platform

```bash
# Create buildx builder (first time only)
docker buildx create --name multiplatform --use

# Temporal Server
cd temporal-server
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/ciso360ai/temporal-server:latest \
  --push .

# Temporal UI
cd temporal-ui
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/ciso360ai/temporal-ui:latest \
  --push .
```

## Build Local

```bash
# Temporal Server
docker buildx build -t temporal-server:local temporal-server/

# Temporal UI
docker buildx build -t temporal-ui:local temporal-ui/
```

## Pull

```bash
docker pull ghcr.io/ciso360ai/temporal-server:latest
docker pull ghcr.io/ciso360ai/temporal-ui:latest
```

## Version Update

Edit Dockerfile ARGs:
- `temporal-server/Dockerfile`: `TEMPORAL_VERSION=X.Y.Z`
- `temporal-ui/Dockerfile`: `TEMPORALUI_VERSION=X.Y.Z`