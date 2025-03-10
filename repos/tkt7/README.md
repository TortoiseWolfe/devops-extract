# TKT7 - Redwood Blog Application

This directory contains the Docker configuration for running the Redwood Blog application.

## About Redwood.js Apps

Redwood.js is a full-stack JavaScript/TypeScript framework for building web applications. It has a few key differences from standard React applications:

- **Dual Server Architecture** - Separate web (frontend) and API (backend) servers
- **GraphQL API** - API server provides GraphQL endpoints rather than REST
- **Prisma ORM** - Uses Prisma for database access and migrations
- **File-based Routing** - Similar to Next.js

## Running the Application

1. Start the application:
   ```bash
   cd ../../
   ./start.sh tkt7
   ```

2. Set up the database (after container is running):
   ```bash
   cd ../../
   ./repos/tkt7/init-db.sh
   ```
   This will run the Prisma migrations and optionally seed the database.

## Available Endpoints

- **Web UI**: http://tkt7.localhost
- **GraphQL API**: http://api-tkt7.localhost
- **Storybook**: http://tkt7-storybook.localhost
- **Database Admin**: http://localhost:8080 (phpMyAdmin)

## Container Details

The TKT7 setup uses:
- Node.js 20 Alpine base image
- Python, Make, and G++ for native dependencies
- Yarn package manager
- MySQL database via the shared service
- Prisma ORM for database migrations and access

## Development Notes

1. **Database Changes**:
   If you need to modify the database schema, make changes to the Prisma schema file in the Redwood app:
   ```
   ./api/db/schema.prisma
   ```
   
   Then run migrations inside the container:
   ```bash
   docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml exec tkt7 sh -c 'cd /app && yarn rw prisma migrate dev'
   ```

2. **API/GraphQL Changes**:
   Changes to the GraphQL API are available at http://api-tkt7.localhost/graphql

3. **Storybook**:
   Storybook in a Redwood app is located in the web directory and includes components from there.

## Troubleshooting

1. **Migration Issues**:
   - Check the database connection string in the environment variables
   - Make sure the MySQL service is running
   - Review logs with: `docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml logs tkt7`

2. **Build Failures**:
   - Redwood requires several native dependencies; verify they're installed in the container
   - Python, Make, and G++ are required for some NPM packages

3. **API Connection Issues**:
   - Ensure the `RWJS_DEV_API_URL` environment variable is set correctly
   - Verify the API server is accessible at http://api-tkt7.localhost