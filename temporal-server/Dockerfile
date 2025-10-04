ARG ALPINE_VERSION=3.22
ARG TEMPORAL_VERSION=1.29.0

# Temporal source for build metadata
FROM --platform=$BUILDPLATFORM temporalio/auto-setup:${TEMPORAL_VERSION} AS temporal-source

# Base image
FROM alpine:${ALPINE_VERSION}

LABEL \
    name="CISO360AI Temporal Server" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

ARG TARGETARCH
ARG TARGETPLATFORM

# Install dependencies and CA certificates for AWS RDS PostgreSQL SSL
RUN apk add --no-cache \
    bash \
    ca-certificates \
    curl \
    tini \
    tzdata \
    && wget -O /usr/local/share/ca-certificates/ca.crt \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
    && update-ca-certificates

# Set environment variables for AWS RDS PostgreSQL SSL
ENV POSTGRES_TLS_CERT_FILE=/usr/local/share/ca-certificates/ca.crt
ENV AWS_CA_FILE=/usr/local/share/ca-certificates/ca.crt

COPY --from=temporal-source /usr/local/bin/temporal /usr/local/bin/temporal
COPY --from=temporal-source /usr/local/bin/temporal-server /usr/local/bin/temporal-server
COPY --from=temporal-source /etc/temporal /etc/temporal

# Create user and directories
RUN addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal && \
    chown -R temporal:temporal /etc/temporal && \
    chmod +x /usr/local/bin/temporal*

USER temporal
WORKDIR /etc/temporal

ENV TEMPORAL_HOME=/etc/temporal
EXPOSE 6933 6934 6935 6939 7233 7234 7235 7239

HEALTHCHECK --interval=60s --timeout=10s --start-period=60s --retries=3 \
    CMD temporal operator cluster health || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/etc/temporal/entrypoint.sh"]
