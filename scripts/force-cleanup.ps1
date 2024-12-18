# Force cleanup of Docker and WSL resources
$ErrorActionPreference = "SilentlyContinue"

Write-Host "Starting aggressive cleanup..." -ForegroundColor Yellow

# Stop all related services
Write-Host "Stopping services..."
Stop-Service -Force -Name "Docker*"
Stop-Service -Force -Name "com.docker.*"
Stop-Service -Force -Name "WSL*"

# Kill all related processes
Write-Host "Terminating processes..."
$processes = @(
    "wsl.exe",
    "wslhost.exe",
    "wslservice.exe",
    "docker.exe",
    "dockerd.exe",
    "com.docker.service",
    "com.docker.backend",
    "Docker Desktop.exe"
)

foreach ($proc in $processes) {
    Get-Process | Where-Object {$_.ProcessName -like $proc} | Stop-Process -Force
}

# Unregister WSL instances
Write-Host "Unregistering WSL instances..."
wsl --shutdown
Start-Sleep -Seconds 2
wsl --unregister docker-desktop
wsl --unregister docker-desktop-data

# Take ownership and set permissions
Write-Host "Taking ownership of VHDX file..."
$vhdxPath = "F:\wsl\DockerDesktopWSL\data\ext4.vhdx"
takeown /F $vhdxPath /A
icacls $vhdxPath /grant Administrators:F
icacls $vhdxPath /grant System:F

# Wait a moment
Start-Sleep -Seconds 2

# Try to delete the file
Write-Host "Attempting to delete VHDX file..."
Remove-Item -Force -Path $vhdxPath

# Check if deletion was successful
if (Test-Path $vhdxPath) {
    Write-Host "File still exists. Will try alternative removal method..." -ForegroundColor Red
    cmd /c del /F /Q $vhdxPath
}

# Final cleanup
Write-Host "Cleaning up remaining directories..."
Remove-Item -Force -Recurse "F:\wsl\DockerDesktopWSL" -ErrorAction SilentlyContinue

Write-Host "Cleanup complete!" -ForegroundColor Green