from flask import Flask, render_template, current_app
import os

app = Flask(__name__)

# Get environment variables
repo_url = os.environ.get('TKT0_REPO_URL', '')
git_user_name = os.environ.get('GIT_USER_NAME', '')
git_user_email = os.environ.get('GIT_USER_EMAIL', '')

@app.route('/')
def home():
    return render_template('index.html', 
                           title="Welcome to Flask",
                           repo_url=repo_url,
                           git_user_name=git_user_name,
                           git_user_email=git_user_email)

@app.route('/tutorial')
def tutorial():
    return render_template('tutorial.html', title="Flask Tutorial")

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)