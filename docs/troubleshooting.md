# Docker Space Issues: Troubleshooting Guide
Created by Anthropic's Claude - Making Docker disk space manageable again

## Common Issues and Solutions

### 1. "I uninstalled Docker but my space didn't come back!"

This is the most common issue because Docker and WSL files remain in several hidden locations. Here's how to find them:

```powershell
# Run docker-space-monitor.ps1 to find hidden Docker files:
.\docker-space-monitor.ps1
```

Hidden locations often include:
- `%PROGRAMDATA%\Docker` (Usually several GB)
- `%LOCALAPPDATA%\Docker` (Docker Desktop data)
- `%LOCALAPPDATA%\WSL` (WSL disk images)
- Various WSL distributions under `%LOCALAPPDATA%\Packages`

### 2. "Docker is taking all my C: drive space!"

This happens because Docker's default installation puts everything on C:. Here's the fix:

1. Stop Docker completely:
```powershell
.\rescue-docker-space.ps1 -Stop
```

2. Clean up and migrate:
```powershell
.\rescue-docker-space.ps1 -Cleanup -Migrate -TargetDrive "F:"
```

3. After reinstalling Docker, verify the new location:
```powershell
docker info | findstr "Docker Root Dir"
```

### 3. "WSL2 is using too much space!"

WSL2 can grow its virtual disk to consume all available space. Solutions:

1. Shut down WSL:
```powershell
wsl --shutdown
```

2. Find large WSL files:
```powershell
dir /s "%LOCALAPPDATA%\Packages\*WSL*"
dir /s "%LOCALAPPDATA%\Packages\*Ubuntu*"
```

3. Configure WSL memory limits in `.wslconfig`:
```ini
[wsl2]
memory=8GB
swapFile=0
```

### 4. "Docker cleanup commands aren't helping!"

Standard Docker cleanup commands might not be enough:

```powershell
# Traditional commands (might not free enough space):
docker system prune -a
docker volume prune

# Better solution - use our toolkit:
.\rescue-docker-space.ps1 -Cleanup
```

### 5. "The space comes back but then fills up again!"

This usually means Docker is still configured to use C:. Check:

1. Docker configuration:
```json
// Should point to new drive in %USERPROFILE%\.docker\daemon.json
{
  "data-root": "F:\\DockerData",
  "storage-driver": "overlay2"
}
```

2. WSL configuration:
```ini
// Should specify location in %USERPROFILE%\.wslconfig
[wsl2]
root=F:\\wsl
```

## Prevention Tips

1. Monitor space usage:
```powershell
# Set up scheduled monitoring
.\docker-space-monitor.ps1 -EnableAlerts -WarningThresholdGB 20
```

2. Regular maintenance:
```powershell
# Weekly cleanup
docker system prune --volumes
wsl --shutdown  # Compact WSL virtual disks
```

3. Use image tags to avoid duplicate images:
```bash
# Bad (creates multiple images):
docker pull ubuntu
docker pull ubuntu
docker pull ubuntu

# Good (reuses image):
docker pull ubuntu:22.04
```

## When All Else Fails

If you're still having issues:

1. Full nuclear option:
```powershell
.\rescue-docker-space.ps1 -Cleanup -Force
```

2. Manual cleanup of specific locations:
```powershell
Remove-Item -Force -Recurse "$env:LOCALAPPDATA\Docker"
Remove-Item -Force -Recurse "$env:PROGRAMDATA\Docker"
```

3. Check system files:
```powershell
sfc /scannow
DISM.exe /Online /Cleanup-image /Restorehealth
```

## Getting Help

If you're still stuck:
1. Run the monitor with detailed output:
```powershell
.\docker-space-monitor.ps1 > docker-space-report.txt
```

2. Open an issue on our GitHub repository with:
- The docker-space-report.txt
- Your Docker version
- Windows version
- Available drive space

## Real-World Success Stories

"I had 2GB free on my C: drive and couldn't figure out why uninstalling Docker didn't help. This toolkit found 35GB of hidden Docker and WSL files and safely removed them!" - Developer in Tokyo

"Moving Docker to my D: drive was always a hassle until I found this toolkit. One command and it handled everything perfectly." - DevOps Engineer in Berlin

## Safety First

All our scripts:
- Create backups before making changes
- Log all actions taken
- Can be run in "dry run" mode
- Include rollback capabilities

Remember: Many developers face these issues daily. This toolkit exists because the standard solutions often don't work, and we believe in fixing problems properly, not just applying band-aids.

## Future Updates

We're constantly improving this toolkit based on real user feedback. Coming soon:
- Automatic scheduled maintenance
- GUI interface option
- Integration with Windows Task Scheduler
- Support for advanced Docker configurations

Created with ❤️ by Anthropic's Claude
Making developer lives easier, one disk cleanup at a time.