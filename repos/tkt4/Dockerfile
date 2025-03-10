FROM node:20-alpine3.19

# Install tini, git, and wget (for healthchecks)
RUN apk add --no-cache tini git wget

WORKDIR /app

# Use TKT4_REPO_URL from environment
ARG TKT4_REPO_URL
ENV TKT4_REPO_URL=${TKT4_REPO_URL}

# Clone repository if TKT4_REPO_URL is provided
RUN if [ -n "$TKT4_REPO_URL" ]; then \
      git clone $TKT4_REPO_URL /tmp/repo && \
      cp -r /tmp/repo/* /app/ && \
      rm -rf /tmp/repo; \
    fi

# Install dependencies
RUN if [ -f "package.json" ]; then \
      npm install && npm cache clean --force; \
    fi

# Expose Vite's default port
EXPOSE 5173

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to development mode with host flag to expose on all interfaces
CMD [ "sh", "-c", "echo '🚀 Starting TKT4 Trivia App...' && \
if [ -f package.json ]; then \
  echo '✅ Repository cloned successfully' && \
  echo '📦 Found package.json - starting React application' && \
  echo '🌐 App will be available at http://tkt4.localhost when ready' && \
  echo '📊 Traefik Dashboard: http://traefik.localhost:8081' && \
  echo "📂 REPO: ${TKT4_REPO_URL}" && \
  npm run dev -- --host 0.0.0.0; \
else \
  echo '❌ ERROR: No package.json found. Please provide a valid TKT4_REPO_URL.' && \
  echo '🔎 REPO_URL setting: ${TKT4_REPO_URL}' && \
  echo '📋 Check your .env file or command line arguments' && \
  sleep infinity; \
fi" ]