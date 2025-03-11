FROM node:20-alpine3.19

WORKDIR /app

# Install git and essential tools
RUN apk add --no-cache git

# Accept build arg for repo URL
ARG TKT56_REPO_URL

# Clone from repository and install dependencies
RUN git clone "$TKT56_REPO_URL" /app && \
    npm install || echo "Empty repository or no package.json found"

# Environment setup
ENV NODE_ENV=development
ENV PORT=5175
ENV NEXT_PUBLIC_API_URL=http://localhost:5175/api

# Expose ports
EXPOSE 5175

# Start development server
CMD ["sh", "-c", "if [ -f 'package.json' ]; then npm run dev -- --hostname 0.0.0.0 --port 5175; else echo 'No package.json found' && tail -f /dev/null; fi"]
