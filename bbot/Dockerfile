FROM python:3.14-trixie
# Pinned to a specific bbot dev commit for reproducibility (includes extractous->kreuzberg change)

LABEL \
    name="CISO360AI BBOT worker" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Environment Variables
ENV DEBIAN_FRONTEND="noninteractive"
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    7zip bash curl pandoc chromium openssl gcc git make unzip wget vim sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Install uv from the official static-binary image (pinned)
COPY --from=ghcr.io/astral-sh/uv:0.11.24 /uv /uvx /usr/local/bin/

# Copy lockfile + project metadata
COPY pyproject.toml uv.lock .python-version ./

# Pre-place bbot config so bbot's first run uses it
RUN mkdir -p /root/.config/bbot
COPY bbot.yml /root/.config/bbot/bbot.yml

# Install Python dependencies into the system environment from the lockfile.
# UV_PYTHON_DOWNLOADS=0 forces uv to use the base image's interpreter at
# /usr/local instead of downloading a managed CPython.
ENV UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/usr/local \
    UV_PYTHON_DOWNLOADS=0
RUN uv sync --frozen --no-install-project

# Install BBOT module dependencies (dry-run triggers dep installation)
RUN bbot --dry-run -t ciso360.net -p kitchen-sink \
    -c interactsh_disable=true \
    -em asn,skymem,myssl,medusa,git_clone,github_org,crt,crt_db,trufflehog \
    -m ajaxpro,aspnet_bin_exposure,baddns,baddns_direct,baddns_zone,badsecrets,bucket_amazon,bucket_digitalocean,bucket_firebase,bucket_google,bucket_hetzner,bucket_microsoft,bypass403,dnscommonsrv,dotnetnuke,dnsbrute,dnsbrute_mutations,docker_pull,filedownload,fingerprintx,generic_ssrf,git,gitdumper,gitlab_com,gitlab_onprem,gowitness,graphql_introspection,host_header,http,hunt,iis_shortnames,jadx,legba,lightfuzz,newsletters,ntlm,nuclei,oauth,paramminer_cookies,paramminer_getparams,paramminer_headers,portscan,reflected_parameters,retirejs,robots,securitytxt,sslcert,telerik,url_manipulation,wafw00f,webbrute,webbrute_shortnames,wpscan,trajan \
    && rm -rf /root/.cache/pip /root/.cache/gem /root/.cache/ansible

CMD [ "bash" ]