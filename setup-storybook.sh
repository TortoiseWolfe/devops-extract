#!/bin/sh

# Check for package.json
if [ ! -f package.json ]; then
  echo "ERROR: No package.json found. Please provide a valid REPO_URL."
  exit 1
fi

# Make sure storybook is installed
if ! npm list storybook >/dev/null 2>&1; then
  echo "Installing Storybook dependencies..."
  npm install --save-dev storybook @storybook/react-vite @storybook/addon-essentials @storybook/addon-interactions
fi

# Create basic config if not present
if [ ! -d ".storybook" ] && [ ! -d "storybook" ]; then
  echo "Creating basic Storybook configuration..."
  mkdir -p .storybook
  cat > .storybook/main.js << EOL
import { join, dirname } from "path";

export default {
  framework: {
    name: "@storybook/react-vite",
    options: {}
  },
  stories: ["../src/**/*.stories.@(js|jsx|ts|tsx|mdx)"],
  addons: ["@storybook/addon-essentials"]
};
EOL
fi

# If .storybook exists but missing framework field, update it
if [ -d ".storybook" ] && ! grep -q "framework" .storybook/main.js; then
  echo "Updating Storybook configuration with framework field..."
  # Determine framework based on dependencies
  if grep -q "react" package.json; then
    FRAMEWORK="@storybook/react-vite"
  elif grep -q "vue" package.json; then
    FRAMEWORK="@storybook/vue3-vite"
  else
    FRAMEWORK="@storybook/react-vite"
  fi
  # Install the framework
  npm install --save-dev $FRAMEWORK
  
  # Run automigrate to fix configuration
  npx storybook automigrate --yes
fi

echo "Starting Storybook..."
npx storybook dev --port 6006 --host 0.0.0.0 --ci