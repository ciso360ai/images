# Check: https://github.com/temporalio/temporal/releases
ARG TEMPORAL_VERSION=1.29.3

# Temporal source for build metadata
FROM temporalio/auto-setup:1.29.3 AS temporal-source

# Base image
FROM alpine:3.22

# Re-declare ARGs after FROM to make them available in this stage
ARG TEMPORAL_VERSION
ARG TARGETPLATFORM

LABEL \
    name="CISO360AI Temporal Server" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Install dependencies and CA certificates for AWS RDS PostgreSQL SSL
RUN apk add --no-cache \
    bash \
    curl \
    ca-certificates && \
    wget -O /usr/local/share/ca-certificates/ca.crt \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem && \
    update-ca-certificates && \
    mkdir -p /etc/temporal

# Set environment variables for AWS RDS Postgres SSL
ENV POSTGRES_TLS_CERT_FILE=/usr/local/share/ca-certificates/ca.crt
ENV AWS_CA_FILE=/usr/local/share/ca-certificates/ca.crt

WORKDIR /etc/temporal

# Download and install specific AMD64 versions
RUN \
  if [ "$TARGETPLATFORM" = 'linux/amd64' ]; then \
    wget https://github.com/temporalio/temporal/releases/download/v${TEMPORAL_VERSION}/temporal_${TEMPORAL_VERSION}_linux_amd64.tar.gz \
    && tar -xzf temporal_${TEMPORAL_VERSION}_linux_amd64.tar.gz \
    && mv temporal-* /usr/local/bin \
    && rm -rf temporal-* \
    && rm -rf *.tar.gz \
  ; fi

# Download and install specific ARM64 versions
RUN \
  if [ "$TARGETPLATFORM" = 'linux/arm64' ]; then \
    wget https://github.com/temporalio/temporal/releases/download/v${TEMPORAL_VERSION}/temporal_${TEMPORAL_VERSION}_linux_arm64.tar.gz \
    && tar -xzf temporal_${TEMPORAL_VERSION}_linux_arm64.tar.gz \
    && mv temporal-* /usr/local/bin \
    && rm -rf temporal-* \
    && rm -rf *.tar.gz \
  ; fi

COPY --from=temporal-source /etc/temporal/schema /etc/temporal/schema
COPY --from=temporal-source /usr/local/bin/temporal /usr/local/bin/temporal
COPY docker.yaml /etc/temporal/config/docker.yaml
COPY entrypoint.sh /etc/temporal/entrypoint.sh

# Create user and directories
RUN addgroup -g 1000 temporal && \
    adduser -u 1000 -G temporal -D temporal && \
    chown -R temporal:temporal /etc/temporal && \
    chmod +x /usr/local/bin/temporal* && \
    chmod +x /etc/temporal/entrypoint.sh

USER temporal

ENV TEMPORAL_HOME=/etc/temporal
EXPOSE 6933 6934 6935 6939 7233 7234 7235 7239

HEALTHCHECK --interval=60s --timeout=10s --start-period=60s --retries=3 \
    CMD temporal operator cluster health || exit 1

ENTRYPOINT ["/etc/temporal/entrypoint.sh"]