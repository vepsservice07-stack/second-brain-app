#!/bin/bash
# Second Brain - Development Server Startup
# Starts all necessary services for local development
# Usage: ./start-dev.sh

echo "========================================"
echo "  Starting Second Brain Development"
echo "========================================"
echo ""

# Source environment
if [ -f "./second-brain-setup.sh" ]; then
    source ./second-brain-setup.sh > /dev/null 2>&1
fi

# Check if we're in the right directory
if [ ! -d "second-brain-rails" ]; then
    echo "❌ Error: Must run from second-brain-app directory"
    exit 1
fi

echo "This will start 3 services in separate terminal tabs/windows:"
echo "  1. Cloud SQL Proxy (database connection)"
echo "  2. Tailwind CSS Watch (auto-compile styles)"
echo "  3. Rails Server (web application)"
echo ""
echo "Press Ctrl+C in this terminal to stop all services"
echo ""

# Create a temp directory for PIDs
mkdir -p .tmp/pids

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Shutting down services..."
    
    if [ -f .tmp/pids/proxy.pid ]; then
        kill $(cat .tmp/pids/proxy.pid) 2>/dev/null
        rm .tmp/pids/proxy.pid
    fi
    
    if [ -f .tmp/pids/tailwind.pid ]; then
        kill $(cat .tmp/pids/tailwind.pid) 2>/dev/null
        rm .tmp/pids/tailwind.pid
    fi
    
    if [ -f .tmp/pids/rails.pid ]; then
        kill $(cat .tmp/pids/rails.pid) 2>/dev/null
        rm .tmp/pids/rails.pid
    fi
    
    echo "✅ All services stopped"
    exit 0
}

trap cleanup INT TERM

# Start Cloud SQL Proxy in background
echo "Starting Cloud SQL Proxy..."
mkdir -p /tmp/cloudsql
~/bin/cloud_sql_proxy -dir=/tmp/cloudsql $DB_CONNECTION_NAME > .tmp/logs/proxy.log 2>&1 &
PROXY_PID=$!
echo $PROXY_PID > .tmp/pids/proxy.pid
sleep 2

if ps -p $PROXY_PID > /dev/null; then
    echo "✅ Cloud SQL Proxy started (PID: $PROXY_PID)"
else
    echo "❌ Failed to start Cloud SQL Proxy"
    cat .tmp/logs/proxy.log
    exit 1
fi

# Start Tailwind watcher in background
echo "Starting Tailwind CSS watcher..."
cd second-brain-rails
bin/rails tailwindcss:watch > ../.tmp/logs/tailwind.log 2>&1 &
TAILWIND_PID=$!
echo $TAILWIND_PID > ../.tmp/pids/tailwind.pid
cd ..
sleep 2

if ps -p $TAILWIND_PID > /dev/null; then
    echo "✅ Tailwind CSS watcher started (PID: $TAILWIND_PID)"
else
    echo "❌ Failed to start Tailwind watcher"
    cat .tmp/logs/tailwind.log
    cleanup
    exit 1
fi

# Start Rails server in background
echo "Starting Rails server..."
cd second-brain-rails
RAILS_ENV=development bin/rails server > ../.tmp/logs/rails.log 2>&1 &
RAILS_PID=$!
echo $RAILS_PID > ../.tmp/pids/rails.pid
cd ..
sleep 3

if ps -p $RAILS_PID > /dev/null; then
    echo "✅ Rails server started (PID: $RAILS_PID)"
else
    echo "❌ Failed to start Rails server"
    cat .tmp/logs/rails.log
    cleanup
    exit 1
fi

echo ""
echo "========================================"
echo "  All Services Running!"
echo "========================================"
echo ""
echo "🌐 Application: http://localhost:3000"
echo ""
echo "Logs:"
echo "  Proxy:    tail -f .tmp/logs/proxy.log"
echo "  Tailwind: tail -f .tmp/logs/tailwind.log"
echo "  Rails:    tail -f .tmp/logs/rails.log"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Wait for Ctrl+C
wait