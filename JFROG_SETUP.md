# JFrog Artifactory Docker Registry Setup

## 🎯 What We're Setting Up

```
JFrog Artifactory (Docker Registry)
├── Web UI: http://localhost:8081
├── Docker Registry: localhost:8082
├── API: http://localhost:8081/artifactory
└── Registry UI: http://localhost:8080
```

---

## ⚡ Quick Start (5 minutes)

### Option 1: Run with Your App

```bash
# Start both JFrog Artifactory and your Node app
docker-compose -f docker-compose-full.yml up -d

# Wait for startup (30-60 seconds)
```

### Option 2: Run JFrog Only

```bash
# Start just Artifactory
docker run -d \
  --name jfrog-artifactory \
  -p 8081:8081 \
  -p 8082:8082 \
  -v artifactory-data:/var/opt/jfrog/artifactory \
  releases-docker.jfrog.io/jfrog/artifactory-oss:latest

# Wait for startup
sleep 30
```

---

## 🔐 Access JFrog

### Web UI
```
URL: http://localhost:8081/artifactory

Default Credentials:
Username: admin
Password: password
```

### Docker Registry
```
Registry: localhost:8082
No authentication required initially
```

### Registry Browser UI
```
URL: http://localhost:8080
Browse Docker images easily
```

---

## 📝 Change Default Password (Recommended)

```bash
# Via UI:
1. Go to http://localhost:8081/artifactory
2. Login with admin/password
3. Admin → Security → Users
4. Change admin password

# Via API:
curl -u admin:password \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"password":"new-password"}' \
  http://localhost:8081/artifactory/api/security/users/admin/password
```

---

## 🐳 Build & Push Docker Image to JFrog

### Step 1: Create Docker Repository in JFrog

```bash
# Via UI:
1. Go to http://localhost:8081/artifactory
2. Admin → Repositories → Create Repository
3. Select: Docker
4. Repository Key: docker-local
5. Click Create

# Or via API:
curl -u admin:password \
  -X PUT \
  -H "Content-Type: application/json" \
  -d '{
    "key": "docker-local",
    "packageType": "Docker",
    "rclass": "local",
    "repoLayoutRef": "docker"
  }' \
  http://localhost:8081/artifactory/api/repositories/docker-local
```

### Step 2: Build Your App Image

```bash
# Build for local registry
docker build -t localhost:8082/simple-node-app:latest .

# Or build with tag
docker build -t localhost:8082/docker-local/simple-node-app:1.0.0 .
```

### Step 3: Push to JFrog

```bash
# Tag image
docker tag simple-node-app:latest localhost:8082/docker-local/simple-node-app:latest

# Push (no authentication needed initially)
docker push localhost:8082/docker-local/simple-node-app:latest
```

---

## 📥 Pull Image from JFrog

### From Local Machine

```bash
# Pull image
docker pull localhost:8082/docker-local/simple-node-app:latest

# Run container
docker run -p 3000:3000 localhost:8082/docker-local/simple-node-app:latest
```

### From Docker Compose

```yaml
version: '3.9'
services:
  app:
    image: localhost:8082/docker-local/simple-node-app:latest
    ports:
      - "3000:3000"
```

---

## 🔑 Authenticate to JFrog Registry

### Docker Login

```bash
# Interactive login
docker login localhost:8082
Username: admin
Password: password

# Non-interactive
docker login -u admin -p password localhost:8082
```

### Create Credentials File

**On Linux/Mac:**
```bash
# Docker will auto-create ~/.docker/config.json
docker login localhost:8082
```

**On Windows:**
```powershell
# Docker Desktop auto-handles this
docker login localhost:8082
```

---

## 📊 Example: Complete Build & Push Pipeline

```bash
#!/bin/bash

# Variables
REGISTRY="localhost:8082"
REPO="docker-local"
IMAGE="simple-node-app"
TAG="1.0.0"
FULL_IMAGE="$REGISTRY/$REPO/$IMAGE:$TAG"

# 1. Build
echo "🔨 Building image..."
docker build -t $IMAGE:latest .

# 2. Tag
echo "🏷️  Tagging image..."
docker tag $IMAGE:latest $FULL_IMAGE

# 3. Login (if needed)
echo "🔐 Logging in..."
docker login -u admin -p password $REGISTRY

# 4. Push
echo "📤 Pushing to JFrog..."
docker push $FULL_IMAGE

# 5. Verify
echo "✅ Verifying..."
curl -u admin:password \
  http://localhost:8081/artifactory/api/storage/$REPO/$IMAGE

echo "✅ Push complete!"
```

---

## 🔄 Integrate with GitHub Actions

### Updated CI/CD Pipeline with JFrog

```yaml
name: Build & Push to JFrog

on:
  push:
    branches: [main]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: docker build -t simple-node-app:${{ github.sha }} .
      
      - name: Tag for JFrog
        run: |
          docker tag simple-node-app:${{ github.sha }} \
            ${{ secrets.JFROG_URL }}/docker-local/simple-node-app:latest
          docker tag simple-node-app:${{ github.sha }} \
            ${{ secrets.JFROG_URL }}/docker-local/simple-node-app:${{ github.sha }}
      
      - name: Login to JFrog
        run: |
          echo "${{ secrets.JFROG_PASSWORD }}" | docker login \
            -u ${{ secrets.JFROG_USERNAME }} \
            --password-stdin \
            ${{ secrets.JFROG_URL }}
      
      - name: Push to JFrog
        run: |
          docker push ${{ secrets.JFROG_URL }}/docker-local/simple-node-app:latest
          docker push ${{ secrets.JFROG_URL }}/docker-local/simple-node-app:${{ github.sha }}
      
      - name: Verify push
        run: |
          curl -u ${{ secrets.JFROG_USERNAME }}:${{ secrets.JFROG_PASSWORD }} \
            ${{ secrets.JFROG_URL }}/artifactory/api/storage/docker-local/simple-node-app
```

