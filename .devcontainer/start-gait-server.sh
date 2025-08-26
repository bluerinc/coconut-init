#!/bin/bash

# GAIT Server Startup Script
# This script starts the GAIT web server in production or development mode

echo "🚀 Starting GAIT Web Server"
echo "=========================="

# Check if GAIT is installed
if [ ! -d "/opt/gait" ]; then
    echo "❌ GAIT not found at /opt/gait"
    exit 1
fi

cd /opt/gait/packages/web

# Check if the server files exist
if [ ! -f "server-prod.js" ] || [ ! -f "server-dev.js" ]; then
    echo "❌ Server files not found"
    exit 1
fi

# Determine which mode to run in
MODE=${GAIT_MODE:-production}
HOSTNAME=${HOSTNAME:-0.0.0.0}  # Default to 0.0.0.0 to allow external connections
PORT=${PORT:-3000}

echo "Configuration:"
echo "  Mode: $MODE"
echo "  Hostname: $HOSTNAME"
echo "  Port: $PORT"
echo ""

# Export environment variables for the server
export HOSTNAME=$HOSTNAME
export PORT=$PORT

# Check if the project is built
if [ ! -d ".next" ] || [ ! -d "dist" ]; then
    echo "📦 Building GAIT web interface..."
    pnpm build
fi

# Start the appropriate server
if [ "$MODE" = "production" ]; then
    echo "🚀 Starting production server..."
    echo "   Access locally: http://localhost:$PORT"
    echo "   Access remotely: http://<container-host-ip>:$PORT"
    node server-prod.js
else
    echo "🚀 Starting development server..."
    echo "   Access locally: http://localhost:$PORT"
    echo "   Access remotely: http://<container-host-ip>:$PORT"
    node server-dev.js
fi
