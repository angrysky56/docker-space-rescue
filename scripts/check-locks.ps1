# Find processes locking a file
$HandlePath = "$env:TEMP\handle.exe"
$HandleZip = "$env:TEMP\handle.zip"

# Download Handle tool if not exists
if (-not (Test-Path $HandlePath)) {
    Invoke-WebRequest "https://download.sysinternals.com/files/Handle.zip" -OutFile $HandleZip
    Expand-Archive $HandleZip $env:TEMP -Force
}

# Run handle.exe to find processes
$output = & $HandlePath -a "F:\wsl\DockerDesktopWSL\data\ext4.vhdx" -nobanner
Write-Host "Processes holding the file:"
$output | Where-Object { $_ -match "pid:" } | ForEach-Object {
    $pid = ($_ -split "pid: ")[1].Split(" ")[0]
    $processName = (Get-Process -Id $pid).ProcessName
    Write-Host "Process: $processName (PID: $pid)"
}