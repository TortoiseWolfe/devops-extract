FROM python:3.10-slim

WORKDIR /app

# Install essential packages for Python development
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for data science, web development, and testing
RUN pip install --no-cache-dir \
    flask \
    flask-cors \
    flask-sqlalchemy \
    pytest \
    pytest-cov \
    requests \
    pandas \
    numpy \
    matplotlib \
    seaborn \
    scikit-learn \
    jupyterlab \
    black \
    pylint \
    mypy \
    python-dotenv

# Create a sample Flask app
RUN mkdir -p /app/templates

# Add a sample app.py file
COPY ./app.py /app/app.py
COPY ./templates /app/templates

# Set permissions
RUN chmod -R 777 /app

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=app.py
ENV FLASK_ENV=development

# Create a non-root user to run the application
RUN useradd -m appuser
USER appuser

# Service healthcheck
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/ || exit 1

EXPOSE 5000

# Run the Flask application
CMD ["flask", "run", "--host=0.0.0.0"]