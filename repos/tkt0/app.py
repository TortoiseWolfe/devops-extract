from flask import Flask, render_template, jsonify
import os
import platform
import socket
import datetime

app = Flask(__name__)

# Fallback HTML for when template doesn't exist
FALLBACK_HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>Python Advanced Problem Solving</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; padding: 20px; max-width: 800px; margin: 0 auto; }
        h1 { color: #3776ab; }
        .card { background: #f5f9fc; padding: 15px; margin-bottom: 15px; border-radius: 5px; }
        .info-item { margin-bottom: 8px; }
        .label { font-weight: bold; color: #3776ab; }
        a { color: #3776ab; text-decoration: none; margin-right: 15px; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>Python Advanced Problem Solving Environment</h1>
    
    <div class="card">
        <h2>Environment Information</h2>
        <div class="info-item"><span class="label">Python Version:</span> {python_version}</div>
        <div class="info-item"><span class="label">Platform:</span> {platform}</div>
        <div class="info-item"><span class="label">Hostname:</span> {hostname}</div>
        <div class="info-item"><span class="label">Current Time:</span> {current_time}</div>
        <div class="info-item"><span class="label">Environment:</span> {environment}</div>
    </div>
    
    <div class="card">
        <h2>Available Resources</h2>
        <p>
            <a href="/api/info">API Environment Info</a>
            <a href="/api/exercises">Python Exercises API</a>
            <a href="http://localhost:8888">Jupyter Notebook</a>
        </p>
    </div>
    
    <div class="card">
        <h2>Getting Started</h2>
        <p>
            Welcome to the Python Advanced Problem Solving environment! This container provides
            everything you need to learn and practice Python programming.
        </p>
        <p>
            The environment includes popular libraries like Flask, Pandas, NumPy, Matplotlib, and scikit-learn.
            You can use the Jupyter Notebook for interactive coding and exploration.
        </p>
    </div>
</body>
</html>
"""

@app.route('/')
def home():
    """Render the home page with Python environment information"""
    data = {
        'python_version': platform.python_version(),
        'platform': platform.platform(),
        'hostname': socket.gethostname(),
        'current_time': datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'environment': os.environ.get('FLASK_ENV', 'development'),
    }
    
    try:
        return render_template('index.html', data=data)
    except:
        # Fallback to inline HTML if template doesn't exist
        return FALLBACK_HTML.format(
            python_version=data['python_version'],
            platform=data['platform'],
            hostname=data['hostname'],
            current_time=data['current_time'],
            environment=data['environment']
        )

@app.route('/api/info')
def api_info():
    """Return Python environment information as JSON"""
    data = {
        'python_version': platform.python_version(),
        'platform': platform.platform(),
        'hostname': socket.gethostname(),
        'current_time': datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'libraries': {
            'flask': 'installed',
            'pandas': 'installed',
            'numpy': 'installed',
            'matplotlib': 'installed',
            'scikit-learn': 'installed'
        }
    }
    return jsonify(data)

@app.route('/api/exercises')
def api_exercises():
    """Return available Python exercises"""
    exercises = [
        {
            'id': 1,
            'title': 'Hello World',
            'difficulty': 'Beginner',
            'description': 'Print "Hello, World!" to the console'
        },
        {
            'id': 2,
            'title': 'Data Analysis with Pandas',
            'difficulty': 'Intermediate',
            'description': 'Analyze a CSV dataset using pandas'
        },
        {
            'id': 3,
            'title': 'Machine Learning Classification',
            'difficulty': 'Advanced',
            'description': 'Build a classification model using scikit-learn'
        }
    ]
    return jsonify(exercises)

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)