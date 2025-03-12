FROM python:3.10-slim

WORKDIR /workspace

# Install essential packages for Python development
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    ssh \
    vim \
    nano \
    iputils-ping \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for data science and web development
RUN pip install --no-cache-dir \
    flask \
    flask-cors \
    flask-sqlalchemy \
    flask-migrate \
    requests \
    pytest \
    python-dotenv \
    gunicorn \
    pandas \
    numpy \
    matplotlib \
    scikit-learn \
    jupyterlab \
    black \
    flake8 \
    mypy

# Create development directories
RUN mkdir -p /workspace/code /workspace/data /workspace/.ssh

# Configure git
RUN git config --global init.defaultBranch main && \
    git config --global core.editor "vim"

# Set correct permissions
RUN chmod -R 777 /workspace

# Create startup script
RUN echo '#!/bin/bash\n\
echo "=================================================="\n\
echo "  Python Module Development Environment (MOD0)"\n\
echo "=================================================="\n\
echo "- Your code is in /workspace/code"\n\
echo "- Data files are in /workspace/data"\n\
echo "- SSH keys should be mounted in /workspace/.ssh"\n\
echo ""\n\
\n\
# Setup Git configuration from environment variables\n\
if [ -n "$GIT_USER_NAME" ] && [ -n "$GIT_USER_EMAIL" ]; then\n\
  echo "Setting up Git configuration:"\n\
  echo "  User: $GIT_USER_NAME"\n\
  echo "  Email: $GIT_USER_EMAIL"\n\
  git config --global user.name "$GIT_USER_NAME"\n\
  git config --global user.email "$GIT_USER_EMAIL"\n\
  echo "Git configuration set successfully"\n\
else\n\
  echo "Git user configuration not provided in .env file"\n\
fi\n\
\n\
# Debug environment variables\n\
echo "Environment variable check:"\n\
echo "MOD0_REPO_URL='$MOD0_REPO_URL'"\n\
env | grep -E "MOD0|GIT_USER"\n\
cat /workspace/.env 2>/dev/null || echo "No .env file in /workspace"\n\
\n\
# Clone repository if provided - must happen BEFORE starting services\n\
if [ -n "$MOD0_REPO_URL" ]; then\n\
  echo "Repository URL is set: $MOD0_REPO_URL"\n\
  if [ ! -d "/workspace/code/.git" ]; then\n\
    if [ "$(ls -A /workspace/code)" ]; then\n\
      echo "Backing up existing files..."\n\
      mkdir -p /workspace/backup\n\
      cp -r /workspace/code/* /workspace/backup/ 2>/dev/null || true\n\
      find /workspace/code -mindepth 1 -not -path "*/\\.*" -delete\n\
    fi\n\
    echo "Cloning repository from $MOD0_REPO_URL..."\n\
    git clone "$MOD0_REPO_URL" /workspace/code\n\
  fi\n\
else\n\
  echo "WARNING: MOD0_REPO_URL is empty or not set"\n\
fi\n\
\n\
# Check for app.py and create if needed\n\
if [ ! -f "/workspace/code/app.py" ]; then\n\
  echo "No app.py found after repository setup. Creating starter Flask application..."\n\
  mkdir -p /workspace/code/templates /workspace/code/static/css\n\
  \n\
  # Copy our app.py file from the repository\n\
  cp -f /workspace/mod0/app.py /workspace/code/app.py || echo \"Warning: Could not copy app.py from mod0 directory\"\n\
  \n\
  # Set up template and static directories in code\n\
  mkdir -p /workspace/code/templates /workspace/code/static/css\n\
  \n\
  # Copy our templates from the mounted mod0 directory\n\
  cp -f /workspace/mod0/templates/* /workspace/code/templates/ 2>/dev/null || echo \"Warning: No template files found in /workspace/mod0/templates\"\n\
  cp -f /workspace/mod0/static/css/* /workspace/code/static/css/ 2>/dev/null || echo \"Warning: No CSS files found in /workspace/mod0/static/css\"\n\
fi\n\
\n\
# NOW start services after repository and files are prepared\n\
if [ "$START_JUPYTER" = "true" ]; then\n\
  echo "Starting Jupyter Lab in background..."\n\
  cd /workspace/code\n\
  jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root &\n\
fi\n\
\n\
if [ "$START_FLASK" = "true" ]; then\n\
  echo "Starting Flask in background..."\n\
  cd /workspace/code\n\
  if [ -f "app.py" ]; then\n\
    export FLASK_APP=app.py\n\
    export MOD0_REPO_URL="$MOD0_REPO_URL"\n\
    flask run --host=0.0.0.0 &\n\
    echo "Flask started successfully on port 5000"\n\
  else\n\
    echo "ERROR: No app.py found in /workspace/code - Flask cannot start!"\n\
  fi\n\
fi\n\
\n\
echo "Development environment is ready!"\n\
tail -f /dev/null\n\
' > /usr/local/bin/dev-startup.sh
RUN chmod +x /usr/local/bin/dev-startup.sh

# Keep container running for SSH access
CMD ["/usr/local/bin/dev-startup.sh"]
