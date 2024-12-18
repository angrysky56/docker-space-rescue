# Download and set up Process Explorer
$procExpUrl = "https://download.sysinternals.com/files/ProcessExplorer.zip"
$downloadPath = "F:\ai_workspace\Nexus-Prime\docker-space-rescue\tools"
$zipPath = Join-Path $downloadPath "ProcessExplorer.zip"

# Create tools directory
New-Item -ItemType Directory -Force -Path $downloadPath

# Download Process Explorer
Invoke-WebRequest -Uri $procExpUrl -OutFile $zipPath

# Extract the zip
Expand-Archive -Path $zipPath -DestinationPath $downloadPath -Force

Write-Host @"
Process Explorer has been downloaded and extracted to:
$downloadPath

To find what's locking the VHDX file:
1. Run procexp64.exe as Administrator
2. Press Ctrl+F
3. Search for "ext4.vhdx"
4. The search results will show which process has the file locked
5. You can then right-click the process and select 'Kill Process Tree'

Would you like me to run Process Explorer now?
"@