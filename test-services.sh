#!/bin/bash

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}Testing services...${NC}"

# Test core infrastructure services
echo -e "\n${BLUE}Testing Core Infrastructure:${NC}"

# Check if Traefik service is healthy
echo -n "Testing Traefik Dashboard (http://localhost:8081): "
if curl -s --head --request GET --connect-timeout 2 http://localhost:8081 | grep "200\|304" > /dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
fi

# Check if phpMyAdmin service is healthy
echo -n "Testing phpMyAdmin service (http://localhost:8080): "
if curl -s --head --request GET --connect-timeout 2 http://localhost:8080 | grep "200\|304" > /dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
fi

# Check if CloudBeaver service is healthy
echo -n "Testing CloudBeaver service (http://localhost:8978): "
if curl -s --head --request GET --connect-timeout 2 http://localhost:8978 | grep "200\|304" > /dev/null; then
    echo -e "${GREEN}PASS${NC}"
else
    echo -e "${RED}FAIL${NC}"
fi

# Test application services if they are running
for app in tkt0 mod0 tkt4 tkt56 tkt7; do
    if docker ps | grep -q "devops-$app"; then
        echo -e "\n${BLUE}Testing $app services:${NC}"
        echo -n "Testing $app main service (http://$app.localhost): "
        if curl -s --head --request GET --connect-timeout 2 "http://$app.localhost" | grep "200\|304" > /dev/null; then
            echo -e "${GREEN}PASS${NC}"
        else
            echo -e "${RED}FAIL${NC}"
        fi
        
        # Test specific ports for each app based on requirements
        case "$app" in
            tkt0)
                # Test Flask and Jupyter
                echo -n "Testing TKT0 Flask (http://localhost:5000): "
                curl -s --head --request GET --connect-timeout 2 "http://localhost:5000" | grep "200\|304" > /dev/null && \
                echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}"
                
                echo -n "Testing TKT0 Jupyter (http://localhost:8888): "
                curl -s --head --request GET --connect-timeout 2 "http://localhost:8888" | grep "200\|304" > /dev/null && \
                echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}"
                ;;
            mod0)
                # Test Flask and Jupyter
                echo -n "Testing MOD0 Flask (http://localhost:5001): "
                curl -s --head --request GET --connect-timeout 2 "http://localhost:5001" | grep "200\|304" > /dev/null && \
                echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}"
                
                echo -n "Testing MOD0 Jupyter (http://localhost:8889): "
                curl -s --head --request GET --connect-timeout 2 "http://localhost:8889" | grep "200\|304" > /dev/null && \
                echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}"
                ;;
            tkt7)
                # Test Redwood API server
                echo -n "Testing TKT7 API (http://localhost:8911): "
                curl -s --head --request GET --connect-timeout 2 "http://localhost:8911" | grep "200\|304" > /dev/null && \
                echo -e "${GREEN}PASS${NC}" || echo -e "${RED}FAIL${NC}"
                ;;
        esac
    fi
done

# Show Docker container status
echo -e "\n${BLUE}Docker container status:${NC}"
docker ps

# Show memory usage with total calculation
echo -e "\n${BLUE}Memory Usage:${NC}"

# Get memory usage data
mem_data=$(docker stats --no-stream --format "{{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}")

# Display the data in a formatted table with a header
echo -e "CONTAINER\tMEMORY USAGE\tMEMORY %"
echo "$mem_data" | while IFS=$'\t' read -r name usage percent; do
    echo -e "$name\t$usage\t$percent"
done

# Calculate and display total memory usage
total_mem_mb=$(echo "$mem_data" | awk '{split($2, a, " / "); sum += a[1]} END {print sum}' | sed 's/MiB//')
system_mem_mb=$(free -m | awk '/^Mem:/ {print $2}')
mem_percent=$(awk "BEGIN {printf \"%.1f\", (${total_mem_mb} / ${system_mem_mb}) * 100}")

# Determine if memory usage is excessive
if (( $(echo "$mem_percent > 70" | bc -l) )); then
    mem_color=$RED
    mem_warning=" (WARNING: High memory usage!)"
elif (( $(echo "$mem_percent > 50" | bc -l) )); then
    mem_color=$RED
    mem_warning=" (Consider shutting down unused containers)"
else
    mem_color=$GREEN
    mem_warning=""
fi

echo -e "\n${BLUE}Total Memory Usage: ${mem_color}${total_mem_mb} MiB / ${system_mem_mb} MiB (${mem_percent}%)${mem_warning}${NC}"

echo -e "\n${BLUE}Test completed.${NC}"