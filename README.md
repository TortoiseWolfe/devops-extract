# DevOps Multi-App Development Environment

A Docker-based development environment for multiple applications with shared infrastructure. All application code is pulled from external repositories.

## Core Features

- **Repository-First Architecture**: All applications are imported from external Git repositories
- **Shared Infrastructure**: MySQL, phpMyAdmin, CloudBeaver, and Traefik
- **Standardized App Integration**: Consistent pattern for all applications
- **Resource Management**: Selective startup and monitoring

## Getting Started

1. Configure repository URLs in `.env` file:
   ```
   TKT0_REPO_URL=https://github.com/yourusername/python-learning
   TKT4_REPO_URL=https://github.com/yourusername/react-trivia
   TKT56_REPO_URL=https://github.com/yourusername/nextjs-tutorial
   TKT7_REPO_URL=https://github.com/yourusername/redwoodblog
   ```

2. Start the environment:
   ```
   ./start.sh --all     # Start all configured apps
   ./start.sh tkt0      # Start only TKT0 (Python development environment)
   ./start.sh tkt4      # Start only TKT4 (React Trivia app)
   ```

3. Verify services:
   ```
   ./test-services.sh
   ```

## Python Learning Environment (TKT0)

Our Python environment (TKT0) provides a full Flask and Jupyter setup for learning Python and web development.

### Getting Started with Flask

1. **Start the Python environment**:
   ```
   ./start.sh tkt0
   ```

2. **Access the Web Interface**:
   - Open http://localhost:5000 in your browser
   - You'll see the welcome page with setup instructions

### Step-by-Step Tutorial: Building Your First Flask App

Once the environment is running, follow these steps to create a simple Flask app:

1. **Create a Basic Flask File**:
   ```bash
   # Access the container shell
   docker exec -it devops-tkt0-dev bash
   
   # Navigate to your code directory
   cd /workspace/code
   
   # Create hello.py with a text editor
   nano hello.py
   ```

   Add this code to your file:
   ```python
   from flask import Flask

   app = Flask(__name__)

   @app.route('/')
   def hello_world():
       return 'Hello, World! My first Flask app.'

   if __name__ == '__main__':
       app.run(debug=True, host='0.0.0.0')
   ```

2. **Run Your App**:
   ```bash
   python hello.py
   ```
   Visit http://localhost:5000 to see your app!

3. **Add HTML Templates**:
   ```bash
   # Create a templates folder
   mkdir -p templates
   
   # Create an HTML template
   nano templates/hello.html
   ```

   Add this HTML code:
   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <title>My First Flask App</title>
       <style>
           body {
               font-family: Arial, sans-serif;
               margin: 0;
               padding: 30px;
               background-color: #f5f5f5;
           }
           .container {
               max-width: 800px;
               margin: 0 auto;
               background-color: white;
               padding: 20px;
               border-radius: 10px;
               box-shadow: 0 2px 4px rgba(0,0,0,0.1);
           }
           h1 {
               color: #4285f4;
           }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>Hello, World!</h1>
           <p>My name is <strong>{{ name }}</strong> and this is my first Flask app!</p>
           <p>The current time is: <strong>{{ current_time }}</strong></p>
       </div>
   </body>
   </html>
   ```

4. **Update Your Flask App to Use Templates**:
   ```bash
   nano hello.py
   ```

   Replace the content with:
   ```python
   from flask import Flask, render_template
   from datetime import datetime

   app = Flask(__name__)

   @app.route('/')
   def hello_world():
       # Get the current time
       now = datetime.now().strftime("%H:%M:%S")
       
       # Your name - change this!
       your_name = "Python Beginner"
       
       # Render the HTML template with variables
       return render_template('hello.html', name=your_name, current_time=now)

   if __name__ == '__main__':
       app.run(debug=True, host='0.0.0.0')
   ```

5. **Run your updated app**:
   ```bash
   python hello.py
   ```

### Building a Form-Based Application

Let's make your app interactive by adding a form:

1. **Create a Form Template**:
   ```bash
   nano templates/form.html
   ```

   Add this HTML code:
   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <title>My Flask Form</title>
       <style>
           body {
               font-family: Arial, sans-serif;
               margin: 0;
               padding: 30px;
               background-color: #f5f5f5;
           }
           .container {
               max-width: 800px;
               margin: 0 auto;
               background-color: white;
               padding: 20px;
               border-radius: 10px;
               box-shadow: 0 2px 4px rgba(0,0,0,0.1);
           }
           h1 { color: #4285f4; }
           form { margin: 20px 0; }
           input[type="text"] {
               padding: 8px;
               width: 300px;
               border: 1px solid #ddd;
               border-radius: 4px;
           }
           button {
               padding: 8px 16px;
               background-color: #4285f4;
               color: white;
               border: none;
               border-radius: 4px;
               cursor: pointer;
           }
           .result {
               margin-top: 20px;
               padding: 15px;
               background-color: #e8f0fe;
               border-radius: 4px;
           }
       </style>
   </head>
   <body>
       <div class="container">
           <h1>Message Generator</h1>
           
           <form method="POST">
               <input type="text" name="name" placeholder="Enter your name" required>
               <button type="submit">Generate Message</button>
           </form>
           
           {% if message %}
           <div class="result">
               <p>{{ message }}</p>
           </div>
           {% endif %}
           
           <p><a href="/">Go back to homepage</a></p>
       </div>
   </body>
   </html>
   ```

