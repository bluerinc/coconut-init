#!/bin/bash

# GAIT Status Check Script
# Verifies that GAIT is properly installed and configured in the devcontainer

echo "🚀 GAIT Development Environment Status"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check GAIT installation
if [ -d "/opt/gait" ]; then
    echo -e "${GREEN}✅ GAIT source code found at /opt/gait${NC}"
    
    # Check if packages are built
    if [ -d "/opt/gait/packages/cli/dist" ]; then
        echo -e "${GREEN}✅ GAIT packages are built${NC}"
    else
        echo -e "${YELLOW}⚠️  GAIT packages not built, building now...${NC}"
        cd /opt/gait && pnpm build
    fi
    
    # Check if CLI is linked
    if command -v gait &> /dev/null; then
        echo -e "${GREEN}✅ GAIT CLI is globally available${NC}"
        echo ""
        echo "GAIT CLI version:"
        gait --version 2>/dev/null || echo "  Version information not available"
    else
        echo -e "${YELLOW}⚠️  GAIT CLI not linked, linking now...${NC}"
        cd /opt/gait/packages/cli && npm link
    fi
else
    echo -e "${RED}❌ GAIT not found at /opt/gait${NC}"
    echo "This container may not have been built with GAIT pre-installed."
    echo ""
    echo "To manually install GAIT:"
    echo "  1. Clone the repository: git clone https://github.com/bluerinc/gait.git /opt/gait"
    echo "  2. Build packages: cd /opt/gait && pnpm install && pnpm build"
    echo "  3. Link CLI: cd /opt/gait/packages/cli && npm link"
fi

echo ""
echo "🔧 Development Tools Status:"
echo "----------------------------"

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✅ Node.js: ${NODE_VERSION}${NC}"
else
    echo -e "${RED}❌ Node.js not found${NC}"
fi

# Check pnpm
if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm --version)
    echo -e "${GREEN}✅ pnpm: ${PNPM_VERSION}${NC}"
else
    echo -e "${RED}❌ pnpm not found${NC}"
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✅ npm: ${NPM_VERSION}${NC}"
else
    echo -e "${RED}❌ npm not found${NC}"
fi

# Check git
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    echo -e "${GREEN}✅ git: ${GIT_VERSION}${NC}"
else
    echo -e "${RED}❌ git not found${NC}"
fi

# Check GitHub CLI
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -1 | cut -d' ' -f3)
    echo -e "${GREEN}✅ GitHub CLI: ${GH_VERSION}${NC}"
else
    echo -e "${YELLOW}⚠️  GitHub CLI not found (optional)${NC}"
fi

# Check additional AI CLI tools
if command -v gemini &> /dev/null; then
    echo -e "${GREEN}✅ Google Gemini CLI: installed${NC}"
else
    echo -e "${YELLOW}⚠️  Google Gemini CLI not found${NC}"
fi

if command -v claude-code &> /dev/null; then
    echo -e "${GREEN}✅ Anthropic Claude Code CLI: installed${NC}"
else
    echo -e "${YELLOW}⚠️  Anthropic Claude Code CLI not found${NC}"
fi

if command -v codex &> /dev/null; then
    echo -e "${GREEN}✅ OpenAI Codex CLI: installed${NC}"
else
    echo -e "${YELLOW}⚠️  OpenAI Codex CLI not found${NC}"
fi

echo ""
echo "📦 GAIT Packages Status:"
echo "------------------------"

if [ -d "/opt/gait" ]; then
    # List GAIT packages
    for package in cli core types web; do
        if [ -d "/opt/gait/packages/$package" ]; then
            if [ -f "/opt/gait/packages/$package/package.json" ]; then
                VERSION=$(grep '"version"' "/opt/gait/packages/$package/package.json" | head -1 | cut -d'"' -f4)
                echo -e "${GREEN}✅ @gait/$package: v${VERSION}${NC}"
            else
                echo -e "${YELLOW}⚠️  @gait/$package: found but no package.json${NC}"
            fi
        else
            echo -e "${RED}❌ @gait/$package: not found${NC}"
        fi
    done
fi

echo ""
echo "🌐 Environment Variables:"
echo "-------------------------"
echo "  GAIT_HOME: ${GAIT_HOME:-not set}"
echo "  NODE_ENV: ${NODE_ENV:-not set}"
echo "  SHELL: ${SHELL}"
echo "  USER: $(whoami)"
echo "  PWD: $(pwd)"

echo ""
echo "💡 Quick Start Commands:"
echo "------------------------"
echo "  gait --help           # Show GAIT CLI help"
echo "  gait init            # Initialize GAIT in current project"
echo "  gait serve           # Start GAIT web interface"
echo "  gait propose         # Create a change proposal"
echo ""
echo "📚 GAIT Source Location: /opt/gait"
echo "   To modify GAIT itself:"
echo "   cd /opt/gait && pnpm dev"
echo ""
echo "🎉 Environment ready! Happy coding!"
