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

# Install Storybook
RUN if [ -f "package.json" ]; then \
      npx storybook@latest init --yes && \
      npm install -D @storybook/react; \
    fi

# Expose Storybook's default port
EXPOSE 6006

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to Storybook development mode
CMD [ "sh", "-c", "echo '📚 Starting TKT4 Storybook...' && \
if [ -f package.json ]; then \
  echo '✅ Repository cloned successfully' && \
  echo '📦 Found package.json - starting Storybook' && \
  echo '🌐 Storybook will be available at http://localhost:6006 when ready' && \
  npm run storybook -- --host 0.0.0.0; \
else \
  echo '❌ ERROR: No package.json found. Please provide a valid TKT4_REPO_URL.' && \
  echo '🔎 REPO_URL setting: ${TKT4_REPO_URL}' && \
  echo '📋 Check your .env file or command line arguments' && \
  sleep infinity; \
fi" ]