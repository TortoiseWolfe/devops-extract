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
