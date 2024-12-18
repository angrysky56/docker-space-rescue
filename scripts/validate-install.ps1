# Docker Installation Validation Script
# Verifies Docker Desktop installation and configuration

function Test-DockerInstallation {
    $results = @{
        WSLConfig = $false
        DockerLocation = $false
        WSLIntegration = $false
        DockerService = $false
        NetworkAccess = $false
    }

    Write-Host "`nValidating Docker Installation..." -ForegroundColor Cyan
    Write-Host "================================`n"

    # Check WSL Configuration
    Write-Host "Checking WSL Configuration..." -NoNewline
    if (Test-Path "$env:USERPROFILE\.wslconfig") {
        $wslConfig = Get-Content "$env:USERPROFILE\.wslconfig" -Raw
        if ($wslConfig -match "root=F:\\wsl") {
            Write-Host " OK!" -ForegroundColor Green
            $results.WSLConfig = $true
        } else {
            Write-Host " Warning: WSL not configured for F: drive" -ForegroundColor Yellow
        }
    } else {
        Write-Host " Not Found!" -ForegroundColor Red
    }

    # Check Docker Location
    Write-Host "Checking Docker Location..." -NoNewline
    $dockerInfo = docker info 2>$null
    if ($dockerInfo -match "Docker Root Dir: F:\\") {
        Write-Host " OK!" -ForegroundColor Green
        $results.DockerLocation = $true
    } else {
        Write-Host " Warning: Docker not using F: drive" -ForegroundColor Yellow
    }

    # Check WSL Integration
    Write-Host "Checking WSL Integration..." -NoNewline
    $wslList = wsl --list --verbose 2>$null
    if ($wslList -match "Ubuntu") {
        Write-Host " OK!" -ForegroundColor Green
        $results.WSLIntegration = $true
    } else {
        Write-Host " Warning: WSL distro not found" -ForegroundColor Yellow
    }

    # Check Docker Service
    Write-Host "Checking Docker Service..." -NoNewline
    $service = Get-Service "*docker*" -ErrorAction SilentlyContinue
    if ($service.Status -eq "Running") {
        Write-Host " OK!" -ForegroundColor Green
        $results.DockerService = $true
    } else {
        Write-Host " Not Running!" -ForegroundColor Red
    }

    # Test Network Access
    Write-Host "Testing Network Access..." -NoNewline
    $testResult = docker run --rm hello-world 2>$null
    if ($testResult -match "Hello from Docker!") {
        Write-Host " OK!" -ForegroundColor Green
        $results.NetworkAccess = $true
    } else {
        Write-Host " Failed!" -ForegroundColor Red
    }

    # Summary
    Write-Host "`nInstallation Summary:"
    Write-Host "===================="
    $totalChecks = $results.Count
    $passedChecks = ($results.Values | Where-Object { $_ -eq $true }).Count
    
    foreach ($check in $results.Keys) {
        $status = if ($results[$check]) { "✓" } else { "✗" }
        $color = if ($results[$check]) { "Green" } else { "Red" }
        Write-Host "$status $check" -ForegroundColor $color
    }

    Write-Host "`nOverall Status: " -NoNewline
    if ($passedChecks -eq $totalChecks) {
        Write-Host "PASSED" -ForegroundColor Green
        Write-Host "Docker is correctly installed and configured!"
    } else {
        Write-Host "NEEDS ATTENTION" -ForegroundColor Yellow
        Write-Host "Some checks failed. Review the output above and consult the troubleshooting guide."
    }
}

# Run validation
Test-DockerInstallation