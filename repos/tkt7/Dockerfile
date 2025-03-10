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

# Set Redwood environment variables
ENV NODE_ENV=development
ENV RWJS_DEV_API_URL=http://api-tkt7.localhost
# Default DATABASE_URL that can be overridden by docker-compose
ENV DATABASE_URL=mysql://user:password@mysql:3306/app

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

# Expose Redwood's web and API ports
EXPOSE 8910
EXPOSE 8911

# Use tini as entrypoint
ENTRYPOINT ["/sbin/tini", "--"]

# Default to development mode with host flag to expose on all interfaces
CMD [ "sh", "-c", "echo '🚀 Starting TKT7 Redwood Blog App...' && if [ -f package.json ]; then echo '✅ Repository cloned successfully' && echo '📦 Found package.json - starting Redwood application' && echo '🌐 Web UI will be available at http://tkt7.localhost when ready' && echo '🌐 API will be available at http://api-tkt7.localhost when ready' && echo '📊 Traefik Dashboard: http://traefik.localhost:8081' && echo \"📂 REPO: ${TKT7_REPO_URL}\" && if grep -q '\"packageManager\":' package.json; then echo '🧶 Enabling Corepack for Yarn version management' && corepack enable && yarn -v; fi && if [ ! -d 'node_modules' ]; then echo '📦 Installing dependencies...' && echo '📦 Adding missing dependencies...' && yarn add yargs && yarn install; fi && if [ -f ./api/db/schema.prisma ]; then echo '🔄 Configuring Prisma for MySQL...' && if grep -q 'provider = \"sqlite\"' ./api/db/schema.prisma; then echo '🔄 Updating schema.prisma to use MySQL instead of SQLite...' && sed -i 's/provider = \"sqlite\"/provider = \"mysql\"/g' ./api/db/schema.prisma && sed -i 's|url.*=.*env(\"DATABASE_URL\")|url      = \"mysql://user:password@mysql:3306/app\"|g' ./api/db/schema.prisma; fi && echo '🔄 Skipping migrations for now - will run from init-db.sh script'; fi && if [ -f redwood.toml ]; then echo '🔄 Updating redwood.toml for containerized environment...' && sed -i 's/port = 8910/port = 8910\\nhost = \"0.0.0.0\"/g' redwood.toml && sed -i 's/port = 8911/port = 8911\\nhost = \"0.0.0.0\"/g' redwood.toml && sed -i 's/open = true/open = false/g' redwood.toml; fi && echo '🚀 Starting Redwood app...' && PORT=8910 API_PORT=8911 yarn rw dev --fwd=\"--host=0.0.0.0\"; else echo '❌ ERROR: No package.json found. Please provide a valid TKT7_REPO_URL.' && echo '🔎 REPO_URL setting: ${TKT7_REPO_URL}' && echo '📋 Check your .env file or command line arguments' && sleep infinity; fi" ]