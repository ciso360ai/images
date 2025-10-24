ARG TEMPORALUI_VERSION=2.42.1

# Use Temporal UI as base image (proper platform targeting)
FROM temporalio/ui:${TEMPORALUI_VERSION}

LABEL \
    name="CISO360AI Temporal UI" \
    author="CISO360AI <office@CISO360.AI>" \
    description="Your All-round Cyber-Intelligent Sidekick"

# Set environment variables
ENV TEMPORAL_UI_PORT=8081
# Expose the default port
EXPOSE 8081

# Health check
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD curl http://localhost:8081/healthz || exit 1
