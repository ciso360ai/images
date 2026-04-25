FROM python:3.14-trixie

LABEL \
    name="CISO360AI Backend Base" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Environment Variables
ENV DEBIAN_FRONTEND="noninteractive"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ARG TARGETARCH
ARG TARGETPLATFORM

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv from the official static-binary image (pinned)
COPY --from=ghcr.io/astral-sh/uv:0.11.7 /uv /uvx /usr/local/bin/

# Copy lockfile + project metadata
COPY pyproject.toml uv.lock .python-version ./

# Install Python dependencies into the system environment from the lockfile.
# UV_LINK_MODE=copy avoids hardlink failures when caches and /usr/local
# live on different filesystems (common in BuildKit).
ENV UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/usr/local
RUN uv sync --frozen --no-install-project

CMD [ "bash" ]