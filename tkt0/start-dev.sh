#!/bin/bash

# Display welcome message
echo "=================================================="
echo "  Python Development Environment"
echo "=================================================="
echo "- Your code is in /workspace/code"
echo "- Data files are in /workspace/data"
echo "- SSH keys should be mounted in /workspace/.ssh"
echo ""
echo "To pull from your repository:"
echo "  cd /workspace/code"
echo "  git clone <YOUR_REPO_URL> ."
echo ""
echo "To start Flask app:"
echo "  cd /workspace/code"
echo "  flask run --host=0.0.0.0"
echo ""
echo "To start Jupyter Lab:"
echo "  cd /workspace/code"
echo "  jupyter lab --ip=0.0.0.0 --no-browser --allow-root"
echo "=================================================="

# Start Jupyter Lab in the background if requested
if [ "$START_JUPYTER" = "true" ]; then
  echo "Starting Jupyter Lab in background..."
  cd /workspace/code
  jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root &
fi

# Start Flask if requested
if [ "$START_FLASK" = "true" ]; then
  echo "Starting Flask in background..."
  cd /workspace/code
  if [ -f "app.py" ]; then
    export FLASK_APP=app.py
    flask run --host=0.0.0.0 &
  else
    echo "No app.py found in /workspace/code"
  fi
fi

