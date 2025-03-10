#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Define domains we need for our services
DOMAINS=(
  "dev.localhost"
  "storybook.localhost"
  "tkt4.localhost"
  "tkt4-storybook.localhost"
  "tkt56.localhost"
  "tkt56-storybook.localhost"
  "tkt7.localhost" 
  "tkt7-storybook.localhost"
  "traefik.localhost"
)

# Check if running as root (needed to modify /etc/hosts)
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root to modify /etc/hosts${NC}"
   echo "Please run: sudo $0"
   exit 1
fi

echo -e "${BLUE}Setting up /etc/hosts entries for Traefik domains...${NC}"

# Create a backup of the hosts file
BACKUP_FILE="/etc/hosts.$(date +%Y%m%d%H%M%S).bak"
cp /etc/hosts "$BACKUP_FILE"
echo -e "${GREEN}Created backup of /etc/hosts at $BACKUP_FILE${NC}"

# Check if we already have our marker in the file
if grep -q "# START DEVOPS-EXTRACT DOMAINS" /etc/hosts; then
  # Remove old entries between our markers
  sed -i '/# START DEVOPS-EXTRACT DOMAINS/,/# END DEVOPS-EXTRACT DOMAINS/d' /etc/hosts
  echo -e "${YELLOW}Removed old entries from /etc/hosts${NC}"
fi

# Add our marker and entries
echo "# START DEVOPS-EXTRACT DOMAINS" >> /etc/hosts
for domain in "${DOMAINS[@]}"; do
  echo "127.0.0.1 $domain" >> /etc/hosts
  echo -e "${GREEN}Added: 127.0.0.1 $domain${NC}"
done
echo "# END DEVOPS-EXTRACT DOMAINS" >> /etc/hosts

echo -e "${BLUE}==========================${NC}"
echo -e "${GREEN}Setup complete! All domains now point to 127.0.0.1${NC}"
echo -e "${BLUE}==========================${NC}"
echo "You can now access your services at:"
echo -e "- Development App: ${GREEN}http://dev.localhost${NC}"
echo -e "- Development Storybook: ${GREEN}http://storybook.localhost${NC}"
echo -e "- TKT4 App: ${GREEN}http://tkt4.localhost${NC}"
echo -e "- TKT4 Storybook: ${GREEN}http://tkt4-storybook.localhost${NC}"
echo -e "- TKT56 App: ${GREEN}http://tkt56.localhost${NC}"
echo -e "- TKT56 Storybook: ${GREEN}http://tkt56-storybook.localhost${NC}"
echo -e "- TKT7 App: ${GREEN}http://tkt7.localhost${NC}"
echo -e "- TKT7 Storybook: ${GREEN}http://tkt7-storybook.localhost${NC}"
echo -e "- Traefik Dashboard: ${GREEN}http://traefik.localhost:8081${NC}"