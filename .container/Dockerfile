# Container base
FROM alpine:latest

# Install dependencies
RUN apk update && apk add --no-cache \
    bash \
    && rm -rf /var/cache/apk/*

# Working directory
WORKDIR /work

# Interactively start
CMD ["bash"]