### GitHub Secrets to Add

```
JFROG_URL = http://jfrog.example.com:8081
JFROG_USERNAME = admin
JFROG_PASSWORD = your-password
```

---

## 📊 JFrog Web UI Features

### Browse Repositories
```
Artifactory → Repositories
├── docker-local (your Docker images)
├── libs-snapshot (libraries)
└── libs-release (released libraries)
```

### View Image Details
```
Navigate to: docker-local/simple-node-app
├── Layers
├── Manifests
├── Properties
└── Statistics
```

### Check Image Scan Results
```
Admin → Security → Scan Results
Shows vulnerability reports
```

---

## 🔍 Common Commands

### List all repositories
```bash
curl -u admin:password \
  http://localhost:8081/artifactory/api/repositories
```

### List images in repository
```bash
curl -u admin:password \
  http://localhost:8081/artifactory/api/storage/docker-local
```

### Get image details
```bash
curl -u admin:password \
  http://localhost:8081/artifactory/api/storage/docker-local/simple-node-app/latest/manifest.json
```

### Delete image
```bash
curl -u admin:password \
  -X DELETE \
  http://localhost:8081/artifactory/docker-local/simple-node-app/latest
```

### Cleanup old builds
```bash
curl -u admin:password \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "retention": {
      "count": 10,
      "period": 30
    }
  }' \
  http://localhost:8081/artifactory/api/storage/docker-local/cleanup
```

---

## 🐳 Docker Compose Services

### JFrog Artifactory
```
Container: jfrog-artifactory
Ports: 8081 (Web/API), 8082 (Docker Registry)
Volume: artifactory-data (persistent storage)
Health Check: Automatic
```

### Simple Node App
```
Container: simple-node-app
Ports: 3000
Depends on: Artifactory
Pulls from: JFrog registry
```

### Registry UI (Optional)
```
Container: jfrog-ui
Ports: 8080
Browse Docker images visually
Easier than JFrog web UI
```

---

## ⚠️ Troubleshooting

### Issue: Registry not accessible

```bash
# Check if running
docker ps | grep artifactory

# Check logs
docker logs jfrog-artifactory

# Check port
netstat -an | grep 8082

# Restart
docker-compose restart artifactory
```

### Issue: Push fails with "Unauthorized"

```bash
# Login again
docker login localhost:8082

# Check credentials
docker login -u admin -p password localhost:8082

# Check config
cat ~/.docker/config.json
```

### Issue: Out of disk space

```bash
# Check Docker disk usage
docker system df

# Clean up
docker system prune -a

# Remove old images
docker image prune -a --filter "until=168h"
```

### Issue: Slow performance

```bash
# Check JFrog memory
docker stats jfrog-artifactory

# Increase memory in docker-compose-full.yml:
environment:
  - JVM_MAX_MEM_PERCENT=80
```

---

## 💾 Backup & Restore

### Backup JFrog Data

```bash
# Backup volume
docker run --rm \
  -v artifactory-data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/artifactory-backup.tar.gz -C /data .

# Check backup
ls -lh backup/artifactory-backup.tar.gz
```

### Restore from Backup

```bash
# Restore volume
docker run --rm \
  -v artifactory-data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar xzf /backup/artifactory-backup.tar.gz -C /data

# Restart
docker-compose restart artifactory
```

---

## 🚀 Production Setup

### On Azure VM

```bash
# 1. SSH to VM
ssh -i key.pem azureuser@<ip>

# 2. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. Create app directory
mkdir -p ~/jfrog-setup
cd ~/jfrog-setup

# 5. Copy docker-compose file
wget https://raw.githubusercontent.com/YOUR/REPO/main/docker-compose-full.yml

# 6. Start services
sudo docker-compose -f docker-compose-full.yml up -d

# 7. Configure firewall
sudo ufw allow 8081/tcp
sudo ufw allow 8082/tcp
sudo ufw allow 3000/tcp
```

---

## 📈 Storage Management

### Check Repository Size

```bash
curl -u admin:password \
  http://localhost:8081/artifactory/api/storage/docker-local/stat
```

### Set Storage Quotas

```bash
curl -u admin:password \
  -X PUT \
  -H "Content-Type: application/json" \
  -d '{
    "maxStorageMB": 5120
  }' \
  http://localhost:8081/artifactory/api/system/config/storage
```

---

## 🎯 Next Steps

1. **Start JFrog:** `docker-compose -f docker-compose-full.yml up -d`
2. **Access UI:** http://localhost:8081/artifactory
3. **Create Repository:** Admin → Repositories → Create Docker repo
4. **Build & Push:** `docker build -t localhost:8082/docker-local/simple-node-app:latest .`
5. **Verify:** Check in JFrog UI

---

## 📚 Resources

- [JFrog Artifactory Docker Docs](https://jfrog.com/help/display/jfrog/docker+registry)
- [JFrog Artifactory OSS](https://jfrog.com/open-source/)
- [Docker Registry API](https://docs.docker.com/registry/spec/api/)
- [Docker Authentication](https://docs.docker.com/engine/reference/commandline/login/)

---

**Status**: Complete JFrog Artifactory Docker setup! 🚀
