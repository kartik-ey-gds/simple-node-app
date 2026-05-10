# Simple Node App - Quick Reference

## ⚡ Quick Start (15 minutes)

### 1. Azure VM Setup (5 min)
```
Portal → Virtual Machines → + Create
Image: Ubuntu 20.04 LTS
Size: Standard B1s (cheapest)
SSH key: Generate & download

Get Public IP ✅
```

### 2. Prepare VM (3 min)
```bash
ssh -i key.pem azureuser@<ip>
sudo apt update && sudo apt install -y nodejs npm git
sudo npm install -g pm2
```

### 3. Deploy App (2 min)
```bash
mkdir ~/simple-node-app
cd ~/simple-node-app
git clone https://github.com/YOUR/simple-node-app.git .
npm install --production
pm2 start app.js --name "simple-app"
```

### 4. Configure GitHub (5 min)
```
Secrets:
- AZURE_VM_IP = <your_ip>
- SSH_PRIVATE_KEY = (contents of key.pem)
```

### 5. Push & Deploy (Auto!)
```bash
git push origin main
# GitHub Actions auto-deploys!
```

---

## 📍 Access Your App

```
http://<your_public_ip>:3000          # Main endpoint
http://<your_public_ip>:3000/health   # Health check
http://<your_public_ip>:3000/api/info # Info
```

---

## 🔑 Required Secrets in GitHub

| Name | Value | Where |
|------|-------|-------|
| `AZURE_VM_IP` | 52.123.45.67 | Azure Portal → VM → Public IP |
| `SSH_PRIVATE_KEY` | -----BEGIN OPENSSH... | Downloaded during VM creation |

---

## 🛠️ Common Commands

### Local
```bash
npm install      # Install deps
npm start        # Run app
npm run dev      # Dev mode (auto-reload)
git push         # Trigger deployment
```

### On VM
```bash
pm2 status           # Check process
pm2 logs simple-app  # View logs
pm2 restart simple-app  # Restart
ssh azureuser@<ip>   # SSH to VM
```

---

## 🚨 Troubleshooting

| Issue | Solution |
|-------|----------|
| SSH fails | Check key permissions: `chmod 600 key.pem` |
| Port 3000 blocked | Add NSG rule in Azure Portal |
| App not running | `pm2 logs simple-app` to see errors |
| Deployment fails | Check GitHub Actions logs |
| High costs | Use B1s VM size (~$8/month) |

---

## ✅ Verify Everything

```bash
# 1. SSH works
ssh -i key.pem azureuser@<ip>

# 2. App running
pm2 status

# 3. Endpoint responds
curl http://<ip>:3000/health

# 4. Automation works
# Push code → GitHub Actions deploys automatically
```

---

## 📊 Architecture

```
GitHub Repository
       ↓
  Push to main
       ↓
GitHub Actions Pipeline
       ↓
SSH to Azure VM
       ↓
Pull code + npm install
       ↓
PM2 restart app
       ↓
Health check ✅
```

---

## 💰 Monthly Cost

```
Azure VM B1s: $7-10
GitHub Actions: FREE (within limits)
Total: ~$8-10/month
```

---

## 🎯 What You Have

✅ Simple Node.js app (4 endpoints)
✅ Docker support
✅ Automated CI/CD pipeline
✅ Health monitoring
✅ Process management (PM2)
✅ Production-ready

---

**See DEPLOYMENT_GUIDE.md for complete setup!**
