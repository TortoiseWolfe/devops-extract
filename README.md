# Multi-Repository DevOps Configuration

This repository contains a modular Docker configuration for running multiple applications from different repositories with shared database services.

## Features

- **Multiple App Support** - Deploy and run multiple apps from different repositories
- **App-specific Storybook** - Each app has its own Storybook instance
- **Shared Database** - Central MySQL database for all applications
- **Database Management** - phpMyAdmin and CloudBeaver for database administration
- **Modular Architecture** - Add new apps without affecting existing ones
- **Health Monitoring** - Automatic health checks for all services
- **Traefik Integration** - Host-based routing for managing port conflicts using domain names

## Supported Applications

- **TKT4** - React Trivia App
- **TKT56** - Issue Tracker App
- **TKT7** - Redwood Blog App
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
   chmod +x start.sh test-services.sh setup-storybook.sh setup-hosts.sh
   ```

3. Set up hostname routing for Traefik:
   ```bash
   sudo ./setup-hosts.sh
   ```
   This adds entries to your /etc/hosts file so domain names resolve correctly.

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

- `TKT4_REPO_URL` - Git repository URL for TKT4 app
- `TKT56_REPO_URL` - Git repository URL for TKT56 app  
- `TKT7_REPO_URL` - Git repository URL for TKT7 app
- `REPO_URL` - Legacy repository URL (for backward compatibility)

Example:
```bash
TKT4_REPO_URL=https://github.com/username/trivia.git ./start.sh tkt4
```

### Available Services

#### Base Services
- MySQL Database: localhost:3306
- phpMyAdmin: http://localhost:8080
- CloudBeaver: http://localhost:8978
- Traefik Dashboard: http://traefik.localhost:8081

#### App Services (Traefik Routing)
- Development App: http://dev.localhost
- Development Storybook: http://storybook.localhost
- TKT4 Trivia App: http://tkt4.localhost
- TKT4 Storybook: http://tkt4-storybook.localhost
- TKT56 Issue Tracker: http://tkt56.localhost
- TKT56 Storybook: http://tkt56-storybook.localhost
- TKT7 Redwood Blog: http://tkt7.localhost
- TKT7 Storybook: http://tkt7-storybook.localhost

### Database Credentials

- Username: user (or root for admin)
- Password: password (or rootpassword for admin)
- Database name: app

## Architecture

The system uses a modular architecture:

1. **Base Infrastructure** - Defined in the main docker-compose.yaml
   - Traefik reverse proxy for routing
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
   - Hostname-based routing through Traefik
   - No port conflicts between services

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

1. Run the test script to identify issues:
   ```bash
   ./test-services.sh
   ```

2. Check container logs:
   ```bash
   docker-compose logs mysql
   docker-compose -f ./repos/tkt4/docker-compose.tkt4.yml logs tkt4
   ```

3. Restart services:
   ```bash
   ./start.sh tkt4
   ```