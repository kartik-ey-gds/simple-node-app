# Simple Node App - Deployment Guide

## 📋 Prerequisites

### On Your Local Machine
- [ ] Git installed
- [ ] Node.js 18+ installed
- [ ] GitHub account
- [ ] SSH key pair (for Azure VM)

### On Azure
- [ ] Azure subscription
- [ ] Azure VM created (Ubuntu 20.04+)
- [ ] Public IP assigned to VM
- [ ] Security Group (NSG) configured

---

## 🔵 AZURE SETUP (Complete Steps)

### Step 1: Create Azure VM

**1. Go to Azure Portal:**
```
https://portal.azure.com
```

**2. Create Virtual Machine:**
```
Search: Virtual Machines → + Create

Settings:
- Subscription: (your subscription)
- Resource Group: (create new: simple-app-rg)
- VM Name: simple-app-vm
- Region: (closest to you)
- Image: Ubuntu Server 20.04 LTS
- Size: Standard B1s (cheapest)
- Authentication: SSH public key

SSH Key Pair:
- Generate new pair
- Download private key (save as: azure-key.pem)

Review + Create → Create
```

**3. Wait for deployment** (2-3 minutes)

**4. Get Public IP:**
```
Portal → Virtual Machines → simple-app-vm
Overview → Public IP address
```

---

### Step 2: Network Security Group (NSG) Rules

**1. Find NSG:**
```
Portal → simple-app-vm → Networking → Network settings
```

**2. Add Inbound Rules:**

| Port | Protocol | Source | Purpose |
|------|----------|--------|---------|
| 22 | TCP | Your IP | SSH access |
| 3000 | TCP | 0.0.0.0/0 | App access |
| 80 | TCP | 0.0.0.0/0 | HTTP (future) |

**Add rules:**
```
Click: + Add inbound port rule

Rule 1 (SSH):
- Source: Your IP (or 0.0.0.0/0 for testing)
- Destination port: 22
- Action: Allow

Rule 2 (App):
- Source: 0.0.0.0/0
- Destination port: 3000
- Action: Allow

Click Add for each
```

---

### Step 3: SSH into VM

**On Windows (PowerShell):**
```powershell
# Set private key permissions
icacls "C:\path\to\azure-key.pem" /inheritance:r /grant:r "$($env:USERNAME):(F)"

# SSH to VM
ssh -i C:\path\to\azure-key.pem azureuser@<your_public_ip>
```

**On Mac/Linux:**
```bash
chmod 600 ~/azure-key.pem
ssh -i ~/azure-key.pem azureuser@<your_public_ip>
```

---

### Step 4: Prepare Azure VM

**1. Update System:**
```bash
sudo apt update && sudo apt upgrade -y
```

**2. Install Node.js:**
```bash
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs npm
node --version
npm --version
```

**3. Install PM2 (Process Manager):**
```bash
sudo npm install -g pm2
pm2 startup
pm2 install pm2-logrotate
```

**4. Install Git:**
```bash
sudo apt install -y git
```

**5. Create App Directory:**
```bash
mkdir -p ~/simple-node-app
cd ~/simple-node-app
```

---

## 🔧 LOCAL SETUP

### Step 1: Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/simple-node-app.git
cd simple-node-app
```

### Step 2: Setup Environment

```bash
# Copy example env
cp .env.example .env

# Install dependencies
npm install
```

### Step 3: Test Locally

```bash
# Run dev server
npm run dev

# Open another terminal
curl http://localhost:3000/
curl http://localhost:3000/health
curl -X POST http://localhost:3000/api/echo -H "Content-Type: application/json" -d '{"message":"Hello"}'
```

---

## 🚀 GitHub Setup

### Step 1: Create GitHub Repository

```
GitHub.com → + New Repository

Settings:
- Name: simple-node-app
- Description: Simple Node.js application
- Public or Private (your choice)
- Add README.md
- Add .gitignore (Node)

Create repository
```

### Step 2: Push Code

```bash
cd simple-node-app

git init
git add .
git commit -m "Initial commit: Simple Node app"
git remote add origin https://github.com/YOUR_USERNAME/simple-node-app.git
git branch -M main
git push -u origin main
```

### Step 3: Add GitHub Secrets

**Go to Repository:**
```
Settings → Secrets and variables → Actions → New repository secret
```

**Add 2 Secrets:**

1. **Secret: AZURE_VM_IP**
   - Value: Your VM's public IP (e.g., 52.123.45.67)

2. **Secret: SSH_PRIVATE_KEY**
   - Value: Contents of your azure-key.pem file
   - On Windows PowerShell:
     ```powershell
     Get-Content C:\path\to\azure-key.pem -Raw | Set-Clipboard
     ```
   - On Mac/Linux:
     ```bash
     cat ~/azure-key.pem | pbcopy
     ```

---

## 📤 DEPLOY TO AZURE

### Method 1: Automatic (GitHub Actions)

**1. Make a Change:**
```bash
# Edit app.js
nano app.js

# Make any change (e.g., update message)
git add .
git commit -m "Update message"
git push origin main
```

**2. Watch Deployment:**
```
GitHub → Actions → See workflow running
Wait for completion (3-5 minutes)
```

**3. Access Application:**
```
http://<your_public_ip>:3000
http://<your_public_ip>:3000/health
```

---

### Method 2: Manual Deploy

**1. SSH to VM:**
```bash
ssh -i azure-key.pem azureuser@<your_ip>
```

**2. Deploy:**
```bash
cd ~/simple-node-app

