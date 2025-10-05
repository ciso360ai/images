# CISO360AI Docker Images

Multi-platform Docker images for Temporal workflow engine.

## Images

- `ghcr.io/ciso360ai/temporal-server:latest` - Temporal server with AWS RDS SSL support
- `ghcr.io/ciso360ai/temporal-ui:latest` - Temporal Web UI

## Build

```bash

# Temporal Server
cd temporal-server
docker buildx build --load --tag ciso360ai/temporal-server .

# Temporal UI
cd temporal-ui
docker buildx build --load --tag ciso360ai/temporal-ui .
```

## Debug
```bash
docker run --rm -it ciso360ai/temporal-server:latest sh
```

## SQL updates

Example default schema upgrade:
```bash
docker run --rm -it ciso360ai/temporal-server:latest temporal-sql-tool \
	--tls \
	--tls-enable-host-verification \
	--tls-cert-file <path to your client cert> \
	--tls-key-file <path to your client key> \
	--tls-ca-file <path to your CA> \
	--ep localhost -p 5432 -u temporal -pw temporal --pl postgres --db temporal update-schema -d ./schema/postgresql/v12/temporal/versioned
```

Example visibility schema upgrade:
```bash
docker run --rm -it ciso360ai/temporal-server:latest temporal-sql-tool \
	--tls \
	--tls-enable-host-verification \
	--tls-cert-file <path to your client cert> \
	--tls-key-file <path to your client key> \
	--tls-ca-file <path to your CA> \
	--ep localhost -p 5432 -u temporal -pw temporal --pl postgres --db temporal_visibility update-schema -d ./schema/postgresql/v12/visibility/versioned
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