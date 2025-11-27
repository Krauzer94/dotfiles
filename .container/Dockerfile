# Container base
FROM debian:unstable-slim
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /app

# Interactively start
CMD [ "bash" ]
