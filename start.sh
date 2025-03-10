#!/bin/bash

# Colors for output (ensure terminal handles ANSI color codes)
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Set flag for color output
USE_COLOR=1

# Detect if we're running in a terminal that doesn't support colors
if [ -t 1 ]; then
    # Check if NO_COLOR environment variable is set (https://no-color.org/)
    if [ -n "$NO_COLOR" ] || [ "$TERM" = "dumb" ]; then
        USE_COLOR=0
    fi
fi

# Helper function to handle colored output
colorize() {
    if [ "$USE_COLOR" -eq 1 ]; then
        echo -e "$@"
    else
        # Strip ANSI color codes when color is disabled
        echo -e "$@" | sed -E 's/\x1B\[[0-9;]*[mK]//g'
    fi
}

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
    echo "  tkt4           React Trivia App" 
    echo "  tkt56          Issue Tracker App"
    echo "  tkt7           Redwood Blog App"
    echo ""
    echo "Environment Variables (set in .env file):"
    echo "  TKT4_REPO_URL  Git repository URL for tkt4 app"
    echo "  TKT56_REPO_URL Git repository URL for tkt56 app"
    echo "  TKT7_REPO_URL  Git repository URL for tkt7 app"
    echo ""
    echo "Example:"
    echo "  ./start.sh tkt4 tkt56             # Start tkt4 and tkt56 apps"
    echo "  ./start.sh -a                     # Start all apps"
    echo "  TKT4_REPO_URL=https://... ./start.sh tkt4  # Set repo URL and start tkt4"
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
        tkt4|tkt56|tkt7)
            apps_to_start+=("$1")
            shift
            ;;
        *)
            # Check if argument looks like a URL
            if [[ $1 == http* ]]; then
                echo "Setting default REPO_URL to: $1"
                REPO_URL="$1"
            else
                echo "Unknown option: $1"
                show_help
            fi
            shift
            ;;
    esac
done

# Create .env file if it doesn't exist
touch .env

# Process environment variables from command line or current env
if [ -n "$REPO_URL" ]; then
    grep -q "REPO_URL=" .env && sed -i "s|REPO_URL=.*|REPO_URL=$REPO_URL|g" .env || echo "REPO_URL=$REPO_URL" >> .env
fi

if [ -n "$TKT4_REPO_URL" ]; then
    grep -q "TKT4_REPO_URL=" .env && sed -i "s|TKT4_REPO_URL=.*|TKT4_REPO_URL=$TKT4_REPO_URL|g" .env || echo "TKT4_REPO_URL=$TKT4_REPO_URL" >> .env
fi

if [ -n "$TKT56_REPO_URL" ]; then
    grep -q "TKT56_REPO_URL=" .env && sed -i "s|TKT56_REPO_URL=.*|TKT56_REPO_URL=$TKT56_REPO_URL|g" .env || echo "TKT56_REPO_URL=$TKT56_REPO_URL" >> .env
fi

if [ -n "$TKT7_REPO_URL" ]; then
    grep -q "TKT7_REPO_URL=" .env && sed -i "s|TKT7_REPO_URL=.*|TKT7_REPO_URL=$TKT7_REPO_URL|g" .env || echo "TKT7_REPO_URL=$TKT7_REPO_URL" >> .env
fi

