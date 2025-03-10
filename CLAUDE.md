# CLAUDE.md - Coding Assistant Guidelines

## Key Services
- 🚨 **Traefik Dashboard**: http://localhost:8081 - for monitoring services
- **MySQL Database**: http://localhost:3306 
- **phpMyAdmin**: http://localhost:8080
- **CloudBeaver**: http://localhost:8978

## Recent Updates
- Improved repository display with colorful banners at script start
- Streamlined services section with clickable URLs
- Added intelligent Storybook detection
- Updated all references to use direct localhost:PORT format
- Restructured APPS SUMMARY section for clarity
- Added colorful error messages for missing Storybook configurations

## Docker Commands
- `docker-compose build --no-cache` - Rebuild containers (use cautiously - slows down rebuilds)
- `docker-compose build` - Rebuild using cache when possible (faster)
- `docker-compose up -d` - Start all services
- `docker-compose down` - Stop all services
- `docker-compose ps` - List running containers
- `docker-compose logs <service>` - View container logs (web, storybook, mysql, etc.)
- `docker-compose exec <service> sh` - Access container shell

## Scripts
- `./start.sh [app_name]` - Start specific application(s) with configured repo URLs
- `./start.sh --all` - Start all configured applications
- `./start.sh --help` - Show all available options
- `./test-services.sh` - Verify services are running correctly

## Roadmap
- **TKT0**: Python Advanced Problem Solving environment
  - Virtual environment for local Python development
  - Includes Jupyter Notebook, popular libraries, and coding exercises
  - Required before any ticket implementation
  - Access at http://localhost:8888 for Jupyter and http://localhost:5000 for Flask apps
  - Conserve system resources with `docker-compose stop python_notebook` when not in use

## App Configuration
- **TKT4**: React Trivia App (https://github.com/TortoiseWolfe/react-trivia)
- **TKT56**: Issue Tracker App (https://github.com/TortoiseWolfe/nextjs-tutorial)
- **TKT7**: Redwood Blog App (https://github.com/TortoiseWolfe/redwoodblog_Mar_2nd_4pm)
  - **Architecture**: Full-stack app with separate Web and API servers
  - **Ports**: Web (8910), API (8911)
  - **Endpoints**: 
    - Web UI: http://localhost:8910
    - GraphQL API: http://localhost:8911
  - **Database**: Uses Prisma ORM with MySQL
  - **Setup**: After starting, run `./repos/tkt7/init-db.sh` to initialize the database

## Known Issues & Improvement Areas
- **Docker Compose Version**: No explicit version specified in docker-compose files
- **Security**: Database credentials hardcoded in docker-compose.yaml (development use only)
- **Error Handling**: Git repository cloning failure handling could be improved
- **Container Dependencies**: Some services may start before dependencies are fully ready
- **Performance**: Each app builds its own Node.js container, potentially inefficient
- **Memory Usage**: Running all services simultaneously requires significant RAM
- **HTTPS**: Not configured for local development (HTTP only)

## Resource Management
- **Memory Monitoring**: The start script displays container memory usage
- **Stop Unused Services**: `docker-compose stop <service>` to pause services not in use
- **Selective Startup**: Use `./start.sh tkt0` to start only specific applications
- **Minimal Base**: `docker-compose up -d mysql phpmyadmin` for just database services
- **Jupyter Lab**: Consumes significant memory, stop when not actively coding

## Code Style Guidelines
- **Docker:** Use Alpine-based images, implement health checks, expose specific ports
- **Services:** Main Web (5173), Main Storybook (6006), MySQL (3306), phpMyAdmin (8080), CloudBeaver (8978)
- **Port Assignments:**
  - Development: Web (5173), Storybook (6006)
  - TKT0: Jupyter (8888), Flask (5000)
  - TKT4: Web (5174), Storybook (6007)
  - TKT56: Web (5175), Storybook (6008)
  - TKT7: Web (8910), API (8911), Storybook (6009)
  - Traefik Dashboard: 8081
- **Scripts:** Include proper error handling, clear error messages, non-zero exit codes on failure
- **Environment:** Use environment variables for configuration (REPO_URL, TKT4_REPO_URL, etc.)
- **Testing:** HTTP endpoint verification, container health status checks

## Structure
This is primarily a DevOps configuration for running React applications with Storybook, MySQL, and database management tools. Traefik is used as the reverse proxy to route requests to the appropriate services.

## Troubleshooting
1. Always check the Traefik dashboard (http://localhost:8081) first for service health
2. Use `./test-services.sh` to verify all endpoints are responding correctly
3. Check application-specific logs with `docker-compose logs [service]`
4. For Git clone failures, check repository URLs in .env file
5. If containers restart repeatedly, check health status with `docker ps` and logs