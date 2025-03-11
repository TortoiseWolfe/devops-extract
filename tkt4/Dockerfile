FROM node:20-alpine3.19

WORKDIR /app

# Install git and essential tools
RUN apk add --no-cache git

# Accept build arg for repo URL
ARG TKT4_REPO_URL

# Clone from repository and install dependencies
RUN git clone "$TKT4_REPO_URL" /app && \
    npm install

# Environment setup
ENV NODE_ENV=development
ENV PORT=5174

# Expose ports
EXPOSE 5174

# Start development server
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "5174"]
