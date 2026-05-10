################################
# Build and Push to JFrog (PowerShell)
# Usage: .\scripts\build-and-push.ps1 -Tag "1.0.0"
# Example: .\scripts\build-and-push.ps1 -Tag latest
################################

param(
    [string]$Tag = "latest",
    [string]$Registry = "localhost:8082",
    [string]$Repo = "docker-local",
    [string]$Image = "simple-node-app"
)

$FullImage = "$Registry/$Repo/$Image`:$Tag"

Write-Host "🐳 Docker Build & Push to JFrog" -ForegroundColor Cyan
Write-Host "Registry: $Registry"
Write-Host "Repository: $Repo"
Write-Host "Image: $Image"
Write-Host "Tag: $Tag"
Write-Host "Full: $FullImage"
Write-Host ""

# Step 1: Build
Write-Host "Step 1: 🔨 Building Docker image..." -ForegroundColor Cyan
docker build -t "$Image`:latest" -t "$Image`:$Tag" .
Write-Host "✅ Build complete!" -ForegroundColor Green
Write-Host ""

# Step 2: Tag
Write-Host "Step 2: 🏷️  Tagging for JFrog..." -ForegroundColor Cyan
docker tag "$Image`:latest" "$FullImage"
if ($Tag -ne "latest") {
    docker tag "$Image`:$Tag" "$Registry/$Repo/$Image`:$Tag"
}
Write-Host "✅ Tagging complete!" -ForegroundColor Green
Write-Host ""

# Step 3: Login
Write-Host "Step 3: 🔐 Authenticating to registry..." -ForegroundColor Cyan
$login = Read-Host "Need to login? (y/n) [n]"
if ($login -eq "y" -or $login -eq "Y") {
    $user = Read-Host "Username (default: admin)"
    if ([string]::IsNullOrEmpty($user)) { $user = "admin" }
    
    $pass = Read-Host "Password" -AsSecureString
    $passPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicodePtr($pass))
    
    $pass | ConvertFrom-SecureString | Out-Null
    docker login -u $user -p "$passPlain" $Registry
    Write-Host "✅ Login successful!" -ForegroundColor Green
} else {
    Write-Host "⏭️  Skipping login" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Push
Write-Host "Step 4: 📤 Pushing to JFrog..." -ForegroundColor Cyan
docker push "$FullImage"
if ($Tag -ne "latest") {
    docker push "$Registry/$Repo/$Image`:$Tag"
}
Write-Host "✅ Push complete!" -ForegroundColor Green
Write-Host ""

# Step 5: Verify
Write-Host "Step 5: ✔️  Verifying..." -ForegroundColor Cyan
$verify = Read-Host "Verify with API? (y/n) [n]"
if ($verify -eq "y" -or $verify -eq "Y") {
    $user = Read-Host "Username (default: admin)"
    if ([string]::IsNullOrEmpty($user)) { $user = "admin" }
    
    $pass = Read-Host "Password" -AsSecureString
    $passPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicodePtr($pass))
    
    $ApiUrl = "http://localhost:8081/artifactory/api/storage/$Repo/$Image/$Tag"
    Write-Host "Checking: $ApiUrl"
    
    $response = Invoke-RestMethod -Uri $ApiUrl -Authentication Basic -Credential (New-Object System.Management.Automation.PSCredential($user, (ConvertTo-SecureString $passPlain -AsPlainText -Force)))
    $response | ConvertTo-Json | Write-Host
    Write-Host "✅ Verification complete!" -ForegroundColor Green
} else {
    Write-Host "⏭️  Skipping verification" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "✅ All done!" -ForegroundColor Green
Write-Host ""
Write-Host "Access your image:" -ForegroundColor Cyan
Write-Host "  Docker: docker pull $FullImage"
Write-Host "  UI: http://localhost:8081/artifactory"
Write-Host "  Registry UI: http://localhost:8080"
