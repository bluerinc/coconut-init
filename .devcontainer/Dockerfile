# Multi-stage build for optimized GAIT devcontainer
# Stage 1: Builder - Clone and build GAIT
FROM node:20-alpine AS builder

# Install git and build dependencies
RUN apk add --no-cache git openssh-client python3 python3-dev py3-setuptools make g++ linux-headers

# Set working directory for GAIT build
WORKDIR /tmp/gait-build

# Clone GAIT repository using build secret
# --mount=type=secret mounts the secret file during build only
RUN --mount=type=secret,id=github_token \
    if [ -f /run/secrets/github_token ]; then \
        export GITHUB_TOKEN=$(cat /run/secrets/github_token) && \
        git clone https://${GITHUB_TOKEN}@github.com/bluerinc/gait.git . ; \
    else \
        echo "Warning: No GitHub token provided, attempting public clone" && \
        git clone https://github.com/bluerinc/gait.git . ; \
    fi

# Enable corepack for pnpm (with retry and fallback)
RUN corepack enable && \
    (corepack prepare pnpm@8.15.1 --activate || \
     corepack prepare pnpm@8.15.1 --activate || \
     npm install -g pnpm@8.15.1)

# Install dependencies and build all packages
RUN pnpm install --frozen-lockfile && \
    pnpm build

# Prepare CLI for global installation
RUN cd packages/cli && npm pack

# Stage 2: Runtime - Lean container with pre-built GAIT
FROM node:20-alpine

# Install only runtime dependencies
RUN apk add --no-cache \
    git \
    bash \
    curl \
    sudo \
    shadow \
    github-cli \
    python3 \
    py3-pip \
    # Build tools needed for some npm packages
    make \
    g++ \
    linux-headers

# Add sudo access for the existing node user
RUN echo "node ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Enable corepack for pnpm (with fallback to npm install)
RUN corepack enable && \
    (corepack prepare pnpm@8.15.1 --activate || npm install -g pnpm@8.15.1)

# Create necessary directories
RUN mkdir -p /opt/gait /workspaces/project && \
    chown -R node:node /opt/gait /workspaces/project

# Copy built GAIT from builder stage
COPY --from=builder --chown=node:node /tmp/gait-build /opt/gait

# Copy startup script
COPY --chown=node:node start-gait-server.sh /usr/local/bin/start-gait-server
RUN chmod +x /usr/local/bin/start-gait-server

# Install GAIT CLI and other global tools as root (needs permission to write to /usr/local)
RUN cd /opt/gait/packages/cli && \
    npm link && \
    cd /opt/gait && \
    # Link all workspace packages for development
    pnpm install --offline --frozen-lockfile && \
    # Install additional CLI tools globally
    npm install -g @google/gemini-cli @anthropic-ai/claude-code @openai/codex

# Switch to non-root user (node user exists in node:20-alpine)
USER node

# Configure npm for GitHub Package Registry
RUN echo "@bluer:registry=https://npm.pkg.github.com" >> ~/.npmrc && \
    echo "@gait:registry=https://npm.pkg.github.com" >> ~/.npmrc

# Set up environment variables
ENV GAIT_HOME=/opt/gait \
    PATH="/opt/gait/packages/cli/dist:${PATH}" \
    NODE_ENV=development \
    SHELL=/bin/bash \
    HOSTNAME=0.0.0.0 \
    PORT=3000 \
    GAIT_MODE=production

# Set working directory
WORKDIR /workspaces/project

# Expose common development ports
EXPOSE 3000 3001 5173 8080 8000

# Add a health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node --version && gait --version || exit 1

# Default command
CMD ["/bin/bash"]
