FROM python:3.14-trixie

LABEL \
    name="CISO360AI Backend Base" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Environment Variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv from the official static-binary image (pinned)
COPY --from=ghcr.io/astral-sh/uv:0.11.29 /uv /uvx /usr/local/bin/

# Copy lockfile + project metadata
COPY pyproject.toml uv.lock .python-version ./

# Install Python dependencies into the system environment from the lockfile.
# UV_LINK_MODE=copy avoids hardlink failures when caches and /usr/local
# live on different filesystems (common in BuildKit).
# UV_PYTHON_DOWNLOADS=0 forces uv to use the base image's interpreter at
# /usr/local instead of downloading a managed CPython.
ENV UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/usr/local \
    UV_PYTHON_DOWNLOADS=0
RUN uv sync --frozen --no-install-project

CMD [ "bash" ]