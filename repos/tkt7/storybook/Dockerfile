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

# Install dependencies
RUN if [ -f "package.json" ]; then \
      yarn install && yarn cache clean; \
    fi

# Install Storybook (for Redwood app)
RUN if [ -f "package.json" ]; then \
      yarn add --dev @storybook/react && \
      yarn rw setup storybook; \
    fi

# Expose Storybook's default port
EXPOSE 6008

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to Storybook development mode
CMD [ "sh", "-c", "echo '📚 Starting TKT7 Storybook...' && \
if [ -f package.json ]; then \
  echo '✅ Repository cloned successfully' && \
  echo '📦 Found package.json - starting Storybook' && \
  echo '🌐 Storybook will be available at http://localhost:6008 when ready' && \
  yarn storybook --port 6008 --ci --host 0.0.0.0; \
else \
  echo '❌ ERROR: No package.json found. Please provide a valid TKT7_REPO_URL.' && \
  echo '🔎 REPO_URL setting: ${TKT7_REPO_URL}' && \
  echo '📋 Check your .env file or command line arguments' && \
  sleep infinity; \
fi" ]