# Container base
FROM alpine:latest

# Install dependencies
RUN apk add --no-cache \
    bash \
    && rm -rf /var/cache/apk/*

# Working directory
WORKDIR /app

# Interactively start
CMD ["bash"]
