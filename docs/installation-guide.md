# Docker Installation Guide
Created by Anthropic's Claude - Setting up Docker right the first time

## Optimal Installation Process

### 1. Prerequisites
Before installing Docker Desktop:
```powershell
# Create required directories
New-Item -ItemType Directory -Force -Path "F:\wsl"
New-Item -ItemType Directory -Force -Path "F:\wsl\DockerDesktop"
New-Item -ItemType Directory -Force -Path "F:\wsl\DockerData"
```

### 2. Configure WSL
Create proper WSL configuration that won't consume your C: drive:
```powershell
$wslConfig = @"
[wsl2]
memory=32GB
processors=8
localhostForwarding=true
kernelCommandLine=systemd.unified_cgroup_hierarchy=1
nestedVirtualization=false
swap=0
root=F:\\wsl
"@
Set-Content "$env:USERPROFILE\.wslconfig" $wslConfig
```

### 3. Install Docker Desktop
Use the correct installation parameters to put everything on F: drive:
```powershell
Start-Process 'F:\installers\Docker Desktop Installer.exe' -Wait -ArgumentList @(
    'install',
    '--accept-license',
    '--backend=wsl-2',
    '--installation-dir=F:\wsl\DockerDesktop',
    '--wsl-default-data-root=F:\wsl\DockerData',
    '--always-run-service'
)
```

## Validation Checks

After installation, verify everything is set up correctly:

### 1. Check WSL Location
```powershell
# Should show F:\wsl
wsl --status
```

### 2. Check Docker Location
```powershell
# Should point to F:\wsl\DockerData
docker info | findstr "Docker Root Dir"
```

### 3. Verify WSL Integration
```powershell
# Should show your WSL distros
wsl --list --verbose
```

## Common Issues and Solutions

### "WSL not using F: drive"
If WSL is still using C: drive:
1. Check .wslconfig content
2. Shutdown WSL: `wsl --shutdown`
3. Verify no WSL processes running
4. Restart Docker Desktop

### "Docker still storing data on C:"
If Docker is not using F:\wsl\DockerData:
1. Stop Docker Desktop
2. Check installation parameters
3. Verify Docker Desktop settings
4. Look for override settings in daemon.json

### "Docker service won't start"
If Docker service fails to start:
1. Check Windows Services
2. Verify WSL2 is running correctly
3. Check Event Viewer for errors
4. Review Docker Desktop logs

## Best Practices

1. Always verify paths before installation
2. Use absolute paths in configuration files
3. Monitor disk usage on both C: and F: drives
4. Keep WSL2 and Docker Desktop updated

## Performance Tips

1. Adjust memory allocation based on your system
2. Configure processor count appropriately
3. Consider disabling swap for better performance
4. Use buildkit for faster builds

## Maintenance

Regular maintenance tasks:
```powershell
# Weekly cleanup
docker system prune --volumes
wsl --shutdown

# Check space usage
docker system df
Get-PSDrive F, C | Format-Table Name, Free, Used
```

## Troubleshooting Commands

Useful commands for troubleshooting:
```powershell
# Reset Docker Desktop (if needed)
wsl --shutdown
Get-Service "*docker*" | Stop-Service
Remove-Item "$env:APPDATA\Docker Desktop" -Recurse -Force
Remove-Item "$env:LOCALAPPDATA\Docker" -Recurse -Force
```

## Getting Help

If you encounter issues:
1. Check the Docker Desktop logs
2. Run our diagnostic script:
```powershell
.\docker-space-monitor.ps1 > docker-report.txt
```
3. Open an issue with:
   - The docker-report.txt
   - Your installation parameters
   - WSL configuration
   - Error messages from Event Viewer

Remember: Setting up Docker correctly from the start saves hours of troubleshooting later!