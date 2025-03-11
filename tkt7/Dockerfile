FROM node:20-alpine3.19

WORKDIR /app

# Install git and essential tools
RUN apk add --no-cache git bash curl

# Accept build arg for repo URL
ARG TKT7_REPO_URL

# Clone from repository and install dependencies
RUN git clone "$TKT7_REPO_URL" /app && \
    npm install || echo "Repository clone failed or no package.json found"

# Environment setup for Redwood
ENV NODE_ENV=development
ENV DATABASE_URL=mysql://user:password@mysql:3306/app
ENV WEB_PORT=8910
ENV API_PORT=8911

# Expose ports
EXPOSE 8910 8911

# Start development server
CMD ["sh", "-c", "if [ -f 'package.json' ]; then npm run dev; else echo 'No package.json found' && tail -f /dev/null; fi"]
