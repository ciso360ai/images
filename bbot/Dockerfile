FROM python:3.14-trixie
# Testing bbot python-support-3-14 branch (replaces extractous with kreuzberg)

LABEL \
    name="CISO360AI BBOT worker" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Environment Variables
ENV DEBIAN_FRONTEND="noninteractive"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ARG TARGETARCH
ARG TARGETPLATFORM

RUN apt-get update && apt-get install -y --no-install-recommends \
    7zip bash curl pandoc chromium openssl gcc git make unzip curl wget vim sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Copy requirements and install dependencies
COPY requirements.txt .
RUN mkdir -p /root/.config/bbot
COPY bbot.yml /root/.config/bbot/bbot.yml

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Install BBOT dependencies and updates
RUN bbot --install-all-deps \
    && rm -rf /root/.cache/pip /root/.cache/gem /root/.cache/ansible

CMD [ "bash" ]