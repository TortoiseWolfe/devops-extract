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

# Expose Storybook's default port
EXPOSE 6006

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to Storybook detection and conditional startup
CMD [ "sh", "-c", "echo -e '\\n\\n🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵' && \
echo '🚀 TKT4 - REACT TRIVIA APP 🎮' && \
echo '📚 STORYBOOK SERVICE STARTING 📚' && \
echo '🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵' && \
if [ -f package.json ]; then \
  echo '✅ Repository cloned successfully' && \
  echo '📦 Found package.json' && \
  if grep -q '\"storybook\"' package.json || [ -d '.storybook' ] || [ -d 'storybook' ]; then \
    echo '🎉 Storybook configuration detected!' && \
    echo '🌐 Storybook will be available at http://localhost:6006 when ready' && \
    npm run storybook -- --host 0.0.0.0; \
  else \
    echo -e '\\n🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡' && \
    echo '⚠️  TKT4 - REACT TRIVIA APP ⚠️' && \
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
  echo '❌ TKT4 - REACT TRIVIA APP ❌' && \
  echo '❌ ERROR: No package.json found in repository ❌' && \
  echo '🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴' && \
  echo '\\n🔎 REPO_URL setting: ${TKT4_REPO_URL}' && \
  echo '📋 Check your .env file or command line arguments' && \
  exit 1; \
fi" ]