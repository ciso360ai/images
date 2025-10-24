ARG ZITADEL_VERSION=4.4.0-debug

# Custom Zitadel image with AWS RDS SSL support
FROM ghcr.io/zitadel/zitadel:v${ZITADEL_VERSION}

LABEL \
    name="CISO360AI ZITADEL" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Switch to root to install packages
USER root

# Install required packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && curl -o /usr/local/share/ca-certificates/aws-rds-global-bundle.crt \
    https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
    && update-ca-certificates \
    && apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to zitadel user
USER zitadel

# Set environment variables for AWS RDS PostgreSQL SSL
ENV PGSSLROOTCERT=/usr/local/share/ca-certificates/aws-rds-global-bundle.crt
ENV SSL_CERT_FILE=/usr/local/share/ca-certificates/aws-rds-global-bundle.crt
ENV ZITADEL_DATABASE_POSTGRES_USER_SSL_ROOTCERT=/usr/local/share/ca-certificates/aws-rds-global-bundle.crt
ENV ZITADEL_DATABASE_POSTGRES_ADMIN_SSL_ROOTCERT=/usr/local/share/ca-certificates/aws-rds-global-bundle.crt

# Health check
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -I http://localhost:8080/debug/ready || exit 1
