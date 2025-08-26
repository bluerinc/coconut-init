#!/bin/bash

# GAIT DevContainer Build Script
# Builds the devcontainer with GAIT pre-installed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 GAIT DevContainer Build Script${NC}"
echo "=================================="

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed${NC}"
    exit 1
fi

# Check for BuildKit support
if ! docker buildx version &> /dev/null; then
    echo -e "${YELLOW}⚠️  Docker BuildKit not found, trying to enable...${NC}"
    export DOCKER_BUILDKIT=1
fi

# Check for GitHub token
TOKEN_FILE=".env"
if [ -f "$TOKEN_FILE" ]; then
    source "$TOKEN_FILE"
    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${YELLOW}⚠️  GITHUB_TOKEN not found in .env file${NC}"
        echo "The build will attempt to clone the public repository."
    else
        echo -e "${GREEN}✅ GitHub token found${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No .env file found${NC}"
    echo "Create .devcontainer/.env with GITHUB_TOKEN=your_token"
    echo "The build will attempt to clone the public repository."
fi

# Image name and tag
IMAGE_NAME="gait-devcontainer"
IMAGE_TAG="latest"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

echo ""
echo -e "${GREEN}Building image: ${FULL_IMAGE}${NC}"
echo ""

# Build with BuildKit and secret mounting
if [ -n "$GITHUB_TOKEN" ]; then
    # Create temporary file with token for secret mounting
    echo "$GITHUB_TOKEN" > .github_token_temp
    
    # Build with secret
    DOCKER_BUILDKIT=1 docker build \
        --secret id=github_token,src=.github_token_temp \
        --progress=plain \
        -t "$FULL_IMAGE" \
        -f Dockerfile \
        .
    
    # Clean up temporary file
    rm -f .github_token_temp
else
    # Build without secret (will try public clone)
    DOCKER_BUILDKIT=1 docker build \
        --progress=plain \
        -t "$FULL_IMAGE" \
        -f Dockerfile \
        .
fi

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""
    echo "Image details:"
    docker images | grep "$IMAGE_NAME"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "1. Open this folder in VS Code"
    echo "2. Press F1 and select 'Dev Containers: Reopen in Container'"
    echo "3. Or use: docker run -it --rm -v \$(pwd):/workspaces/project $FULL_IMAGE"
    echo ""
    echo -e "${GREEN}GAIT will be available immediately with:${NC}"
    echo "  gait --help"
    echo "  gait init"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Build failed${NC}"
    echo "Please check the error messages above."
    exit 1
fi
