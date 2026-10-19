
$ErrorActionPreference = "Stop"

# Determine repository directory
$dotfiles = $PSScriptRoot
$sharedProfile = Join-Path $dotfiles "powershell/profile.ps1"

if (-not (Test-Path $sharedProfile)) {
    throw "Shared PowerShell profile not found."
}

# Install required applications
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    winget install --id Starship.Starship --exact
    if ($LASTEXITCODE -ne 0) {
        throw "Starship installation failed."
    }
}

# Install Nerd Font through WinGet
winget install --id DEVCOM.JetBrainsMonoNerdFont --exact

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Font installation returned exit code $LASTEXITCODE."
}

# Create profile directory
New-Item -ItemType Directory -Force `
    -Path (Split-Path $PROFILE) | Out-Null

# Create portable bootstrap
$bootstrap = @'
# Load shared PowerShell configuration
$sharedProfile = Join-Path $HOME "dotfiles/powershell/profile.ps1"

if (Test-Path $sharedProfile) {
    . $sharedProfile
}
'@

# Update profile only when necessary
$currentProfile = if (Test-Path $PROFILE) {
    Get-Content $PROFILE -Raw
} else {
    ""
}

if ($currentProfile.Trim() -ne $bootstrap.Trim()) {
    if (Test-Path $PROFILE) {
        $backup = "$PROFILE.$(Get-Date -Format 'yyyyMMdd-HHmmss').bak"
        Copy-Item $PROFILE $backup
    }

    Set-Content -Path $PROFILE -Value $bootstrap -Encoding utf8
}

Write-Host "PowerShell dotfiles installed."
