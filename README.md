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

## Python Dependency Management (uv)

The Python images (`backend-base`, `bbot`) use [uv](https://docs.astral.sh/uv/)
for dependency management. Each image has its own `pyproject.toml` + `uv.lock`
and pins Python via `.python-version`. Lockfiles are the single source of
truth — installs in the Dockerfiles run `uv sync --frozen --no-install-project`,
so reproducible builds require committing the lockfile after any change.

Install uv locally (see [docs](https://docs.astral.sh/uv/getting-started/installation/)):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Common workflows

Run from the image directory (e.g. `cd backend-base/` or `cd bbot/`):

```bash
# Resolve and install everything from the lockfile (no source install)
uv sync --frozen --no-install-project

# Add a new runtime dependency (updates pyproject.toml + uv.lock)
uv add "somepkg>=1.2"

# Remove a dependency
uv remove somepkg

# Bump a single package to its latest allowed version
uv lock --upgrade-package fastapi

# Refresh the entire lockfile against current pyproject constraints
uv lock --upgrade

# Inspect the resolved tree
uv tree
```

After any `uv add`/`uv remove`/`uv lock` change, rebuild the image to verify:

```bash
docker buildx build --load --tag ghcr.io/ciso360ai/backend-base:test backend-base/
```

### Why no `requirements.txt`?

The Dockerfiles install dependencies directly from `uv.lock` via `uv sync`,
so a generated `requirements.txt` is no longer needed. Dependabot scans the
`uv` ecosystem (see `.github/dependabot.yml`) and opens PRs against
`pyproject.toml` / `uv.lock` directly. If you ever need a flat
pip-compatible export (e.g. for an external scanner), generate it on demand:

```bash
uv export --frozen --no-emit-project --no-hashes -o requirements.txt
```
