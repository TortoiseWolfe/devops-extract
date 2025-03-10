# Multi-Repository DevOps Configuration

This repository contains a modular Docker configuration for running multiple applications from different repositories with shared database services. This setup is designed for local development environments.

## Features

- **Multiple App Support** - Deploy and run multiple apps from different repositories
- **App-specific Storybook** - Each app has its own Storybook instance
- **Shared Database** - Central MySQL database for all applications
- **Database Management** - phpMyAdmin and CloudBeaver for database administration
- **Modular Architecture** - Add new apps without affecting existing ones
- **Health Monitoring** - Automatic health checks for all services
- **Direct Port Access** - Applications accessible via localhost with unique port numbers

## Note on Development Use

This configuration is optimized for local development and includes:
- Plain-text database credentials (not for production use)
- HTTP-only services (no HTTPS configuration)
- Exposed admin tools without additional authentication

## Supported Applications

- **TKT4** - React Trivia App (https://github.com/TortoiseWolfe/react-trivia)
- **TKT56** - Issue Tracker App (https://github.com/TortoiseWolfe/nextjs-tutorial)
- **TKT7** - Redwood Blog App (https://github.com/TortoiseWolfe/redwoodblog_Mar_2nd_4pm)
  - Full-stack app with separate API and web servers
  - Includes GraphQL API server and database migrations
  - Requires special configuration for Prisma and MySQL
- **Legacy Mode** - Backward compatibility with single repository setup

## Setup

### Prerequisites

- Docker and Docker Compose
- Git
- Bash shell

### Quick Start

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd devops-extract
   ```

2. Make the scripts executable:
   ```bash
   chmod +x start.sh test-services.sh
   ```

3. No host file modification required - all services use direct port access.

4. Run the start script with an application name and its repository URL:
   ```bash
   TKT4_REPO_URL=https://github.com/username/trivia-app.git ./start.sh tkt4
   ```

   This will:
   - Store the repository URL in a .env file
   - Build and start the Docker containers for the selected app
   - Display URLs for accessing the services

5. Verify services are running correctly:
   ```bash
   ./test-services.sh
   ```

## Usage

The start script supports multiple options and can run specific applications:

```bash
# Run the legacy setup (backward compatibility)
./start.sh https://github.com/username/repo.git

# Start a specific app
./start.sh tkt4

# Start multiple apps
./start.sh tkt4 tkt56

# Start all apps
./start.sh --all

# View help
./start.sh --help
```

### Environment Variables

Set these in the `.env` file or pass them directly to the start script:

- `TKT4_REPO_URL` - Git repository URL for TKT4 app (React Trivia)
- `TKT56_REPO_URL` - Git repository URL for TKT56 app (Next.js Tutorial)
- `TKT7_REPO_URL` - Git repository URL for TKT7 app (Redwood Blog)
- `REPO_URL` - Legacy repository URL (for backward compatibility)

Default Repository URLs:
```
TKT4_REPO_URL=https://github.com/TortoiseWolfe/react-trivia
TKT56_REPO_URL=https://github.com/TortoiseWolfe/nextjs-tutorial
TKT7_REPO_URL=https://github.com/TortoiseWolfe/redwoodblog_Mar_2nd_4pm
```

Example usage:
```bash
TKT4_REPO_URL=https://github.com/username/trivia.git ./start.sh tkt4
```

### Available Services

#### Base Services
- MySQL Database: localhost:3306
- phpMyAdmin: http://localhost:8080
- CloudBeaver: http://localhost:8978
- 🚨 Traefik Dashboard: http://localhost:8081 (monitoring & routing visualization)

#### App Services (Direct Port Access)
- Development App: http://localhost:5173
- Development Storybook: http://localhost:6006
- TKT4 Trivia App: http://localhost:5174
- TKT4 Storybook: http://localhost:6007
- TKT56 Issue Tracker: http://localhost:5175
- TKT56 Storybook: http://localhost:6008
- TKT7 Redwood Blog: http://localhost:8910
- TKT7 API Server: http://localhost:8911 (Redwood's GraphQL API)
- TKT7 Storybook: http://localhost:6009

### Database Credentials

- Username: user (or root for admin)
- Password: password (or rootpassword for admin)
- Database name: app

## Architecture

The system uses a modular architecture:

1. **Base Infrastructure** - Defined in the main docker-compose.yaml
   - 🚨 **Traefik reverse proxy** - Provides routing and monitoring dashboard at http://traefik.localhost:8081
   - MySQL database
   - phpMyAdmin
   - CloudBeaver
   - Centralized logging

2. **Application-specific Services** - Each app has its own directory in repos/
   - Individual Dockerfile
   - App-specific docker-compose.yml file
   - Storybook configuration
   - Dedicated logging configuration
   - Traefik labels for hostname-based routing

3. **Networking** - All services share a common network for communication
   - Direct port access via localhost with unique port numbers
   - No port conflicts between services due to careful port mapping

4. **Logging** - Each container has JSON logging configured
   - Log rotation with 10MB maximum file size
   - Retains 3 log files per container
   - View logs with `docker-compose logs [service]`

## Testing

Verify all running services:

```bash
./test-services.sh
```

This script:
- Tests all running services via HTTP requests
- Shows Docker container status
- Displays health check information
- Provides clear pass/fail output

## Adding New Applications

To add a new application:

1. Create a directory for the app in the `repos/` directory
2. Add a Dockerfile and a docker-compose.yml file following the existing templates
3. Update the start script to support the new app

## Troubleshooting

If services aren't running properly:

1. Check the **Traefik Dashboard** for service health:
   ```
   🚨 http://localhost:8081 🚨
   ```
   The dashboard shows all active services and their health status.

2. Run the test script to identify issues:
   ```bash
   ./test-services.sh
   ```

3. Check container logs:
   ```bash
   docker-compose logs mysql
   docker-compose -f ./repos/tkt4/docker-compose.tkt4.yml logs tkt4
   ```

4. For Git repository cloning issues:
   - Verify the repository URLs in your .env file
   - Check that the repositories are accessible
   - Look for error messages in the container logs

5. For container dependency issues:
   - Some services may start before their dependencies are fully ready
   - Check the container health status: `docker ps`

6. Restart services:
   ```bash
   ./start.sh tkt4
   ```

## Known Limitations

- **Docker Compose Version**: No explicit version is specified in the docker-compose files
- **Performance**: Building with `--no-cache` can be slow; use regular builds when possible
- **Container Efficiency**: Each app builds its own Node.js container
- **Error Handling**: Some edge cases in repository cloning may not be handled optimally