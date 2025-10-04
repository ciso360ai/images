ARG TEMPORALUI_VERSION=2.40.1

# Temporal UI source
FROM --platform=$BUILDPLATFORM temporalio/ui:${TEMPORALUI_VERSION} AS temporal-ui-source

LABEL \
    name="CISO360AI Temporal UI" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Health check
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD curl http://localhost:8081/healthz || exit 1