# If no specific apps were requested, use all apps
if [ ${#apps_to_start[@]} -eq 0 ] && [ "$all_apps" = false ]; then
    # Default to the development container if no specific apps are selected
    echo "No specific apps selected. Using development container."
    
    # Check if REPO_URL is set
    if ! grep -q "REPO_URL=" .env || grep -q "REPO_URL=$" .env; then
        echo "Error: REPO_URL not provided"
        echo "Please set REPO_URL in .env file or provide it as environment variable"
        exit 1
    fi
    
    # Get REPO_URL from .env file
    REPO_URL=$(grep "^REPO_URL=" .env | cut -d= -f2-)
    
    # Start the containers with base configuration
    echo "Starting base containers..."
    echo "Using repository: $REPO_URL"
    
    # Pass the environment variables from central .env file
    docker-compose --env-file .env down
    docker-compose --env-file .env build --no-cache
    docker-compose --env-file .env up -d
    
    # Show URLs immediately
    echo "Development React App: http://dev.localhost"
    echo "Development Storybook: http://storybook.localhost"
    echo "Traefik Dashboard:    http://traefik.localhost:8081"
    
    # Show a minimal amount of logs
    echo "Starting services..."
    docker-compose logs --tail=5 -f web &
    PID=$!
    sleep 2
    kill $PID 2>/dev/null
else
    # Start the base infrastructure
    echo "Starting base infrastructure (MySQL, phpMyAdmin, CloudBeaver)..."
    docker-compose down
    docker-compose up -d mysql phpmyadmin cloudbeaver
    
    # Just show minimal status - full info at the end
    echo "Base infrastructure started"

    # Start requested or all apps
    if [ "$all_apps" = true ]; then
        apps_to_start=("tkt4" "tkt56" "tkt7")
    fi

    # Check and start each requested app
    for app in "${apps_to_start[@]}"; do
        case "$app" in
            tkt4)
                # Check if TKT4_REPO_URL is set
                if ! grep -q "TKT4_REPO_URL=" .env || grep -q "TKT4_REPO_URL=$" .env; then
                    echo "Error: TKT4_REPO_URL not provided for tkt4 app"
                    continue
                fi
                
                # Get TKT4_REPO_URL from .env file
                TKT4_REPO_URL=$(grep "^TKT4_REPO_URL=" .env | cut -d= -f2-)
                
                echo "Starting tkt4 (Trivia App)..."
                echo "Using repository: $TKT4_REPO_URL"
                
                # Pass the environment variables from central .env file
                docker-compose -f ./repos/tkt4/docker-compose.tkt4.yml --env-file .env build --no-cache
                docker-compose -f ./repos/tkt4/docker-compose.tkt4.yml --env-file .env up -d
                
                # Show URLs right away
                echo "TKT4 Trivia App: http://tkt4.localhost"
                echo "TKT4 Storybook:  http://tkt4-storybook.localhost"
                ;;
                
            tkt56)
                # Check if TKT56_REPO_URL is set
                if ! grep -q "TKT56_REPO_URL=" .env || grep -q "TKT56_REPO_URL=$" .env; then
                    echo "Error: TKT56_REPO_URL not provided for tkt56 app"
                    continue
                fi
                
                # Get TKT56_REPO_URL from .env file
                TKT56_REPO_URL=$(grep "^TKT56_REPO_URL=" .env | cut -d= -f2-)
                
                echo "Starting tkt56 (Issue Tracker App)..."
                echo "Using repository: $TKT56_REPO_URL"
                
                # Pass the environment variables from central .env file
                # Export all variables from the .env file
                export $(grep -v '^#' .env | xargs)
                echo "Using TKT56 repository: $TKT56_REPO_URL"
                docker-compose -f ./repos/tkt56/docker-compose.tkt56.yml --env-file .env build --no-cache
                docker-compose -f ./repos/tkt56/docker-compose.tkt56.yml --env-file .env up -d
                
                # Show URLs right away
                echo "TKT56 Issue Tracker: http://tkt56.localhost"
                echo "TKT56 Storybook:     http://tkt56-storybook.localhost"
                ;;
                
            tkt7)
                # Check if TKT7_REPO_URL is set
                if ! grep -q "TKT7_REPO_URL=" .env || grep -q "TKT7_REPO_URL=$" .env; then
                    echo "Error: TKT7_REPO_URL not provided for tkt7 app"
                    continue
                fi
                
                # Get TKT7_REPO_URL from .env file
                TKT7_REPO_URL=$(grep "^TKT7_REPO_URL=" .env | cut -d= -f2-)
                
                echo "Starting tkt7 (Redwood Blog App)..."
                echo "Using repository: $TKT7_REPO_URL"
                
                # Pass the environment variables from central .env file
                docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml --env-file .env build --no-cache
                docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml --env-file .env up -d
                
                # Show URLs right away
                echo "TKT7 Redwood Blog: http://tkt7.localhost"
                echo "TKT7 Storybook:    http://tkt7-storybook.localhost"
                ;;
        esac
    done