# Pull code
git clone https://github.com/YOUR_USERNAME/simple-node-app.git . 2>/dev/null || git pull origin main

# Install dependencies
npm install --production

# Start with PM2
pm2 start app.js --name "simple-app"
pm2 save
```

**3. Check Status:**
```bash
pm2 status
pm2 logs simple-app
```

---

## 📊 Verify Deployment

### Test Endpoints

**From anywhere:**
```bash
# Root endpoint
curl http://<your_ip>:3000/

# Health check
curl http://<your_ip>:3000/health

# Info endpoint
curl http://<your_ip>:3000/api/info

# Echo endpoint
curl -X POST http://<your_ip>:3000/api/echo \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello from Azure!"}'
```

**From Browser:**
```
http://<your_ip>:3000
http://<your_ip>:3000/health
http://<your_ip>:3000/api/info
```

---

## 🔍 Monitor Application

### On Azure VM

```bash
# Check all processes
pm2 status

# View logs
pm2 logs simple-app

# Monitor in real-time
pm2 monit

# Show detailed info
pm2 info simple-app
```

### From Local Machine

```bash
# Continuous health check
while true; do curl http://<your_ip>:3000/health && echo "" && sleep 5; done

# Watch logs (if you have SSH alias)
ssh azureuser@<your_ip> "pm2 logs simple-app"
```

---

## 🔄 Update Application

### Update & Redeploy

```bash
# Make changes locally
nano app.js

# Test locally
npm run dev

# Commit and push
git add .
git commit -m "Add new feature"
git push origin main

# GitHub Actions automatically deploys!
```

### Check Deployment Status

```
GitHub → Actions → Click latest workflow
View logs and status
```

---

## ⚙️ Troubleshooting

### Issue: SSH Connection Refused

**Solution:**
```bash
# Verify key permissions
ls -la azure-key.pem
# Should be: -rw------- (600)

# Fix permissions if needed
chmod 600 azure-key.pem

# Try SSH again
ssh -i azure-key.pem -v azureuser@<your_ip>
```

### Issue: Port 3000 Not Accessible

**Solution:**
```bash
# Check if app is running
ssh -i azure-key.pem azureuser@<your_ip>
pm2 status

# Check firewall
sudo ufw status

# Allow port in NSG
# Go to Azure Portal → VM → Networking → + Add inbound port rule
# Port: 3000, Protocol: TCP, Source: 0.0.0.0/0
```

### Issue: GitHub Actions Fails

**Check:**
```
GitHub → Actions → Click failed workflow
View logs for error messages

Common issues:
1. SSH key not in secrets (or incorrect)
2. AZURE_VM_IP is wrong
3. VM not running
4. Port already in use on VM
```

### Issue: App Crashes After Deployment

**On Azure VM:**
```bash
pm2 logs simple-app
# Look for error messages

# Restart app
pm2 restart simple-app

# Check node_modules
cd ~/simple-node-app
npm install --production
```

---

## 📝 Useful Commands

### Local Development

```bash
npm install          # Install dependencies
npm start            # Start app
npm run dev          # Start with auto-reload
npm test             # Run tests
```

### On Azure VM

```bash
pm2 start app.js --name "simple-app"       # Start app
pm2 stop simple-app                         # Stop app
pm2 restart simple-app                      # Restart app
pm2 delete simple-app                       # Delete from PM2
pm2 logs simple-app                         # View logs
pm2 status                                  # List all processes
pm2 save                                    # Save config
sudo systemctl restart pm2-azureuser        # Restart PM2 after reboot
```

### Git Commands

```bash
git status                          # Check changes
git add .                          # Stage changes
git commit -m "message"            # Commit
git push origin main               # Push to GitHub
git log --oneline                  # View history
```

---

## ✅ Deployment Checklist

- [ ] Azure VM created and running
- [ ] SSH key saved locally and permissions set (600)
- [ ] Node.js 18+ installed on VM
- [ ] PM2 installed on VM
- [ ] NSG rules configured (ports 22, 3000)
- [ ] GitHub repository created
- [ ] AZURE_VM_IP secret added to GitHub
- [ ] SSH_PRIVATE_KEY secret added to GitHub
- [ ] Code pushed to main branch
- [ ] GitHub Actions workflow completed
- [ ] Application accessible at http://<ip>:3000
- [ ] Health check responding at http://<ip>:3000/health
- [ ] PM2 configured to auto-start

---

## 💰 Cost Estimation

### Azure VM (Standard B1s)

```
Compute: $7.59/month
Storage: $0.45/month
Outbound bandwidth: ~$0.05/month (minimal)

Total: ~$8-10/month

FREE tier options:
- Free account: 12 months free B1s
- 1-year free: B1s included
```

### GitHub Actions

```
Free tier: 2,000 minutes/month
Usage: ~5 minutes per deployment × 20 deployments = 100 minutes

Total: FREE (within free tier)
```

---

## 🎓 Next Steps

1. **Today**: Setup Azure VM and deploy app
2. **Tomorrow**: Add logging and monitoring
3. **This Week**: Add CI/CD improvements
4. **This Month**: Scale application

---

## 📚 Resources

- [Azure VM Docs](https://learn.microsoft.com/azure/virtual-machines/)
- [GitHub Actions](https://docs.github.com/en/actions)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/nodejs-performance-best-practices/)
- [PM2 Documentation](https://pm2.keymetrics.io/)

---

**Status**: Complete setup guide for deploying simple Node app to Azure! ✅
