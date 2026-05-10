# 🚀 Simple Node App - START HERE

## 📁 What You Have

```
simple-node-app/
├── app.js                    # Main application (4 simple endpoints)
├── package.json             # Dependencies
├── .env.example             # Environment variables template
├── Dockerfile               # Docker containerization
├── docker-compose.yml       # Local Docker setup
├── .gitignore              # Git ignore rules
├── .github/
│   └── workflows/
│       └── deploy.yml      # ⭐ CI/CD Pipeline (automated deployment)
├── README.md               # Quick reference
├── DEPLOYMENT_GUIDE.md     # Complete deployment steps
├── AZURE_SETUP.md          # ⭐ Azure setup (read this first!)
└── AZURE_QUICK_START.md    # Quick commands reference
```

---

## 🎯 What This Does

```
You push code to GitHub
        ↓
GitHub Actions triggers
        ↓
Builds & tests your code
        ↓
Deploys to Azure VM via SSH
        ↓
App runs with PM2
        ↓
You can access it: http://<your-ip>:3000
```

---

## 📖 Read These in Order

### 1️⃣ **FIRST: AZURE_SETUP.md** (20 minutes)
   - Create Azure VM
   - Configure networking
   - Setup SSH access
   - Prepare VM (install Node.js, PM2, Git)
   - **This is 90% of the work!**

### 2️⃣ **SECOND: DEPLOYMENT_GUIDE.md** (10 minutes)
   - Create GitHub repo
   - Add GitHub Secrets
   - Push code
   - Automatic deployment!

### 3️⃣ **Reference: README.md** (anytime)
   - Quick commands
   - Troubleshooting
   - Common tasks

---

## ⚡ Ultra-Quick Summary

### What to Do on Azure
```bash
1. Create VM (Ubuntu 20.04, B1s size)
2. Get SSH key & Public IP
3. Open ports 22 (SSH) and 3000 (App)
4. SSH into VM
5. Run setup commands:
   - sudo apt update && sudo apt install -y nodejs npm git
   - sudo npm install -g pm2
   - mkdir ~/simple-node-app
```

### What to Do on GitHub
```bash
1. Create repository
2. Add Secrets:
   - AZURE_VM_IP = your VM's IP
   - SSH_PRIVATE_KEY = your SSH key
3. Push code
4. GitHub Actions auto-deploys! 🎉
```

### Result
```
http://<your_ip>:3000  ✅ Your app is live!
```

---

## 🔍 The 4 Endpoints

```
GET  /                     # Welcome message
GET  /health              # Health check
GET  /api/info            # App info
POST /api/echo            # Echo request body
```

**Test them:**
```bash
curl http://<your_ip>:3000/health
curl -X POST http://<your_ip>:3000/api/echo \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello!"}'
```

---

## 📊 Files Breakdown

### `app.js` - Your Application
- 4 simple endpoints
- Error handling
- Runs on port 3000

### `.github/workflows/deploy.yml` - CI/CD Pipeline
- ✅ Builds your code
- ✅ Runs tests
- ✅ Deploys to Azure VM
- ✅ Checks if app is healthy

### `AZURE_SETUP.md` - Azure Configuration
- Step-by-step screenshots (almost!)
- How to create VM
- How to open ports
- How to install dependencies
- Copy-paste commands

### `DEPLOYMENT_GUIDE.md` - Full Deployment
- Azure VM details
- GitHub setup
- Troubleshooting
- Monitoring commands

---

## ✅ Complete Setup Checklist

### Azure (20 min)
- [ ] Create Resource Group: `simple-app-rg`
- [ ] Create VM: `simple-app-vm` (B1s, Ubuntu 20.04)
- [ ] Download SSH key: `simple-app-key.pem`
- [ ] Get Public IP: `52.123.45.67`
- [ ] Add NSG rules: Port 22 (SSH), Port 3000 (App)
- [ ] SSH into VM works
- [ ] Node.js 18+ installed
- [ ] PM2 installed globally
- [ ] Git installed
- [ ] App directory created: `~/simple-node-app`

