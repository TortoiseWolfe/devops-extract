#\!/bin/bash

echo "Testing environment variables with Docker..."
echo "TKT56_REPO_URL=${TKT56_REPO_URL}"
export TKT56_REPO_URL="https://github.com/vercel/next-learn"

# Create a simple Dockerfile for testing
cat > test.Dockerfile << INNER_EOF
FROM alpine:latest
ARG TKT56_REPO_URL
RUN echo "ARG TKT56_REPO_URL: \${TKT56_REPO_URL}" > /test-output.txt
ENV TKT56_REPO_URL=\${TKT56_REPO_URL}
RUN echo "ENV TKT56_REPO_URL: \${TKT56_REPO_URL}" >> /test-output.txt
CMD cat /test-output.txt
INNER_EOF

# Build and run the test container
docker build -t test-env-vars --build-arg TKT56_REPO_URL="${TKT56_REPO_URL}" -f test.Dockerfile .
docker run --rm test-env-vars
