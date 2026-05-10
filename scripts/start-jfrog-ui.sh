#!/bin/bash

################################
# JFrog UI - One Command Start
# Usage: ./scripts/start-jfrog-ui.sh
################################

echo "🚀 Starting JFrog Artifactory UI..."
echo ""

# Check if Docker is running
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "Please start Docker and try again."
    exit 1
fi

# Check if already running
if docker ps | grep -q jfrog-ui; then
    echo "⚠️  JFrog UI is already running!"
    echo "Access it at: http://localhost:8081/artifactory"
    exit 0
fi

# Start JFrog
docker-compose -f docker-compose-jfrog-ui-simple.yml up -d

if [ $? -ne 0 ]; then
    echo "❌ Failed to start JFrog!"
    exit 1
fi

echo "✅ JFrog UI container started!"
echo ""
echo "⏳ Waiting for JFrog to startup (30-60 seconds)..."
echo ""

# Wait for health check
for i in {1..60}; do
    if curl -s http://localhost:8081/artifactory/api/system/ping > /dev/null 2>&1; then
        echo ""
        echo "✅ JFrog UI is ready!"
        echo ""
        echo "📍 Access: http://localhost:8081/artifactory"
        echo "👤 Username: admin"
        echo "🔐 Password: password"
        echo ""
        echo "💡 Change password in: Admin → Security → Users"
        echo ""
        exit 0
    fi
    
    # Show progress
    if [ $((i % 10)) -eq 0 ]; then
        echo "⏳ Waiting... ${i}s"
    fi
    
    sleep 1
done

echo ""
echo "⚠️  JFrog is taking longer than usual."
echo "Check logs with: docker logs -f jfrog-ui"
echo "Try accessing: http://localhost:8081/artifactory"