### GitHub (10 min)
- [ ] Create repository
- [ ] Add Secret: `AZURE_VM_IP`
- [ ] Add Secret: `SSH_PRIVATE_KEY`
- [ ] Clone repo locally
- [ ] Push code to main

### Deployment (Auto!)
- [ ] GitHub Actions runs
- [ ] App deploys to Azure VM
- [ ] App starts with PM2
- [ ] Health check passes ✅

### Verify
- [ ] Curl: `curl http://<ip>:3000/health`
- [ ] Browser: `http://<ip>:3000`
- [ ] Success! 🎉

---

## 💰 Cost

```
Azure VM (B1s): $7-10/month
GitHub Actions: FREE
Storage: ~$0.50/month

Total: ~$8-10/month
```

**Free tier available:** First 12 months on Azure free!

---

## 🚨 Most Common Issues

| Issue | Solution |
|-------|----------|
| **SSH won't connect** | Check key permissions: `chmod 600 key.pem` |
| **Port 3000 blocked** | Add NSG rule in Azure Portal |
| **GitHub Actions fails** | Check SSH key secret format |
| **App not starting** | `pm2 logs simple-app` to see error |
| **Can't find IP** | Azure Portal → VM → Overview → Public IP |

---

## 🔄 Making Changes

**Once everything is setup, updating is easy:**

```bash
# Make change locally
nano app.js

# Test
npm start

# Push to GitHub
git add .
git commit -m "Update message"
git push origin main

# ✅ GitHub Actions auto-deploys!
```

---

## 📱 Access Your App

**From anywhere:**
```
http://<your_public_ip>:3000
```

**From terminal:**
```bash
curl http://<ip>:3000/
curl http://<ip>:3000/health
curl http://<ip>:3000/api/info
```

**From browser:**
- http://your-vm-ip:3000
- http://your-vm-ip:3000/health
- http://your-vm-ip:3000/api/info

---

## 🎓 How It Works

```
GitHub Repository
       ↓ (you push code)
GitHub Actions
       ↓ (workflow triggers)
Builds & Tests
       ↓
Connects via SSH
       ↓
Pulls latest code
       ↓
npm install
       ↓
Restarts app with PM2
       ↓
Health check
       ↓
Verification ✅
       ↓
Your app is live!
```

---

## 📞 Need Help?

**Check these files in order:**

1. **AZURE_SETUP.md** - "I can't create/access the VM"
2. **DEPLOYMENT_GUIDE.md** - "Deployment steps"
3. **README.md** - "Quick reference"

---

## 🎯 Next Steps

### Today
- [ ] Read AZURE_SETUP.md
- [ ] Create Azure VM
- [ ] Setup networking
- [ ] SSH into VM
- [ ] Install dependencies

### Tomorrow
- [ ] Create GitHub repo
- [ ] Add secrets
- [ ] Push code
- [ ] Watch auto-deployment!

### This Week
- [ ] Test endpoints
- [ ] Make code changes
- [ ] Verify auto-deployment
- [ ] Add monitoring

---

## 🌟 What's Included

✅ **Simple Node.js app** - 4 endpoints
✅ **CI/CD pipeline** - Automated deployment
✅ **Docker support** - Container ready
✅ **PM2 management** - Process monitoring
✅ **Health checks** - Automatic verification
✅ **Production ready** - ~$8/month cost

---

## 📚 Documentation Files

| File | Purpose | Read When |
|------|---------|-----------|
| **AZURE_SETUP.md** | Azure VM setup | Starting out |
| **DEPLOYMENT_GUIDE.md** | Complete deployment guide | Need details |
| **README.md** | Quick reference | Need quick answer |
| **app.js** | Your application code | Modifying app |
| **.github/workflows/deploy.yml** | CI/CD pipeline | Understanding automation |

---

## ✨ You're Ready!

**Everything you need is here. Start with AZURE_SETUP.md!**

---

**Questions?** Check the troubleshooting section in DEPLOYMENT_GUIDE.md
**Ready?** Go to AZURE_SETUP.md and start! 🚀
