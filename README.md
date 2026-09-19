# CISO360AI Docker Images

Multi-platform Docker image for [CISO360AI](https://ciso360.ai)

## Image

- `ghcr.io/ciso360ai/bbot:latest` — BBOT scan worker

Published on tag (`v*`) and rebuilt weekly. It stays public so a remote or
self-hosted scan worker can pull it without credentials, and because BBOT is
AGPL-3.0 — the pinned fork is [ciso360ai/bbot](https://github.com/ciso360ai/bbot).

Every other CISO360AI service image is built in the repository that deploys it.

## Build

```bash
docker buildx build --load -t ghcr.io/ciso360ai/bbot:latest bbot/
```

## Debug

```bash
docker run --rm -it ghcr.io/ciso360ai/bbot:latest bash
```

## Pull

```bash
docker pull ghcr.io/ciso360ai/bbot:latest
```

## Version update

The BBOT version is pinned to a concrete commit under `[tool.uv.sources]` in
`bbot/pyproject.toml`. Bumping that rev is the highest-risk change here: it
changes what the scanner finds, so verify a scan end to end afterwards.

## Python dependency management (uv)

`bbot` uses [uv](https://docs.astral.sh/uv/). It has its own `pyproject.toml` +
`uv.lock` and pins Python via `.python-version`. The lockfile is the single
source of truth — the Dockerfile runs `uv sync --frozen --no-install-project`,
so a reproducible build requires committing the lockfile after any change.

Install uv locally (see [docs](https://docs.astral.sh/uv/getting-started/installation/)):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Common workflows

Run from `bbot/`:

```bash
# Resolve and install everything from the lockfile (no source install)
uv sync --frozen --no-install-project

# Add a new runtime dependency (updates pyproject.toml + uv.lock)
uv add "somepkg>=1.2"

# Remove a dependency
uv remove somepkg

# Bump a single package to its latest allowed version
uv lock --upgrade-package httpx2

# Refresh the entire lockfile against current pyproject constraints
uv lock --upgrade

# Inspect the resolved tree
uv tree
```

After any `uv add`/`uv remove`/`uv lock` change, rebuild the image to verify:

```bash
docker buildx build --load --tag ghcr.io/ciso360ai/bbot:test bbot/
```

### Why no `requirements.txt`?

The Dockerfile installs dependencies directly from `uv.lock` via `uv sync`, so a
generated `requirements.txt` is not needed. Dependabot scans the `uv` ecosystem
(see `.github/dependabot.yml`) and opens PRs against `pyproject.toml` /
`uv.lock` directly. If you ever need a flat pip-compatible export (e.g. for an
external scanner), generate it on demand:

```bash
uv export --frozen --no-emit-project --no-hashes -o requirements.txt
```
