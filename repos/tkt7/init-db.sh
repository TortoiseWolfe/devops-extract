#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Setting up database for Redwood Blog App...${NC}"

# Check if the container is running
if ! docker ps | grep -q tkt7; then
  echo -e "${RED}Error: TKT7 container is not running${NC}"
  echo "Please start the container first with: ./start.sh tkt7"
  exit 1
fi

echo -e "${YELLOW}Running Prisma migrations...${NC}"

# First, update the Prisma schema to use MySQL
docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml exec tkt7 sh -c 'cd /app && \
  if grep -q "provider = \"sqlite\"" ./api/db/schema.prisma; then \
    echo "Converting Prisma schema from SQLite to MySQL..." && \
    sed -i "s/provider = \"sqlite\"/provider = \"mysql\"/g" ./api/db/schema.prisma; \
  fi'

# Run the Prisma migrations inside the container
docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml exec tkt7 sh -c 'cd /app && \
  echo "Running Prisma migrations..." && \
  yarn rw prisma migrate dev --name initial-setup'

# Check if migrations were successful
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Database migrations completed successfully!${NC}"
  echo -e "Your Redwood Blog App is now ready to use."
  echo -e "Web UI: ${BLUE}http://tkt7.localhost${NC}"
  echo -e "API Server: ${BLUE}http://api-tkt7.localhost${NC}"
else
  echo -e "${RED}Database migrations failed.${NC}"
  echo "Check the logs for more details: docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml logs tkt7"
  exit 1
fi

# Optionally seed the database
echo -e "${YELLOW}Would you like to seed the database with sample data? (y/n)${NC}"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Seeding the database...${NC}"
  docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml exec tkt7 sh -c 'cd /app && yarn rw prisma db seed'
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Database seeded successfully!${NC}"
  else
    echo -e "${RED}Database seeding failed.${NC}"
  fi
fi

echo -e "${GREEN}Setup complete!${NC}"
echo -e "${BLUE}==========================${NC}"
echo -e "You can now access your Redwood Blog at:"
echo -e "- Web UI: ${GREEN}http://tkt7.localhost${NC}"
echo -e "- API: ${GREEN}http://api-tkt7.localhost${NC}"
echo -e "- Database Admin: ${GREEN}http://localhost:8080${NC} (phpMyAdmin)"
echo -e "${BLUE}==========================${NC}"