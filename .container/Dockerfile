# Container base
FROM ubuntu:devel
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt update && apt install -y \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /work

# Start the container
CMD ["bash"]
