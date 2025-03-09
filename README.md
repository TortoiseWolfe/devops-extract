# React App DevOps Configuration

This repository contains Docker configuration for running React applications in containerized environments.

## Files

- `Dockerfile` - Main container configuration for React applications
- `DockerfileNode` - Alternative Node.js container configuration
- `docker-compose.yaml` - Compose configuration for multi-container setup
- `.env.example` - Example environment variables
- `start.sh` - Startup script for launching containers

## Usage

1. Copy the `.env.example` file to `.env`:
   ```
   cp .env.example .env
   ```

2. Set the React application repository URL in the `.env` file:
   ```
   REPO_URL=https://github.com/username/your-react-app.git
   ```

3. Run the start script:
   ```
   ./start.sh
   ```

   Or provide the repository URL directly:
   ```
   ./start.sh https://github.com/username/your-react-app.git
   ```

4. Access your applications:
   - React App: http://localhost:5173
   - Storybook: http://localhost:6006

## Requirements

- Docker and Docker Compose
- Git