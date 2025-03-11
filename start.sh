#\!/bin/bash

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Initialize apps array to track which apps to start
declare -a apps_to_start
all_apps=false

# Display help message
show_help() {
    echo "Usage: ./start.sh [options] [app1] [app2] ..."
    echo ""
    echo "Options:"
    echo "  -a, --all      Start all applications"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Applications:"
    echo "  tkt0           Python Development Environment (Flask + Jupyter)"
    echo "  tkt4           React Trivia App" 
    echo "  tkt56          Issue Tracker App"
    echo "  tkt7           Redwood Blog App"
    echo ""
    echo "Before starting, ensure repository URLs are configured in .env file:"
    echo "  TKT0_REPO_URL=https://github.com/yourusername/python-repo"
    echo "  TKT4_REPO_URL=https://github.com/yourusername/react-repo"
    echo "  TKT56_REPO_URL=https://github.com/yourusername/nextjs-repo"
    echo "  TKT7_REPO_URL=https://github.com/yourusername/redwood-repo"
    echo ""
    echo "Example:"
    echo "  ./start.sh tkt0                   # Start Python development environment"
    echo "  ./start.sh tkt4 tkt56             # Start multiple specific apps"
    echo "  ./start.sh -a                     # Start all apps"
    exit 0
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all)
            all_apps=true
            shift
            ;;
        -h|--help)
            show_help
            ;;
        tkt0|tkt4|tkt56|tkt7)
            apps_to_start+=("$1")
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Load env variables from .env file if it exists
if [ -f .env ]; then
    source .env
fi

echo -e "\n${BLUE}Repository Configuration:${NC}"
[ -n "$TKT0_REPO_URL" ] && echo -e "🐍 TKT0: ${GREEN}$TKT0_REPO_URL${NC}" || echo -e "🐍 TKT0: ${RED}Not configured${NC}"
[ -n "$TKT4_REPO_URL" ] && echo -e "🎮 TKT4: ${GREEN}$TKT4_REPO_URL${NC}" || echo -e "🎮 TKT4: ${RED}Not configured${NC}"
[ -n "$TKT56_REPO_URL" ] && echo -e "📋 TKT56: ${GREEN}$TKT56_REPO_URL${NC}" || echo -e "📋 TKT56: ${RED}Not configured${NC}"
[ -n "$TKT7_REPO_URL" ] && echo -e "📝 TKT7: ${GREEN}$TKT7_REPO_URL${NC}" || echo -e "📝 TKT7: ${RED}Not configured${NC}"

# Start the base infrastructure
echo -e "\n${BLUE}Starting base infrastructure...${NC}"
docker-compose down
docker-compose up -d

# If all apps flag is set, include all apps
if [ "$all_apps" = true ]; then
    apps_to_start=("tkt0" "tkt4" "tkt56" "tkt7")
fi

# Check and start each requested app
for app in "${apps_to_start[@]}"; do
    app_var="${app^^}_REPO_URL"
    if ! grep -q "$app_var=" .env || grep -q "$app_var=$" .env; then
        echo -e "${RED}Error: $app_var not provided for $app app${NC}"
        continue
    fi
    
    echo -e "\n${BLUE}Starting $app...${NC}"
    repo_url=$(grep "^$app_var=" .env | cut -d= -f2-)
    echo "Using repository: $repo_url"
    
    # Ensure external network exists
    docker network inspect app-network >/dev/null 2>&1 || docker network create app-network
    
    # Start the app
    docker-compose -f "./$app/docker-compose.$app.yml" --env-file .env build
    docker-compose -f "./$app/docker-compose.$app.yml" --env-file .env up -d
done

echo -e "\n${GREEN}Services started successfully\!${NC}"
echo -e "Run ./test-services.sh to verify all services are running correctly.\n"

echo -e "${BLUE}Access services at:${NC}"
echo -e "• Traefik Dashboard: ${GREEN}http://traefik.localhost${NC} or ${GREEN}http://localhost:8081${NC}"
echo -e "• phpMyAdmin:       ${GREEN}http://phpmyadmin.localhost${NC} or ${GREEN}http://localhost:8080${NC}"
echo -e "• CloudBeaver:      ${GREEN}http://cloudbeaver.localhost${NC} or ${GREEN}http://localhost:8978${NC}"

# Show URLs for apps that were started
for app in "${apps_to_start[@]}"; do
    case "$app" in
        tkt0)
            echo -e "• TKT0 Flask:       ${GREEN}http://tkt0.localhost${NC} or ${GREEN}http://localhost:5000${NC}"
            echo -e "• TKT0 Jupyter:     ${GREEN}http://jupyter.localhost${NC} or ${GREEN}http://localhost:8888${NC}"
            ;;
        tkt4)
            echo -e "• TKT4 Web:         ${GREEN}http://tkt4.localhost${NC} or ${GREEN}http://localhost:5174${NC}"
            echo -e "• TKT4 Storybook:   ${GREEN}http://tkt4-storybook.localhost${NC} or ${GREEN}http://localhost:6007${NC}"
            ;;
        tkt56)
            echo -e "• TKT56 Web:        ${GREEN}http://tkt56.localhost${NC} or ${GREEN}http://localhost:5175${NC}"
            echo -e "• TKT56 Storybook:  ${GREEN}http://tkt56-storybook.localhost${NC} or ${GREEN}http://localhost:6008${NC}"
            ;;
        tkt7)
            echo -e "• TKT7 Web:         ${GREEN}http://tkt7.localhost${NC} or ${GREEN}http://localhost:8910${NC}"
            echo -e "• TKT7 API:         ${GREEN}http://tkt7-api.localhost${NC} or ${GREEN}http://localhost:8911${NC}"
            echo -e "• TKT7 Storybook:   ${GREEN}http://tkt7-storybook.localhost${NC} or ${GREEN}http://localhost:6009${NC}"
            ;;
    esac
done

