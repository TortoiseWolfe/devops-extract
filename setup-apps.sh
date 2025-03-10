#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Multi-Application Repository Setup${NC}"
echo "==========================================="

# Create or update .env file
touch .env

# Function to add or update environment variables
add_env_var() {
    local name=$1
    local value=$2
    if grep -q "$name=" .env; then
        sed -i "s|$name=.*|$name=$value|g" .env
        echo -e "${GREEN}Updated ${name}=${value}${NC}"
    else
        echo "$name=$value" >> .env
        echo -e "${GREEN}Added ${name}=${value}${NC}"
    fi
}

# Prompt for repository URLs
echo -e "\n${BLUE}Configure Repository URLs${NC}"
echo "Enter the Git repository URLs for each application (leave blank to skip):"

# TKT4 - Trivia App
read -p "TKT4 (Trivia App) Repository URL: " tkt4_url
if [ -n "$tkt4_url" ]; then
    add_env_var "TKT4_REPO_URL" "$tkt4_url"
fi

# TKT56 - Issue Tracker
read -p "TKT56 (Issue Tracker) Repository URL: " tkt56_url
if [ -n "$tkt56_url" ]; then
    add_env_var "TKT56_REPO_URL" "$tkt56_url"
fi

# TKT7 - Redwood Blog
read -p "TKT7 (Redwood Blog) Repository URL: " tkt7_url
if [ -n "$tkt7_url" ]; then
    add_env_var "TKT7_REPO_URL" "$tkt7_url"
fi

# Legacy (for backward compatibility)
read -p "Legacy Repository URL (for backward compatibility): " legacy_url
if [ -n "$legacy_url" ]; then
    add_env_var "REPO_URL" "$legacy_url"
fi

# Display configuration summary
echo -e "\n${BLUE}Configuration Summary:${NC}"
cat .env

# Offer to start services
echo -e "\n${BLUE}Start Services${NC}"
read -p "Would you like to start services now? (y/n): " start_services

if [[ $start_services =~ ^[Yy]$ ]]; then
    echo -e "\n${BLUE}Select which applications to start:${NC}"
    echo "1) Start legacy application (based on REPO_URL)"
    echo "2) Start TKT4 - Trivia App"
    echo "3) Start TKT56 - Issue Tracker"
    echo "4) Start TKT7 - Redwood Blog"
    echo "5) Start all configured applications"
    
    read -p "Enter your choice (1-5): " app_choice
    
    case $app_choice in
        1)
            ./start.sh
            ;;
        2)
            ./start.sh tkt4
            ;;
        3)
            ./start.sh tkt56
            ;;
        4)
            ./start.sh tkt7
            ;;
        5)
            ./start.sh --all
            ;;
        *)
            echo -e "${RED}Invalid choice. No services started.${NC}"
            ;;
    esac
else
    echo -e "\n${GREEN}Setup complete. Run './start.sh' to start services.${NC}"
    echo "Run './start.sh --help' for more options."
fi