fi

echo ""
# Use colorize function for consistent color display
colorize "✨🔗 ${BLUE}AVAILABLE SERVICES${NC} 🔗✨"
colorize "========================================="

# Key services (always show)
colorize "${BLUE}📊 CORE SERVICES${NC}"
echo ""
colorize "  ${ORANGE}🚨 TRAEFIK UI 🚨${NC}  ${GREEN}http://traefik.localhost:8081${NC} ${ORANGE}⬅️ DASHBOARD${NC}"
echo ""
colorize "  🐬 MySQL:       http://localhost:3306"
colorize "  🌐 phpMyAdmin:  http://localhost:8080"
colorize "  ☁️  CloudBeaver: http://localhost:8978" 
echo ""

# Function to check if a container is running
is_container_running() {
    local container_name="$1"
    local compose_file="$2"
    
    if [ -n "$compose_file" ]; then
        docker-compose -f "$compose_file" ps --services --filter "status=running" 2>/dev/null | grep -q "$container_name"
    else
        docker-compose ps --services --filter "status=running" 2>/dev/null | grep -q "$container_name"
    fi
    
    return $?
}

colorize "${BLUE}🔑 DATABASE CREDENTIALS${NC}"
colorize "  👤 Username: ${GREEN}user${NC} (${ORANGE}root${NC} for admin)"
colorize "  🔒 Password: ${GREEN}password${NC} (${ORANGE}rootpassword${NC} for admin)"
colorize "  🗄️ Database: ${GREEN}app${NC}"
echo ""
colorize "${BLUE}📋 HELPFUL COMMANDS${NC}"
colorize "  📊 View logs:  ${GREEN}docker-compose logs -f [service]${NC}"
colorize "  ✅ Run tests:  ${GREEN}./test-services.sh${NC}"
colorize "  ℹ️  Get help:   ${GREEN}./start.sh --help${NC}"
colorize "========================================"

# Show consolidated summary at the very end
colorize "\n${GREEN}🚀 APPS SUMMARY 🚀${NC}"
colorize "🌟━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━🌟"

# Function to check endpoint availability with Traefik integration
check_endpoint() {
    local url="$1"
    local timeout=2  # 2 second timeout
    
    # Just return success for now to prevent hanging
    return 0
}

# Function to show app status with repo URLs
print_consolidated_summary() {
    # Load environment variables directly from the file
    source .env
    
    # Running apps counter
    local running_apps=0
    
    # Check if TKT4 is configured/running
    if [ -n "${TKT4_REPO_URL}" ] && docker-compose -f ./repos/tkt4/docker-compose.tkt4.yml ps 2>/dev/null | grep -q "tkt4"; then
        running_apps=$((running_apps+1))
        colorize "${BLUE}🎮 TKT4 - Trivia App${NC}"
        colorize "  ${GREEN}● ACTIVE${NC}    URL: ${GREEN}http://tkt4.localhost${NC}"
        colorize "  📂 REPO:      ${GREEN}${TKT4_REPO_URL}${NC}"
        colorize "  📚 Storybook: http://tkt4-storybook.localhost"
        echo ""
    fi
    
    # Check if TKT56 is configured/running
    if [ -n "${TKT56_REPO_URL}" ] && docker-compose -f ./repos/tkt56/docker-compose.tkt56.yml ps 2>/dev/null | grep -q "tkt56"; then
        running_apps=$((running_apps+1))
        colorize "${BLUE}🎯 TKT56 - Issue Tracker${NC}"
        colorize "  ${GREEN}● ACTIVE${NC}    URL: ${GREEN}http://tkt56.localhost${NC}"
        colorize "  📂 REPO:      ${GREEN}${TKT56_REPO_URL}${NC}"
        colorize "  📚 Storybook: http://tkt56-storybook.localhost"
        echo ""
    fi
    
    # Check if TKT7 is configured/running
    if [ -n "${TKT7_REPO_URL}" ] && docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml ps 2>/dev/null | grep -q "tkt7"; then
        running_apps=$((running_apps+1))
        colorize "${BLUE}📝 TKT7 - Redwood Blog${NC}"
        colorize "  ${GREEN}● ACTIVE${NC}    URL: ${GREEN}http://tkt7.localhost${NC}"
        colorize "  📂 REPO:      ${GREEN}${TKT7_REPO_URL}${NC}"
        colorize "  📚 Storybook: http://tkt7-storybook.localhost"
        echo ""
    fi
    
    # Check if dev container is running
    if docker-compose ps 2>/dev/null | grep -q "web"; then
        running_apps=$((running_apps+1))
        colorize "${BLUE}🚀 Development Container${NC}"
        colorize "  ${GREEN}● ACTIVE${NC}    URL: ${GREEN}http://dev.localhost${NC}"
        colorize "  📂 REPO:      ${GREEN}${REPO_URL}${NC}"
        colorize "  📚 Storybook: http://storybook.localhost"
        echo ""
    fi
    
    # If no apps are running, show a message
    if [ "$running_apps" -eq 0 ]; then
        colorize "${ORANGE}No applications are currently running.${NC}"
        colorize "Try starting an app with: ${GREEN}./start.sh [app-name]${NC}"
        colorize "See options with:         ${GREEN}./start.sh --help${NC}"
    fi
}

