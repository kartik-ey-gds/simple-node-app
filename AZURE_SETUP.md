# Azure Setup - Complete Step by Step

## 🎯 What We'll Setup

```
Azure Subscription
    ├── Virtual Machine (Ubuntu 20.04)
    ├── Network Security Group (Firewall)
    ├── Public IP Address
    └── Storage Account (optional)
```

---

## 📋 PHASE 1: Prerequisites (5 minutes)

### Check You Have:
- [ ] Azure subscription (free account works: azure.microsoft.com/free)
- [ ] Credit card (for account verification)
- [ ] SSH key pair (or we'll generate one)
- [ ] GitHub account

---

## 🔵 PHASE 2: Create Azure VM (10 minutes)

### Step 1: Sign in to Azure Portal
```
Go to: https://portal.azure.com
Sign in with Microsoft account
```

### Step 2: Create Resource Group

**Why?** Organize all resources together

```
Home → Resource Groups → + Create

Name: simple-app-rg
Region: (choose closest to you)
     - East US (if in US)
     - Europe West (if in Europe)
     - Southeast Asia (if in Asia)

Click: Review + Create → Create
```

**Wait for deployment** (20 seconds)

---

### Step 3: Create Virtual Machine

**Go to:**
```
Home → Virtual Machines → + Create → Azure virtual machine
```

**Fill in Basic Tab:**

| Field | Value |
|-------|-------|
| Subscription | (select yours) |
| Resource Group | simple-app-rg |
| VM Name | simple-app-vm |
| Region | (same as resource group) |
| Image | Ubuntu Server 20.04 LTS - x64 Gen2 |
| VM Architecture | x64 |
| Size | Standard B1s (cheapest: ~$7/month) |

**Click: Next: Disks**

```
OS disk type: Standard SSD
Size: 30 GB (default, fine)

Click: Next: Networking
```

**Click: Next: Management**

```
Leave defaults
Click: Next: Advanced
```

**Click: Review + Create**

---

### Step 4: Generate SSH Key Pair

**On Review Tab:**

```
Scroll to: Administrator account
Authentication type: SSH public key

SSH key pair name: simple-app-key

Click: Generate new key pair
```

**A private key file downloads:**
```
simple-app-key.pem
Save it to: C:\Users\YourUser\Downloads\
Keep it SAFE!
```

**Click: Create**

**Wait for deployment** (2-3 minutes)

---

## 🔓 PHASE 3: Configure Networking (5 minutes)

### Step 1: Find Your VM

```
Portal → Virtual Machines → simple-app-vm
```

**Note Public IP:**
```
Overview tab → Public IP address: 52.123.45.67
Copy this! You'll need it!
```

---

### Step 2: Add Firewall Rules (Network Security Group)

**Go to:**
```
Virtual Machines → simple-app-vm
→ Networking → Network settings
```

**You'll see your NSG in the list. Click on it:**
```
something-nsg → Inbound security rules
```

---

### Step 3: Add Inbound Rule - SSH

**Click: + Add**

```
Source: Your IP (or 0.0.0.0/0 for testing)
Source port ranges: *
Destination: Any
Destination port ranges: 22
Protocol: TCP
Action: Allow
Priority: 100
Name: AllowSSH

Click: Add
```

---

### Step 4: Add Inbound Rule - App (Port 3000)

**Click: + Add**

```
Source: 0.0.0.0/0 (anyone can access)
Source port ranges: *
Destination: Any
Destination port ranges: 3000
Protocol: TCP
Action: Allow
Priority: 101
Name: AllowApp

Click: Add
```

---

### Step 5: Verify Rules

```
You should see:
✅ AllowSSH (port 22)
✅ AllowApp (port 3000)
```

---

## 💻 PHASE 4: Connect to VM (3 minutes)

### Option 1: Windows PowerShell

**Open PowerShell as Administrator:**

```powershell
# Set correct permissions on key
cd Downloads
icacls simple-app-key.pem /inheritance:r /grant:r "$($env:USERNAME):(F)"

# SSH to VM
ssh -i simple-app-key.pem azureuser@52.123.45.67
```

**Accept host key:** Type `yes`

### Option 2: Windows SSH Client

```bash
# Set permissions
chmod 600 simple-app-key.pem

# SSH
ssh -i simple-app-key.pem azureuser@52.123.45.67
```

### Option 3: PuTTY (GUI)

```
PuTTY Host Name: azureuser@52.123.45.67
Auth → Private key file: simple-app-key.pem
Click: Open
```

---

## ⚙️ PHASE 5: Setup VM (5 minutes)

**You're now inside the VM. Run these commands:**

### Step 1: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 2: Install Node.js

```bash
curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs npm
```

**Verify:**
```bash
node --version    # Should show v18.x.x
npm --version     # Should show 9.x.x
```

### Step 3: Install PM2 (Process Manager)

```bash
sudo npm install -g pm2
```

**Configure auto-start:**
```bash
pm2 startup
pm2 install pm2-logrotate
```

### Step 4: Install Git

```bash
sudo apt install -y git
```

**Verify:**
```bash
git --version     # Should show git version 2.x.x
```

### Step 5: Create App Directory

```bash
mkdir -p ~/simple-node-app
cd ~/simple-node-app
```

**Verify:**
```bash
ls -la
pwd    # Should show /home/azureuser/simple-node-app
```

---

## ✅ PHASE 6: Verify VM is Ready

**Run these checks:**

```bash
# Check Node
node -e "console.log('✅ Node.js works')"

# Check npm
npm list -g pm2

# Check permissions
whoami    # Should be: azureuser
pwd       # Should be: /home/azureuser/simple-node-app

# Check ports are open
sudo netstat -tuln | grep LISTEN
```

---

## 🚀 PHASE 7: Prepare for Deployment

### Step 1: Clone Your GitHub Repo

**First, go to GitHub and create a public repo**

```bash
# From your VM
cd ~/simple-node-app
git clone https://github.com/YOUR_USERNAME/simple-node-app.git .
```

### Step 2: Install Dependencies

```bash
npm install --production
```

### Step 3: Start Application Manually (Test)

```bash
node app.js
```

**You should see:**
```
✅ Server running on port 3000
📍 Try: http://localhost:3000/
```

**Press Ctrl+C to stop**

---

## 🧪 PHASE 8: Test Everything

### From Another Terminal (Local Machine)

```bash
# Test root endpoint
curl http://52.123.45.67:3000/

# Test health
curl http://52.123.45.67:3000/health

# Test API
curl http://52.123.45.67:3000/api/info
```

**You should get JSON responses!**

---

## 📊 PHASE 9: GitHub Actions Setup

### Step 1: Create Repository Secret - VM IP

```
GitHub.com → Your Repo
→ Settings → Secrets and variables → Actions
→ New repository secret

Name: AZURE_VM_IP
Value: 52.123.45.67 (your VM's public IP)

Click: Add secret
```

### Step 2: Create Repository Secret - SSH Key

```
Name: SSH_PRIVATE_KEY
Value: (contents of simple-app-key.pem)
```

**How to copy the key:**

**Windows PowerShell:**
```powershell
Get-Content C:\Users\YourUser\Downloads\simple-app-key.pem -Raw | Set-Clipboard
```

**Mac/Linux:**
```bash
cat ~/Downloads/simple-app-key.pem | pbcopy
```

**Then paste in GitHub secret**

### Step 3: Verify Secrets

```
Secrets should show:
✅ AZURE_VM_IP
✅ SSH_PRIVATE_KEY
```

---

## 📤 PHASE 10: Deploy with GitHub Actions

### Step 1: Push Code

```bash
# From local machine
git add .
git commit -m "Initial commit: Simple Node app"
git push origin main
```

### Step 2: Watch Deployment

```
GitHub → Actions → See workflow running
Shows status: In Progress → Success ✅
```

### Step 3: Access Application

**Open browser:**
```
http://52.123.45.67:3000/
```

**You should see:**
```json
{
  "message": "Welcome to Simple Node App",
  "status": "running",
  "version": "1.0.0",
  "timestamp": "..."
}
```

---

## 🔍 PHASE 11: Monitor Application

### Check on Azure VM

```bash
ssh -i simple-app-key.pem azureuser@52.123.45.67

# View all processes
pm2 status

# View logs
pm2 logs simple-app

# Real-time monitoring
pm2 monit
```

---

## ⚠️ Cost Management

### Monitor Costs

```
Portal → Cost Management + Billing
→ Cost analysis

Shows:
- Estimated monthly cost
- Usage breakdown
- Alerts if exceeding budget
```

### Set Budget Alert

```
Cost Management + Billing
→ Budgets → + Add

Name: Simple-app-budget
Amount: $15 (per month)
Alert when: 80% of budget
Recipients: your-email@example.com

Create
```

---

## 🔐 Security Checklist

- [ ] SSH key permissions: 600 (chmod 600 key.pem)
- [ ] SSH key backed up safely
- [ ] NSG rules restricted (or limited by IP)
- [ ] VM password disabled (SSH only)
- [ ] Automatic updates enabled
- [ ] Firewall configured
- [ ] Secrets in GitHub encrypted
- [ ] No passwords in code or logs

---

## 📋 Troubleshooting

### Can't SSH to VM

```bash
# Check:
1. Is VM running?
   Portal → VM → should say "Running"

2. Is key correct?
   ls -la simple-app-key.pem

3. Are permissions correct?
   chmod 600 simple-app-key.pem

4. Is IP correct?
   Portal → VM → Overview → Public IP
```

### Port 3000 Not Accessible

```bash
# Check NSG rule exists
Portal → VM → Networking → Inbound rules
Should show: Port 3000 TCP Allow

# Check app is running
ssh azureuser@<ip>
pm2 status

# Restart app if needed
pm2 restart simple-app
```

### GitHub Actions Fails

```
GitHub → Actions → Click failed run → View logs

Common issues:
1. SSH key in wrong format
2. AZURE_VM_IP wrong
3. VM not reachable
4. App fails to start
```

---

## ✅ Deployment Checklist

- [ ] Azure subscription active
- [ ] Resource group created
- [ ] VM created (B1s size)
- [ ] SSH key downloaded and secured
- [ ] Public IP noted
- [ ] NSG rules added (ports 22, 3000)
- [ ] SSH into VM works
- [ ] Node.js installed
- [ ] PM2 installed
- [ ] Git installed
- [ ] App directory created
- [ ] GitHub repo created
- [ ] GitHub secrets added
- [ ] Code pushed to main
- [ ] GitHub Actions ran successfully
- [ ] App accessible at http://<ip>:3000
- [ ] Health check passes

---

## 📊 What You Now Have

✅ **Production-ready VM in Azure**
✅ **Automated CI/CD pipeline**
✅ **Simple Node.js application running**
✅ **Health monitoring**
✅ **Cost < $10/month**

---

## 🎓 Next Steps

1. **Today**: Complete this setup
2. **Tomorrow**: Test with code changes
3. **This Week**: Add monitoring & logging
4. **This Month**: Scale if needed

---

## 📚 Resources

- [Azure VM Tutorial](https://learn.microsoft.com/azure/virtual-machines/linux/quick-create-portal)
- [SSH Configuration](https://learn.microsoft.com/azure/virtual-machines/linux/ssh-from-windows)
- [NSG Configuration](https://learn.microsoft.com/azure/virtual-network/network-security-groups-overview)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

---

**Status**: Azure setup complete! Ready to deploy! 🚀
