# Docker Space Rescue 🚀

## Caution AI generated code!!! This will absolutely ***NUKE*** your containers!!! It will all be gone. Do not listen to Claudes readme to much. You will need to modify the code to fit your needs.

A practical toolkit for rescuing your C: drive from Docker and WSL space issues, with scripts for cleanup and migration to another drive.

## The Problem This Solves

Many developers face these common issues:
- Docker and WSL consuming all C: drive space
- Unclear or outdated solutions online
- Failed attempts to move Docker to another drive
- Hidden files that aren't cleaned up after uninstall

## Quick Solution

```powershell
# 1. Download and run as Administrator
.\rescue-docker-space.ps1 -TargetDrive "F:"
```

Before:
```
C: Drive - 2GB free 😱
Docker files scattered across system
```

After:
```
C: Drive - 37GB free 🎉
Docker properly configured on F: drive
```

## Features

- 🧹 Deep cleanup of Docker remnants
- 🚚 Migration to another drive
- 📊 Space usage monitoring
- ⚙️ Automatic configuration
- 🔍 Hidden file detection
- 🛡️ Safe cleanup with backups
- 📝 Detailed logging

## Detailed Guides

- [Complete Cleanup Guide](docs/cleanup-guide.md)
- [Drive Migration Guide](docs/migration-guide.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Space Monitoring](docs/monitoring-guide.md)

## Scripts

1. `rescue-docker-space.ps1` - Main cleanup and migration script
2. `docker-space-monitor.ps1` - Ongoing space monitoring
3. `config-templates/` - WSL and Docker configurations
4. `utils/` - Helper utilities

## Common Issues Solved

✅ "Docker is taking all my C: drive space!"
✅ "I uninstalled Docker but my space didn't come back"
✅ "I can't move Docker to another drive"
✅ "WSL2 is consuming too much space"
✅ "Docker cleanup guides don't work"

## Usage

1. Stop Docker and related services:
```powershell
.\rescue-docker-space.ps1 -Stop
```

2. Clean up Docker remnants:
```powershell
.\rescue-docker-space.ps1 -Cleanup
```

3. Migrate to another drive:
```powershell
.\rescue-docker-space.ps1 -Migrate -TargetDrive "F:"
```

4. Monitor space usage:
```powershell
.\docker-space-monitor.ps1
```

## Safety First

- Creates backups before cleanup
- Verifies successful operations
- Logs all actions
- Rollback capability
- Safe default settings

## Requirements

- Windows 10/11
- PowerShell 5.1 or higher
- Administrator privileges
- Docker Desktop (if reinstalling)

## Contributing

Found a hidden Docker file we missed? Know another cleanup trick? Create a pull request!

## Support

- 📚 [Documentation](docs/)
- 🐛 [Issue Tracker](issues/)
- 💬 [Discussions](discussions/)

## License

MIT - Feel free to use and modify!
