FROM node:20-alpine3.19

# Install tini, git, and wget (for healthchecks)
RUN apk add --no-cache tini git wget

WORKDIR /app

# Use TKT7_REPO_URL from environment
ARG TKT7_REPO_URL
ENV TKT7_REPO_URL=${TKT7_REPO_URL}

# Clone repository if TKT7_REPO_URL is provided
RUN if [ -n "$TKT7_REPO_URL" ]; then \
      git clone $TKT7_REPO_URL /tmp/repo && \
      cp -r /tmp/repo/* /app/ && \
      rm -rf /tmp/repo; \
    fi

# Install dependencies (for Redwood app)
RUN if [ -f "package.json" ]; then \
      yarn install && yarn cache clean; \
    fi

# Expose Redwood's default port
EXPOSE 8910

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to development mode with host flag to expose on all interfaces
CMD [ "sh", "-c", "echo '🚀 Starting TKT7 Redwood Blog App...' && \
if [ -f package.json ]; then \
  echo '✅ Repository cloned successfully' && \
  echo '📦 Found package.json - starting Redwood application' && \
  echo '🌐 App will be available at http://tkt7.localhost when ready' && \
  echo '📊 Traefik Dashboard: http://traefik.localhost:8081' && \
  echo '📂 REPO: https://github.com/TortoiseWolfe/redwoodblog_Mar_2nd_4pm' && \
  yarn rw dev --fwd=\"--host 0.0.0.0\"; \
else \
  echo '❌ ERROR: No package.json found. Please provide a valid TKT7_REPO_URL.' && \
  echo '🔎 REPO_URL setting: ${TKT7_REPO_URL}' && \
  echo '📋 Check your .env file or command line arguments' && \
  sleep infinity; \
fi" ]