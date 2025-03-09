#!/bin/bash

# Check if repository URL is provided as argument
if [ "$1" ]; then
    # Update .env file with the provided repository URL
    if [ -f .env ]; then
        sed -i "s|REPO_URL=.*|REPO_URL=$1|g" .env
    else
        echo "REPO_URL=$1" > .env
    fi
    echo "Repository URL set to: $1"
else
    # Check if .env file exists and REPO_URL is set
    if [ -f .env ] && grep -q "REPO_URL=" .env && ! grep -q "REPO_URL=$" .env; then
        echo "Using repository URL from .env file"
    else
        echo "Error: Repository URL not provided"
        echo "Usage: ./start.sh https://github.com/username/repo.git"
        exit 1
    fi
fi

# Start the containers
echo "Starting containers..."
docker-compose down
docker-compose build --no-cache
docker-compose up -d

echo ""
echo "React app running at: http://localhost:5173"
echo "Storybook running at: http://localhost:6006"