# Clone repository if provided
if [ -n "$TKT0_REPO_URL" ]; then
  # Check if there's a .git directory
  if [ -d "/workspace/code/.git" ]; then
    echo "Repository already exists, pulling latest changes..."
    cd /workspace/code
    git pull
  else
    # If code directory contains files (except .git), move them to backup then clone
    if [ "$(ls -A /workspace/code)" ]; then
      echo "Backing up existing files before cloning repository..."
      mkdir -p /workspace/backup
      cp -r /workspace/code/* /workspace/backup/ 2>/dev/null || true
      cp -r /workspace/code/.* /workspace/backup/ 2>/dev/null || true
      find /workspace/code -mindepth 1 -delete
    fi
    echo "Cloning repository from $TKT0_REPO_URL..."
    git clone "$TKT0_REPO_URL" /workspace/code
    
    # If the repository was empty, restore template files
    if [ ! "$(find /workspace/code -type f -not -path '*/\.git/*' | wc -l)" -gt 0 ]; then
      echo "Repository appears to be empty, creating starter application..."
      # We'll keep .git so student can push changes back
    fi
  fi
else
  echo "No repository URL provided, using starter template..."
fi

# Create a default app.py and templates if directory is empty or missing vital files
if [ ! -f "/workspace/code/app.py" ]; then
  echo "Creating starter Flask application..."
  mkdir -p /workspace/code/templates /workspace/code/static/css
  
  # Create app.py
  cat > /workspace/code/app.py << 'EOF'
from flask import Flask, render_template
app = Flask(__name__)

@app.route('/')
def home():
    return render_template('index.html', title="Welcome to Flask")

@app.route('/tutorial')
def tutorial():
    return render_template('tutorial.html', title="Flask Tutorial")

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
EOF
  
  # Create index.html
  cat > /workspace/code/templates/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
</head>
<body>
    <div class="container">
        <h1>Welcome to Your Python Development Environment!</h1>
        <div class="card">
            <h2>Getting Started</h2>
            <p>This is your starter Flask application. Edit the files in <code>/workspace/code</code> to customize your app.</p>
            <p>Visit <a href="/tutorial">the tutorial page</a> for more information on how to develop with Flask.</p>
        </div>
        
        <div class="card">
            <h2>Development Workflow</h2>
            <ol>
                <li>Edit the code in the mounted volume</li>
                <li>Flask will automatically reload when you save changes</li>
                <li>Access Jupyter at <a href="http://jupyter.localhost" target="_blank">http://jupyter.localhost</a></li>
            </ol>
        </div>
        
        <div class="card">
            <h2>Using Git</h2>
            <p>To push your changes to your own repository:</p>
            <div class="code-container">
                <button class="copy-button" onclick="copyCode(this)">Copy</button>
                <pre>
cd /workspace/code
git init
git add .
git commit -m "Initial commit"
git remote add origin YOUR_REPOSITORY_URL
git push -u origin main</pre>
            </div>
        </div>
    </div>
    <script>
        function copyCode(button) {
            const pre = button.nextElementSibling;
            const code = pre.textContent;
            
            navigator.clipboard.writeText(code).then(() => {
                // Change button text to "Copied!"
                button.textContent = "Copied!";
                
                // Reset button text after 2 seconds
                setTimeout(() => {
                    button.textContent = "Copy";
                }, 2000);
            }).catch(err => {
                console.error('Failed to copy text: ', err);
                alert('Failed to copy code');
            });
        }
    </script>
</body>
</html>
EOF

  # Create tutorial.html
  cat > /workspace/code/templates/tutorial.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>{{ title }}</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
</head>
<body>
    <div class="container">
        <h1>Flask Tutorial</h1>
        <p><a href="/">&larr; Back to Home</a></p>
        
        <div class="card">
            <h2>Flask Basics</h2>
            <p>Flask is a lightweight web framework for Python. Here are some key concepts:</p>
            <ul>
                <li><strong>Routes</strong>: Define URL patterns that your app responds to</li>
                <li><strong>Templates</strong>: HTML files with placeholders for dynamic content</li>
                <li><strong>Static Files</strong>: CSS, JavaScript, and images</li>
            </ul>
        </div>
        
        <div class="card">
            <h2>Project Structure</h2>
            <pre>
/workspace/code/
  ├── app.py           # Main application file
  ├── static/          # Static assets
  │   └── css/         # CSS files
  │       └── style.css
  └── templates/       # HTML templates
      ├── index.html   # Home page
      └── tutorial.html # This page
            </pre>
        </div>
        
        <div class="card">
            <h2>Adding a New Page</h2>
            <p>To add a new page:</p>
            <ol>
                <li>Create a new HTML file in the templates folder</li>
                <li>Add a new route in app.py</li>
                <li>Link to your new page from existing pages</li>
            </ol>
            <p>Example route in app.py:</p>
            <div class="code-container">
                <button class="copy-button" onclick="copyCode(this)">Copy</button>
                <pre>
@app.route('/newpage')
def newpage():
    return render_template('newpage.html', title="New Page")</pre>
            </div>
        </div>
    </div>
    <script>
        function copyCode(button) {
            const pre = button.nextElementSibling;
            const code = pre.textContent;
            
            navigator.clipboard.writeText(code).then(() => {
                // Change button text to "Copied!"
                button.textContent = "Copied!";
                
                // Reset button text after 2 seconds
                setTimeout(() => {
                    button.textContent = "Copy";
                }, 2000);
            }).catch(err => {
                console.error('Failed to copy text: ', err);
                alert('Failed to copy code');
            });
        }
    </script>
</body>
</html>
EOF

  # Create a basic CSS file
  cat > /workspace/code/static/css/style.css << 'EOF'
body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    margin: 0;
    padding: 20px;
    background-color: #f5f5f5;
}

.container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px;
}

h1 {
    color: #333;
    border-bottom: 2px solid #4CAF50;
    padding-bottom: 10px;
}

h2 {
    color: #4CAF50;
}

.card {
    background: white;
    border-radius: 5px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

code, pre {
    background: #f4f4f4;
    border: 1px solid #ddd;
    border-radius: 3px;
    padding: 2px 5px;
    font-family: monospace;
    font-size: 14px;
}

pre {
    padding: 10px;
    white-space: pre-wrap;
    margin: 0;
}

a {
    color: #0066cc;
    text-decoration: none;
}

a:hover {
    text-decoration: underline;
}

ol, ul {
    margin-left: 20px;
}

.code-container {
    position: relative;
    background: #f4f4f4;
    border: 1px solid #ddd;
    border-radius: 3px;
    padding: 10px;
    margin: 10px 0;
}

.copy-button {
    position: absolute;
    top: 5px;
    right: 5px;
    background: #4CAF50;
    color: white;
    border: none;
    border-radius: 3px;
    padding: 5px 10px;
    cursor: pointer;
    font-size: 12px;
}

.copy-button:hover {
    background: #45a049;
}
EOF

  echo "Starter application created successfully!"
fi

# Keep container running
echo "Development environment is ready!"
tail -f /dev/null