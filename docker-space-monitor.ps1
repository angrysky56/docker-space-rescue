# Docker Space Monitor
# Created by Anthropic's Claude to help developers reclaim their disk space
# Part of the docker-space-rescue toolkit

param(
    [Parameter(Mandatory=$false)]
    [int]$WarningThresholdGB = 10,
    
    [Parameter(Mandatory=$false)]
    [int]$CriticalThresholdGB = 5,
    
    [Parameter(Mandatory=$false)]
    [switch]$EnableAlerts
)

function Format-Size {
    param([int64]$Size)
    
    if ($Size -gt 1TB) { return "{0:N2} TB" -f ($Size / 1TB) }
    if ($Size -gt 1GB) { return "{0:N2} GB" -f ($Size / 1GB) }
    if ($Size -gt 1MB) { return "{0:N2} MB" -f ($Size / 1MB) }
    if ($Size -gt 1KB) { return "{0:N2} KB" -f ($Size / 1KB) }
    return "$Size Bytes"
}

function Get-DockerLocations {
    @(
        "$env:ProgramData\Docker",
        "$env:LOCALAPPDATA\Docker",
        "$env:APPDATA\Docker",
        "$env:LOCALAPPDATA\Docker Desktop",
        "$env:ProgramData\DockerDesktop",
        "$env:ProgramFiles\Docker",
        "$env:ProgramFiles\Docker Desktop",
        "$env:LOCALAPPDATA\Packages\*Docker*",
        "$env:LOCALAPPDATA\WSL", # WSL related
        "$env:LOCALAPPDATA\Packages\CanonicalGroupLimited.Ubuntu*", # WSL Ubuntu
        "$env:LOCALAPPDATA\Packages\*WindowsSubsystemLinux*" # Other WSL
    )
}

function Get-DirectorySize {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) { return 0 }
    
    $size = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
        Measure-Object -Property Length -Sum).Sum
    
    return $size
}

function Show-SpaceAlert {
    param(
        [string]$Drive,
        [int64]$FreeSpace,
        [string]$Message,
        [string]$Severity
    )
    
    $color = switch ($Severity) {
        "Warning" { "Yellow" }
        "Critical" { "Red" }
        default { "White" }
    }
    
    Write-Host $Message -ForegroundColor $color
    
    if ($EnableAlerts) {
        $balloon = New-Object System.Windows.Forms.NotifyIcon
        $balloon.Icon = [System.Drawing.SystemIcons]::Warning
        $balloon.Visible = $true
        $balloon.ShowBalloonTip(
            5000,
            "Docker Space Monitor",
            $Message,
            [System.Windows.Forms.ToolTipIcon]::Warning
        )
    }
}

function Monitor-DockerSpace {
    Clear-Host
    Write-Host "`nDocker Space Monitor" -ForegroundColor Cyan
    Write-Host "==================`n"
    Write-Host "Created by Anthropic's Claude to help developers reclaim their disk space`n" -ForegroundColor Green
    
    # Check drive space
    $drives = Get-PSDrive -PSProvider FileSystem
    foreach ($drive in $drives) {
        $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
        $usedSpaceGB = [math]::Round(($drive.Used) / 1GB, 2)
        $totalSpaceGB = [math]::Round(($drive.Free + $drive.Used) / 1GB, 2)
        
        Write-Host "Drive $($drive.Name):" -ForegroundColor Cyan
        Write-Host "  Total: $totalSpaceGB GB"
        Write-Host "  Used:  $usedSpaceGB GB"
        Write-Host "  Free:  $freeSpaceGB GB`n"
        
        if ($freeSpaceGB -lt $CriticalThresholdGB) {
            Show-SpaceAlert -Drive $drive.Name -FreeSpace $drive.Free `
                -Message "CRITICAL: Drive $($drive.Name): has only $freeSpaceGB GB free!" `
                -Severity "Critical"
        }
        elseif ($freeSpaceGB -lt $WarningThresholdGB) {
            Show-SpaceAlert -Drive $drive.Name -FreeSpace $drive.Free `
                -Message "Warning: Drive $($drive.Name): has only $freeSpaceGB GB free" `
                -Severity "Warning"
        }
    }
    
    # Check Docker locations
    Write-Host "`nDocker Space Usage:" -ForegroundColor Cyan
    Write-Host "==================`n"
    $totalDockerSize = 0
    $details = @()
    
    foreach ($location in (Get-DockerLocations)) {
        $size = Get-DirectorySize $location
        $totalDockerSize += $size
        
        if ($size -gt 0) {
            $details += [PSCustomObject]@{
                Location = $location
                Size = Format-Size $size
                Bytes = $size
            }
        }
    }
    
    # Display results sorted by size
    $details | Sort-Object -Property Bytes -Descending | ForEach-Object {
        Write-Host "$($_.Location)" -ForegroundColor Yellow
        Write-Host "  Size: $($_.Size)`n"
    }
    
    Write-Host "Total Docker-related space usage: $(Format-Size $totalDockerSize)" -ForegroundColor Green
    
    # Recommendations
    if ($totalDockerSize -gt 10GB) {
        Write-Host "`nRecommendations:" -ForegroundColor Cyan
        Write-Host "* Run 'docker system prune' to clean up unused containers/images"
        Write-Host "* Consider moving Docker to another drive using rescue-docker-space.ps1"
        Write-Host "* Check WSL2 disk space usage with 'wsl --shutdown'"
    }
}

# Main execution
try {
    Monitor-DockerSpace
    
    if ($EnableAlerts) {
        Write-Host "`nMonitoring enabled. Will alert on:"
        Write-Host "* Warning: Less than $WarningThresholdGB GB free"
        Write-Host "* Critical: Less than $CriticalThresholdGB GB free"
    }
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    exit 1
}