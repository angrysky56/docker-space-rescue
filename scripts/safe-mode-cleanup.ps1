# Safe Mode VHDX Cleanup Script
# Run as Administrator

$vhdxPath = "F:\wsl\DockerDesktopWSL\data\ext4.vhdx"
$marker = "F:\wsl\cleanup_pending.txt"

# Phase 1: Before Safe Mode
if (-not (Test-Path $marker)) {
    Write-Host "Phase 1: Preparing for Safe Mode..." -ForegroundColor Cyan
    
    # Create marker file with instructions
    @"
Cleanup Instructions:
1. Delete file: $vhdxPath
2. Run: bcdedit /deletevalue {current} safeboot
3. shutdown /r /t 0
"@ | Out-File $marker

    # Configure next boot for Safe Mode
    bcdedit /set {current} safeboot minimal
    
    Write-Host "`nSystem will now reboot into Safe Mode."
    Write-Host "After reboot, run this script again to complete cleanup.`n"
    
    $response = Read-Host "Press Enter to reboot into Safe Mode, or Ctrl+C to cancel"
    shutdown /r /t 5
}
# Phase 2: In Safe Mode
elseif (Test-Path $marker) {
    Write-Host "Phase 2: Safe Mode Cleanup..." -ForegroundColor Cyan
    
    if (Test-Path $vhdxPath) {
        try {
            Remove-Item -Path $vhdxPath -Force
            Write-Host "Successfully deleted VHDX file!" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to delete VHDX: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "VHDX file not found - may already be deleted" -ForegroundColor Yellow
    }
    
    # Remove Safe Mode boot
    bcdedit /deletevalue {current} safeboot
    
    # Clean up marker
    Remove-Item $marker -Force
    
    Write-Host "`nSystem will now reboot back to normal mode."
    $response = Read-Host "Press Enter to reboot, or Ctrl+C to cancel"
    shutdown /r /t 5
}
