# Docker Space Rescue
# A comprehensive solution for Docker space issues and drive migration
# Run as Administrator

param(
    [Parameter(Mandatory=$false)]
    [string]$TargetDrive = "F:",
    
    [Parameter(Mandatory=$false)]
    [switch]$Cleanup,
    
    [Parameter(Mandatory=$false)]
    [switch]$Migrate,
    
    [Parameter(Mandatory=$false)]
    [switch]$Stop,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Initialize logging
$LogPath = "docker-rescue-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$BackupPath = "docker-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

function Write-Log {
    param($Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Tee-Object -FilePath $LogPath -Append
}

function Test-AdminPrivileges {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Set-DockerConfig {
    param($DriveRoot)
    
    Write-Log "Configuring Docker for $DriveRoot..."
    
    # Create WSL config - UPDATED with correct settings
    $wslConfig = @"
[wsl2]
memory=32GB
processors=8
localhostForwarding=true
kernelCommandLine=systemd.unified_cgroup_hierarchy=1
nestedVirtualization=false
swap=0
root=${DriveRoot}wsl
"@
    
    New-Item -Path "$env:USERPROFILE\.wslconfig" -Value $wslConfig -Force
    Write-Log "Created WSL config at: $env:USERPROFILE\.wslconfig"
    
    # Create Docker config
    $dockerConfig = @"
{
    "data-root": "${DriveRoot}DockerData",
    "storage-driver": "overlay2",
    "features": {
        "buildkit": true
    },
    "experimental": true,
    "dns": ["8.8.8.8", "8.8.4.4"],
    "default-address-pools": [
        {
            "base": "172.17.0.0/16",
            "size": 24
        }
    ],
    "hosts": ["tcp://0.0.0.0:2375", "npipe://"],
    "insecure-registries": ["host.docker.internal:5000"],
    "fixed-cidr": "172.17.0.0/16",
    "fixed-cidr-v6": "fc00::/7"
}
"@
    
    New-Item -Path "$env:USERPROFILE\.docker" -ItemType Directory -Force
    New-Item -Path "$env:USERPROFILE\.docker\daemon.json" -Value $dockerConfig -Force
    Write-Log "Created Docker config at: $env:USERPROFILE\.docker\daemon.json"
    
    # Create necessary directories
    New-Item -ItemType Directory -Force -Path "${DriveRoot}DockerData"
    New-Item -ItemType Directory -Force -Path "${DriveRoot}wsl"
    New-Item -ItemType Directory -Force -Path "${DriveRoot}wsl\DockerDesktop"
    Write-Log "Created Docker directories on $DriveRoot"
}

function Install-DockerDesktop {
    param($InstallerPath, $DriveRoot)
    
    Write-Log "Installing Docker Desktop..."
    try {
        # Updated installation command with all necessary parameters
        Start-Process $InstallerPath -Wait -ArgumentList @(
            'install',
            '--accept-license',
            '--backend=wsl-2',
            "--installation-dir=${DriveRoot}wsl\DockerDesktop",
            "--wsl-default-data-root=${DriveRoot}wsl\DockerData",
            '--always-run-service'
        )
        Write-Log "Docker Desktop installation completed successfully"
    }
    catch {
        Write-Log "Error during Docker Desktop installation: $_"
        throw
    }
}

# ... [rest of the existing script remains the same] ...

# Update the main execution flow to use new installation method
if ($Migrate) {
    Set-DockerConfig -DriveRoot "$TargetDrive\"
    Install-DockerDesktop -InstallerPath "F:\installers\Docker Desktop Installer.exe" -DriveRoot "$TargetDrive\"
}
