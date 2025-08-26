#!/bin/bash

# Script to set up GAIT devcontainer in another project
# Usage: curl -fsSL https://raw.githubusercontent.com/bluerinc/coconut-init/main/.devcontainer/setup-in-project.sh | bash

set -e

echo "🚀 Setting up GAIT DevContainer in your project"
echo "=============================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "⚠️  Warning: Not in a git repository. It's recommended to initialize git first."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if .devcontainer already exists
if [ -d ".devcontainer" ]; then
    echo "⚠️  .devcontainer directory already exists!"
    read -p "Overwrite existing .devcontainer? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
    rm -rf .devcontainer
fi

echo "📦 Creating .devcontainer directory..."
mkdir -p .devcontainer

echo "📥 Downloading GAIT devcontainer configuration..."

# Download the essential files from the GAIT repository
BASE_URL="https://raw.githubusercontent.com/bluerinc/coconut-init/main/.devcontainer"

# Download files
curl -fsSL "$BASE_URL/devcontainer.json" -o .devcontainer/devcontainer.json
curl -fsSL "$BASE_URL/Dockerfile" -o .devcontainer/Dockerfile
curl -fsSL "$BASE_URL/build.sh" -o .devcontainer/build.sh
curl -fsSL "$BASE_URL/install-gait.sh" -o .devcontainer/install-gait.sh
curl -fsSL "$BASE_URL/start-gait-server.sh" -o .devcontainer/start-gait-server.sh
curl -fsSL "$BASE_URL/.env.example" -o .devcontainer/.env.example
curl -fsSL "$BASE_URL/.gitignore" -o .devcontainer/.gitignore
curl -fsSL "$BASE_URL/README.md" -o .devcontainer/README-GAIT.md

# Make scripts executable
chmod +x .devcontainer/build.sh
chmod +x .devcontainer/install-gait.sh
chmod +x .devcontainer/start-gait-server.sh

# Create a project-specific README
cat > .devcontainer/README.md << 'EOF'
# GAIT DevContainer for This Project

This project uses the GAIT devcontainer for development. GAIT is pre-installed and configured.

## Quick Start

1. **Set up GitHub Token** (one-time setup):
   ```bash
   cd .devcontainer
   cp .env.example .env
   # Edit .env and add your GitHub Personal Access Token
   ```

2. **Build the container** (one-time setup):
   ```bash
   cd .devcontainer
   ./build.sh
   ```

3. **Open in VS Code**:
   - Press `F1` and select "Dev Containers: Reopen in Container"
   - Or click the green button in the bottom-left corner

4. **Use GAIT**:
   ```bash
   # Initialize GAIT in this project
   gait init
   
   # Start the web interface
   gait serve
   # Or for network access: start-gait-server
   
   # Create change proposals
   gait propose
   ```

For full documentation, see `.devcontainer/README-GAIT.md`
EOF

echo ""
echo "✅ GAIT DevContainer files installed successfully!"
echo ""
echo "📋 Next steps:"
echo ""
echo "1. Set up your GitHub token:"
echo "   cd .devcontainer"
echo "   cp .env.example .env"
echo "   # Edit .env and add your GitHub Personal Access Token"
echo ""
echo "2. Build the container image:"
echo "   ./build.sh"
echo ""
echo "3. Open in VS Code and reopen in container"
echo ""
echo "4. Once in the container, initialize GAIT:"
echo "   gait init"
echo ""
echo "📚 See .devcontainer/README.md for more details"
