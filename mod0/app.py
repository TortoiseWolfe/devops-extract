import os
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def home():
    # Pass repo URL to template if available
    repo_url = os.environ.get('MOD0_REPO_URL', '')
    git_user_name = os.environ.get('GIT_USER_NAME', '')
    git_user_email = os.environ.get('GIT_USER_EMAIL', '')
    
    return render_template('index.html', 
                          title="Welcome to MOD0",
                          repo_url=repo_url,
                          git_user_name=git_user_name,
                          git_user_email=git_user_email)

@app.route('/tutorial')
def tutorial():
    return render_template('tutorial.html', title="MOD0 Tutorial")

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)