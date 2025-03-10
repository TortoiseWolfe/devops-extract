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

# Expose Storybook's default port
EXPOSE 6007

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to Storybook detection and conditional startup
CMD [ "sh", "-c", "echo -e '\\n\\n🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢' && \
echo '🚀 TKT56 - ISSUE TRACKER APP 📋' && \
echo '📚 STORYBOOK SERVICE STARTING 📚' && \
echo '🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢' && \
if [ -f package.json ]; then \
  echo '✅ Repository cloned successfully' && \
  echo '📦 Found package.json' && \
  if grep -q '\"storybook\"' package.json || [ -d '.storybook' ] || [ -d 'storybook' ]; then \
    echo '🎉 Storybook configuration detected!' && \
    echo '🌐 Storybook will be available at http://localhost:6007 when ready' && \
    npm run storybook -- --host 0.0.0.0 --port 6007; \
  else \
    echo -e '\\n🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡' && \
    echo '⚠️  TKT56 - ISSUE TRACKER APP ⚠️' && \
    echo '⚠️  NO STORYBOOK CONFIGURATION FOUND ⚠️' && \
    echo '🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡' && \
    echo '\\n💡 TIP: If you want to use Storybook with this project:' && \
    echo '  1. Add Storybook to your project with: npx storybook@latest init' && \
    echo '  2. Commit the changes to your repository' && \
    echo '  3. Restart this container' && \
    echo '\\n✅ Storybook container will exit gracefully.\\n' && \
    exit 0; \
  fi; \
else \
  echo -e '\\n🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴' && \
  echo '❌ TKT56 - ISSUE TRACKER APP ❌' && \
  echo '❌ ERROR: No package.json found in repository ❌' && \
  echo '🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴' && \
  echo '\\n🔎 REPO_URL setting: ${TKT56_REPO_URL}' && \
  echo '📋 Check your .env file or command line arguments' && \
  exit 1; \
fi" ]