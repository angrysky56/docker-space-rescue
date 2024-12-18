$handlePath = "F:\ai_workspace\Nexus-Prime\docker-space-rescue\tools\Handle\handle64.exe"
$vhdxPath = "F:\wsl\DockerDesktopWSL\data\ext4.vhdx"

Write-Host "Finding handles for $vhdxPath..."
# First find handles
$output = & $handlePath $vhdxPath -nobanner
Write-Host "Handle output:"
Write-Host $output

# Parse output for process IDs and handle values
$handleInfo = $output | Where-Object { $_ -match "pid:" } | ForEach-Object {
    if ($_ -match "pid:\s+(\d+)\s+(.+?)\s+(\w+):\s+") {
        @{
            PID = $matches[1]
            Handle = $matches[3]
        }
    }
}

if ($handleInfo) {
    Write-Host "`nFound the following handles:"
    foreach ($info in $handleInfo) {
        Write-Host "PID: $($info.PID), Handle: $($info.Handle)"
        Write-Host "Attempting to close handle..."
        & $handlePath -p $info.PID -c $info.Handle -y
    }
} else {
    Write-Host "No handles found for the VHDX file"
}

Write-Host "`nDone. Check if handles were closed."