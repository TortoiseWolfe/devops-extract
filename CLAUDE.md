# CLAUDE.md - Coding Assistant Guidelines

## Docker Commands
- `docker-compose build --no-cache` - Rebuild containers
- `docker-compose up -d` - Start all services
- `docker-compose down` - Stop all services
- `docker-compose ps` - List running containers
- `docker-compose logs <service>` - View container logs (web, storybook, mysql, etc.)
- `docker-compose exec <service> sh` - Access container shell

## Scripts
- `./start.sh [REPO_URL]` - Start services with specified Git repository
- `./test-services.sh` - Verify services are running correctly
- `./setup-storybook.sh` - Set up Storybook for projects that need it

## Code Style Guidelines
- **Docker:** Use Alpine-based images, implement health checks, expose specific ports
- **Services:** Web (5173), Storybook (6006), MySQL (3306), phpMyAdmin (8080), CloudBeaver (8978)
- **Scripts:** Include proper error handling, clear error messages, non-zero exit codes on failure
- **Environment:** Use environment variables for configuration (REPO_URL)
- **Testing:** HTTP endpoint verification, container health status checks

## Structure
This is primarily a DevOps configuration for running React applications with Storybook, MySQL, and database management tools.