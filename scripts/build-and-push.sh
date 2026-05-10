#!/bin/bash

################################
# Build and Push to JFrog
# Usage: ./scripts/build-and-push.sh [tag]
# Example: ./scripts/build-and-push.sh 1.0.0
################################

set -e

# Configuration
REGISTRY="${REGISTRY:-localhost:8082}"
REPO="${REPO:-docker-local}"
IMAGE="simple-node-app"
TAG="${1:-latest}"
FULL_IMAGE="$REGISTRY/$REPO/$IMAGE:$TAG"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Docker Build & Push to JFrog${NC}"
echo "Registry: $REGISTRY"
echo "Repository: $REPO"
echo "Image: $IMAGE"
echo "Tag: $TAG"
echo "Full: $FULL_IMAGE"
echo ""

# Step 1: Build
echo -e "${BLUE}Step 1: 🔨 Building Docker image...${NC}"
docker build -t $IMAGE:latest -t $IMAGE:$TAG .
echo -e "${GREEN}✅ Build complete!${NC}"
echo ""

# Step 2: Tag for registry
echo -e "${BLUE}Step 2: 🏷️  Tagging for JFrog registry...${NC}"
docker tag $IMAGE:latest $FULL_IMAGE
if [ "$TAG" != "latest" ]; then
  docker tag $IMAGE:$TAG $REGISTRY/$REPO/$IMAGE:$TAG
fi
echo -e "${GREEN}✅ Tagging complete!${NC}"
echo ""

# Step 3: Login (optional)
echo -e "${BLUE}Step 3: 🔐 Authenticating to registry...${NC}"
read -p "Need to login? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "Username (admin): " JFROG_USER
  JFROG_USER=${JFROG_USER:-admin}
  read -sp "Password: " JFROG_PASS
  echo
  echo "$JFROG_PASS" | docker login -u $JFROG_USER --password-stdin $REGISTRY
  echo -e "${GREEN}✅ Login successful!${NC}"
else
  echo -e "${YELLOW}⏭️  Skipping login${NC}"
fi
echo ""

# Step 4: Push
echo -e "${BLUE}Step 4: 📤 Pushing to JFrog...${NC}"
docker push $FULL_IMAGE
if [ "$TAG" != "latest" ]; then
  docker push $REGISTRY/$REPO/$IMAGE:$TAG
fi
echo -e "${GREEN}✅ Push complete!${NC}"
echo ""

# Step 5: Verify (optional)
echo -e "${BLUE}Step 5: ✔️  Verifying...${NC}"
read -p "Verify with API? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "Username (admin): " JFROG_USER
  JFROG_USER=${JFROG_USER:-admin}
  read -sp "Password: " JFROG_PASS
  echo
  
  API_URL="http://localhost:8081/artifactory/api/storage/$REPO/$IMAGE/$TAG"
  echo "Checking: $API_URL"
  
  curl -s -u $JFROG_USER:$JFROG_PASS "$API_URL" | jq .
  echo -e "${GREEN}✅ Verification complete!${NC}"
else
  echo -e "${YELLOW}⏭️  Skipping verification${NC}"
fi
echo ""

echo -e "${GREEN}✅ All done!${NC}"
echo ""
echo -e "${BLUE}Access your image:${NC}"
echo "  Docker: docker pull $FULL_IMAGE"
echo "  UI: http://localhost:8081/artifactory (Admin → Repositories)"
echo "  Registry UI: http://localhost:8080"