print_consolidated_summary
colorize "🌟━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━🌟"

# Reminder about Traefik dashboard at the very end
colorize "\n${ORANGE}💻 Don't forget! Traefik Dashboard: ${GREEN}http://traefik.localhost:8081${NC} 🔍"

# Create test script to verify services
cat > test-services.sh << 'EOF'
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "Testing services..."

# Check if /etc/hosts has needed entries
if ! grep -q "dev.localhost" /etc/hosts; then
    echo -e "${YELLOW}WARNING:${NC} Your /etc/hosts file doesn't have entries for .localhost domains"
    echo "You should run: sudo ./setup-hosts.sh"
fi

# Always test infrastructure services
echo -e "\n${GREEN}Testing Infrastructure Services:${NC}"

# Check if Traefik service is healthy
echo -n "Testing Traefik Dashboard (http://traefik.localhost:8081): "
if curl -s --head --request GET --connect-timeout 2 http://traefik.localhost:8081 | grep "200\|304" > /dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC} (Make sure you've run setup-hosts.sh)"
    traefik_failed=true
fi

# Check if phpMyAdmin service is healthy
echo -n "Testing phpMyAdmin service (http://localhost:8080): "
if curl -s --head --request GET --connect-timeout 2 http://localhost:8080 | grep "200\|304" > /dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    phpmyadmin_failed=true
fi

# Check if CloudBeaver service is healthy
echo -n "Testing CloudBeaver service (http://localhost:8978): "
if curl -s --head --request GET --connect-timeout 2 http://localhost:8978 | grep "200\|304" > /dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
    cloudbeaver_failed=true
fi

# Test for Development container services
if docker-compose ps | grep -q "web"; then
    echo -e "\n${GREEN}Testing Development Container Services:${NC}"
    echo -n "Testing Development App (http://dev.localhost): "
    if curl -s --head --request GET --connect-timeout 2 http://dev.localhost | grep "200\|304" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        services_failed=true
    fi

    echo -n "Testing Development Storybook (http://storybook.localhost): "
    if curl -s --head --request GET --connect-timeout 2 http://storybook.localhost | grep "200\|304" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        services_failed=true
    fi
fi

# Test TKT4 services
if docker-compose -f ./repos/tkt4/docker-compose.tkt4.yml ps 2>/dev/null | grep -q "tkt4"; then
    echo -e "\n${GREEN}Testing TKT4 Services:${NC}"
    echo -n "Testing TKT4 app (http://tkt4.localhost): "
    if curl -s --head --request GET --connect-timeout 2 http://tkt4.localhost | grep "200\|304" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        services_failed=true
    fi

    if docker-compose -f ./repos/tkt4/docker-compose.tkt4.yml ps | grep -q "tkt4-storybook"; then
        echo -n "Testing TKT4 storybook (http://tkt4-storybook.localhost): "
        if curl -s --head --request GET --connect-timeout 2 http://tkt4-storybook.localhost | grep "200\|304" > /dev/null; then
            echo -e "${GREEN}PASS${NC}"
        else
            echo -e "${RED}FAIL${NC}"
            services_failed=true
        fi
    fi