2. **Update Your Flask App**:
   ```bash
   nano hello.py
   ```

   Replace the content with:
   ```python
   from flask import Flask, render_template, request
   from datetime import datetime

   app = Flask(__name__)

   @app.route('/')
   def hello_world():
       # Get the current time
       now = datetime.now().strftime("%H:%M:%S")
       
       # Your name - change this!
       your_name = "Python Beginner"
       
       # Render the HTML template with variables
       return render_template('hello.html', name=your_name, current_time=now)

   @app.route('/form', methods=['GET', 'POST'])
   def form():
       message = None
       
       # Check if the form was submitted (POST request)
       if request.method == 'POST':
           # Get the name from the form
           name = request.form.get('name', '')
           
           # Generate a message
           message = f"Hello {name}! Welcome to Flask. The time is {datetime.now().strftime('%H:%M:%S')}"
       
       # Render the form template
       return render_template('form.html', message=message)

   if __name__ == '__main__':
       app.run(debug=True, host='0.0.0.0')
   ```

3. **Add a Link to the Form**:
   ```bash
   nano templates/hello.html
   ```

   Update your hello.html to include a menu:
   ```html
   <div class="menu">
       <a href="/form">Try our message generator</a>
   </div>
   ```

4. **Run your updated app**:
   ```bash
   python hello.py
   ```

### Pushing Your Code to GitHub

1. **Configure Git in the container**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your_email@example.com"
   ```

2. **Initialize and commit your code**:
   ```bash
   cd /workspace/code
   git init
   git add .
   git commit -m "Add form handling to my Flask app"
   git remote add origin git@github.com:yourusername/flask-app.git
   git push -u origin main
   ```

## Other Applications

### TKT4: React Trivia App
- Clones your React app repo and runs it
- Available at http://localhost:5174
- Development workflow:
  1. Start the container: `./start.sh tkt4`
  2. Access the container: `docker exec -it devops-tkt4-dev bash`
  3. Navigate to your code: `cd /workspace/code`
  4. Your code can be accessed from the host at `./tkt4/code/`

### TKT56: Next.js Issue Tracker
- Clones your Next.js app repo and runs it
- Available at http://localhost:5175
- Development workflow similar to TKT4

### TKT7: Redwood Blog
- Clones your Redwood app repo and runs it
- Web UI at http://localhost:8910, API at http://localhost:8911
- Development workflow similar to TKT4

## Services & URLs

| Service | URL | Description |
|---------|-----|-------------|
| MySQL Database | localhost:3306 | Database server |
| phpMyAdmin | http://localhost:8080 | Database web administration |
| CloudBeaver | http://localhost:8978 | SQL client |
| Traefik Dashboard | http://localhost:8081 | Service routing dashboard |

## Database Information

- **Host**: mysql (from containers) or localhost:3306 (from your machine)
- **Database**: app
- **Username**: user
- **Password**: password
- **Root Password**: rootpassword

## SSH Authentication for GitHub 

To push changes back to GitHub repositories from containers:

1. Create a SSH key pair if you don't have one:
   ```
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. Add the public key to your GitHub account:
   - Copy your public key: `cat ~/.ssh/id_ed25519.pub`
   - Go to GitHub → Settings → SSH and GPG keys → New SSH key

3. Configure Git in the container:
   ```
   git config --global user.name "Your Name"
   git config --global user.email "your_email@example.com"
   ```

4. When pulling/pushing in the container, use SSH URLs:
   ```
   # Instead of:
   https://github.com/yourusername/repo.git
   
   # Use:
   git@github.com:yourusername/repo.git
   ```

SSH keys are automatically mounted into the containers.