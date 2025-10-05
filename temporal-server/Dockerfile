ARG TEMPORAL_VERSION=1.29.0

# Temporal source for build metadata
FROM temporalio/server:${TEMPORAL_VERSION} AS temporal-source

LABEL \
    name="CISO360AI Temporal Server" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Install dependencies and CA certificates for AWS RDS PostgreSQL SSL
USER root
RUN apk add --no-cache \
    ca-certificates \
    && wget -O /usr/local/share/ca-certificates/ca.crt \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
    && update-ca-certificates

# Set environment variables for AWS RDS PostgreSQL SSL
ENV POSTGRES_TLS_CERT_FILE=/usr/local/share/ca-certificates/ca.crt
ENV AWS_CA_FILE=/usr/local/share/ca-certificates/ca.crt

USER temporal

HEALTHCHECK --interval=60s --timeout=10s --start-period=60s --retries=3 \
    CMD temporal operator cluster health || exit 1
