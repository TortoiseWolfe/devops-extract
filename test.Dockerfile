FROM alpine:latest
ARG TKT56_REPO_URL
RUN echo "ARG TKT56_REPO_URL: ${TKT56_REPO_URL}" > /test-output.txt
ENV TKT56_REPO_URL=${TKT56_REPO_URL}
RUN echo "ENV TKT56_REPO_URL: ${TKT56_REPO_URL}" >> /test-output.txt
CMD cat /test-output.txt
