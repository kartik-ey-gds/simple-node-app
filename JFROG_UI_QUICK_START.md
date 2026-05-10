# 🚀 JFrog UI - Quick Start

## ⚡ One Command to Start

```bash
docker-compose -f docker-compose-jfrog-ui-simple.yml up -d
```

## 🌐 Access JFrog UI

**Wait 30-60 seconds for startup**

```
URL: http://localhost:8081/artifactory
Username: admin
Password: password
```

## 📋 Container Management

```bash
# Check status
docker ps | grep jfrog

# View logs
docker logs -f jfrog-ui

# Stop
docker stop jfrog-ui

# Start
docker start jfrog-ui

# Remove
docker stop jfrog-ui
docker rm jfrog-ui
docker volume rm simple-node-app_jfrog-data
```

## 🔐 Change Admin Password

1. Go to: http://localhost:8081/artifactory
2. Login: admin / password
3. Click: Admin (top right) → Security → Users
4. Edit admin user
5. Change password

## 🐳 Direct Docker Command

**Without docker-compose:**

```bash
docker run -d \
  --name jfrog-ui \
  -p 8081:8081 \
  -v jfrog-data:/var/opt/jfrog/artifactory \
  --restart unless-stopped \
  releases-docker.jfrog.io/jfrog/artifactory-oss:latest

# Wait 60 seconds
sleep 60

# Check if running
curl http://localhost:8081/artifactory/api/system/ping

# Open UI
# http://localhost:8081/artifactory
```

## 🎯 What You Can Do

- ✅ Create repositories
- ✅ Upload artifacts
- ✅ Manage users
- ✅ View statistics
- ✅ Configure settings

## 📊 System Info

```bash
# Check resource usage
docker stats jfrog-ui

# Check disk usage
docker exec jfrog-ui du -sh /var/opt/jfrog/artifactory
```

## 🔍 Troubleshooting

**UI not accessible:**
```bash
# Check if running
docker ps | grep jfrog

# Check logs
docker logs jfrog-ui

# Restart
docker restart jfrog-ui

# Wait longer
sleep 90
curl http://localhost:8081/artifactory/api/system/ping
```

**Port already in use:**
```bash
# Change port in docker-compose-jfrog-ui-simple.yml
# Or use different port:
docker run -d -p 9081:8081 releases-docker.jfrog.io/jfrog/artifactory-oss:latest
```

## 📈 Next Steps

1. ✅ Start JFrog: `docker-compose -f docker-compose-jfrog-ui-simple.yml up -d`
2. ✅ Open: http://localhost:8081/artifactory
3. ✅ Login: admin/password
4. ✅ Create Docker repository (Admin → Repositories)
5. ✅ Push your images!

---

**Done!** JFrog UI is running! 🚀
