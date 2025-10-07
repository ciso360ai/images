FROM python:3.13-trixie

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
    7zip bash curl gcc git libssl-dev make openssl unzip wget which tar sudo xz-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Copy requirements and install dependencies
COPY requirements.txt .
RUN mkdir -p /root/.config/bbot
COPY bbot.yml /root/.config/bbot/bbot.yml

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Install BBOT dependencies
RUN all_modules="$(bbot -s --help | grep -i "Modules to enable" | sed 's/^.*Modules to enable. Choices: //g')" ; bbot --allow-deadly -m $all_modules --dry-run

RUN /tmp/.bbot/tools/nuclei -update-template-dir /tmp/.bbot/tools/nuclei-templates -update-templates

CMD [ "bash" ]