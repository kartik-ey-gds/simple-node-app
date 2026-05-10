################################
# JFrog UI - One Command Start (PowerShell)
# Usage: .\scripts\start-jfrog-ui.ps1
################################

Write-Host "🚀 Starting JFrog Artifactory UI..." -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
try {
    $dockerInfo = docker ps 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
} catch {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker and try again."
    exit 1
}

# Check if already running
$running = docker ps 2>$null | Select-String "jfrog-ui"
if ($running) {
    Write-Host "⚠️  JFrog UI is already running!" -ForegroundColor Yellow
    Write-Host "Access it at: http://localhost:8081/artifactory"
    exit 0
}

# Start JFrog
Write-Host "Starting container..." -ForegroundColor Cyan
docker-compose -f docker-compose-jfrog-ui-simple.yml up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to start JFrog!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ JFrog UI container started!" -ForegroundColor Green
Write-Host ""
Write-Host "⏳ Waiting for JFrog to startup (30-60 seconds)..." -ForegroundColor Yellow
Write-Host ""

# Wait for health check
$timeout = 120
$elapsed = 0

while ($elapsed -lt $timeout) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8081/artifactory/api/system/ping" -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host ""
            Write-Host "✅ JFrog UI is ready!" -ForegroundColor Green
            Write-Host ""
            Write-Host "📍 Access: http://localhost:8081/artifactory" -ForegroundColor Cyan
            Write-Host "👤 Username: admin"
            Write-Host "🔐 Password: password"
            Write-Host ""
            Write-Host "💡 Change password in: Admin → Security → Users" -ForegroundColor Yellow
            Write-Host ""
            exit 0
        }
    } catch {
        # Still waiting
    }
    
    # Show progress every 10 seconds
    if ($elapsed % 10 -eq 0 -and $elapsed -gt 0) {
        Write-Host "⏳ Waiting... ${elapsed}s" -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds 1
    $elapsed += 1
}

Write-Host ""
Write-Host "⚠️  JFrog is taking longer than usual." -ForegroundColor Yellow
Write-Host "Check logs with: docker logs -f jfrog-ui"
Write-Host "Try accessing: http://localhost:8081/artifactory"
