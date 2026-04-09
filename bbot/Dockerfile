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
    7zip bash curl pandoc chromium openssl gcc git make unzip wget vim sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Copy requirements and install dependencies
COPY requirements.txt .
RUN mkdir -p /root/.config/bbot
COPY bbot.yml /root/.config/bbot/bbot.yml

RUN pip install --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r requirements.txt

# Install BBOT module dependencies (dry-run triggers dep installation)
RUN bbot --dry-run -t ciso360.net -p kitchen-sink \
    -em asn,skymem,myssl,smuggler,medusa,git_clone,github_org \
    -m ajaxpro,aspnet_bin_exposure,baddns,baddns_direct,baddns_zone,badsecrets,bucket_amazon,bucket_firebase,bucket_google,bucket_microsoft,dnscommonsrv,filedownload,git,gitlab_com,gitlab_onprem,graphql_introspection,httpx,hunt,jadx,newsletters,ntlm,oauth,reflected_parameters,retirejs,robots,securitytxt,sslcert,trufflehog,portscan,nuclei,bucket_digitalocean,bypass403,dnsbrute,dnsbrute_mutations,docker_pull,dotnetnuke,ffuf,ffuf_shortnames,fingerprintx,git_clone,gitdumper,gowitness,host_header,legba,lightfuzz,paramminer_cookies,paramminer_getparams,paramminer_headers,telerik,url_manipulation,wafw00f,wpscan,trajan \
    && rm -rf /root/.cache/pip /root/.cache/gem /root/.cache/ansible

CMD [ "bash" ]