fi

# Test TKT56 services
if docker-compose -f ./repos/tkt56/docker-compose.tkt56.yml ps 2>/dev/null | grep -q "tkt56"; then
    echo -e "\n${GREEN}Testing TKT56 Services:${NC}"
    echo -n "Testing TKT56 app (http://tkt56.localhost): "
    if curl -s --head --request GET --connect-timeout 2 http://tkt56.localhost | grep "200\|304" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        services_failed=true
    fi

    if docker-compose -f ./repos/tkt56/docker-compose.tkt56.yml ps | grep -q "tkt56-storybook"; then
        echo -n "Testing TKT56 storybook (http://tkt56-storybook.localhost): "
        if curl -s --head --request GET --connect-timeout 2 http://tkt56-storybook.localhost | grep "200\|304" > /dev/null; then
            echo -e "${GREEN}PASS${NC}"
        else
            echo -e "${RED}FAIL${NC}"
            services_failed=true
        fi
    fi
fi

# Test TKT7 services
if docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml ps 2>/dev/null | grep -q "tkt7"; then
    echo -e "\n${GREEN}Testing TKT7 Services:${NC}"
    echo -n "Testing TKT7 app (http://tkt7.localhost): "
    if curl -s --head --request GET --connect-timeout 2 http://tkt7.localhost | grep "200\|304" > /dev/null; then
        echo -e "${GREEN}PASS${NC}"
    else
        echo -e "${RED}FAIL${NC}"
        services_failed=true
    fi

    if docker-compose -f ./repos/tkt7/docker-compose.tkt7.yml ps | grep -q "tkt7-storybook"; then
        echo -n "Testing TKT7 storybook (http://tkt7-storybook.localhost): "
        if curl -s --head --request GET --connect-timeout 2 http://tkt7-storybook.localhost | grep "200\|304" > /dev/null; then
            echo -e "${GREEN}PASS${NC}"
        else
            echo -e "${RED}FAIL${NC}"
            services_failed=true
        fi
    fi
fi

# Check Docker health status
echo -e "\n${GREEN}Docker service health status:${NC}"
docker-compose ps
echo ""
for app in tkt4 tkt56 tkt7; do
    if [ -f "./repos/$app/docker-compose.$app.yml" ]; then
        if docker-compose -f "./repos/$app/docker-compose.$app.yml" ps -q 2>/dev/null | grep -q .; then
            echo "$app services:"
            docker-compose -f "./repos/$app/docker-compose.$app.yml" ps
            echo ""
        fi
    fi
done

echo -e "\n${GREEN}Detailed health checks:${NC}"
# Get all containers from all compose files
all_containers=$(docker ps --format "{{.ID}}")
for container in $all_containers; do
    name=$(docker inspect --format='{{.Name}}' $container | sed 's/\///')
    health=$(docker inspect --format='{{json .State.Health}}' $container 2>/dev/null)
    if [ $? -eq 0 ] && [ "$health" != "null" ]; then
        status=$(echo $health | jq -r '.Status')
        echo -e "$name health status: $(if [ "$status" = "healthy" ]; then echo -e "${GREEN}$status${NC}"; else echo -e "${RED}$status${NC}"; fi)"
        echo "Last check: $(echo $health | jq -r '.Log[-1].Output')"
    else
        echo -e "$name: ${RED}No health check configured${NC}"
    fi
done

# Exit with error if any service failed
if [ "$phpmyadmin_failed" = true ] || [ "$cloudbeaver_failed" = true ] || [ "$services_failed" = true ]; then
    echo -e "\n${RED}Some services failed the health check${NC}"
    exit 1
else
    echo -e "\n${GREEN}All services passed health checks${NC}"
    exit 0
fi
EOF

chmod +x test-services.sh
echo "Created test script: test-services.sh"
echo "Run './test-services.sh' after services have started to verify they're working"