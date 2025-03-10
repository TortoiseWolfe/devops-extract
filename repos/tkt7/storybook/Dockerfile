FROM node:20-alpine3.19

# Install tini, git, wget, and build dependencies for Redwood
RUN apk add --no-cache tini git wget python3 make g++ bash

# Enable corepack for Yarn 4.x support
RUN corepack enable && corepack prepare yarn@4.6.0 --activate

# Create .yarnrc.yml to use node-modules linker (more compatible)
RUN echo 'nodeLinker: node-modules' > /root/.yarnrc.yml

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

# Install dependencies - handled in CMD to deal with Yarn version issues

# Expose Storybook's default port
EXPOSE 6008

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to Storybook detection and conditional startup
CMD [ "sh", "-c", "echo -e '\\n\\n🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣' && \
echo '🚀 TKT7 - REDWOOD BLOG APP 📝' && \
echo '📚 STORYBOOK SERVICE STARTING 📚' && \
echo '🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣🟣' && \
if [ -f package.json ]; then \
  echo '✅ Repository cloned successfully' && \
  echo '📦 Found package.json' && \
  
  # Handle dependencies for Yarn if needed
  if grep -q '\"packageManager\":' package.json; then \
    echo '🧶 Enabling Corepack for Yarn version management' && \
    corepack enable && yarn -v; \
  fi && \
  
  # Install dependencies if needed
  if [ ! -d 'node_modules' ]; then \
    echo '📦 Installing dependencies...' && \
    yarn install || npm install; \
  fi && \
  
  # Check for Storybook configuration
  if grep -q '\"storybook\"' package.json || [ -d '.storybook' ] || [ -d 'storybook' ] || [ -d 'web/.storybook' ]; then \
    echo '🎉 Storybook configuration detected!' && \
    
    # For Redwood.js projects
    if [ -d web ] && [ -f web/package.json ]; then \
      echo '🌲 Detected Redwood.js project - running Storybook from web directory' && \
      cd web && \
      echo '🌐 Storybook will be available at http://localhost:6009 when ready' && \
      yarn storybook --port 6008 --ci --host 0.0.0.0 || npm run storybook -- --port 6008 --ci --host 0.0.0.0; \
    else \
      echo '🌐 Storybook will be available at http://localhost:6009 when ready' && \
      yarn storybook --port 6008 --ci --host 0.0.0.0 || npm run storybook -- --port 6008 --ci --host 0.0.0.0; \
    fi; \
  else \
    echo -e '\\n🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡' && \
    echo '⚠️  TKT7 - REDWOOD BLOG APP ⚠️' && \
    echo '⚠️  NO STORYBOOK CONFIGURATION FOUND ⚠️' && \
    echo '🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡🟡' && \
    echo '\\n💡 TIP: If you want to use Storybook with this project:' && \
    
    # Special instructions for Redwood
    if [ -f 'redwood.toml' ] || grep -q 'redwoodjs' package.json; then \
      echo '  1. Add Storybook to your Redwood project with: yarn rw setup storybook' && \
    else \
      echo '  1. Add Storybook to your project with: npx storybook@latest init' && \
    fi && \
    
    echo '  2. Commit the changes to your repository' && \
    echo '  3. Restart this container' && \
    echo '\\n✅ Storybook container will exit gracefully.\\n' && \
    exit 0; \
  fi; \
else \
  echo -e '\\n🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴' && \
  echo '❌ TKT7 - REDWOOD BLOG APP ❌' && \
  echo '❌ ERROR: No package.json found in repository ❌' && \
  echo '🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴' && \
  echo '\\n🔎 REPO_URL setting: ${TKT7_REPO_URL}' && \
  echo '📋 Check your .env file or command line arguments' && \
  exit 1; \
fi" ]