FROM node:20-alpine3.19

# Install tini, git, and wget (for healthchecks)
RUN apk add --no-cache tini git wget

WORKDIR /app

# Use TKT56_REPO_URL from environment
ARG TKT56_REPO_URL
ENV TKT56_REPO_URL=${TKT56_REPO_URL}

# Clone repository if TKT56_REPO_URL is provided
RUN if [ -n "$TKT56_REPO_URL" ]; then \
      git clone $TKT56_REPO_URL /tmp/repo && \
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
EXPOSE 6007

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to Storybook development mode
CMD [ "sh", "-c", "echo '📚 Starting TKT56 Storybook...' && \
if [ -f package.json ]; then \
  echo '✅ Repository cloned successfully' && \
  echo '📦 Found package.json - starting Storybook' && \
  echo '🌐 Storybook will be available at http://localhost:6007 when ready' && \
  npm run storybook -- --host 0.0.0.0 --port 6007; \
else \
  echo '❌ ERROR: No package.json found. Please provide a valid TKT56_REPO_URL.' && \
  echo '🔎 REPO_URL setting: ${TKT56_REPO_URL}' && \
  echo '📋 Check your .env file or command line arguments' && \
  sleep infinity; \
fi" ]