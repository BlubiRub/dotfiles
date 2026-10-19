# Install Starship if missing
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
    winget install --id Starship.Starship --exact
}

# Determine repository directory
$dotfiles = $PSScriptRoot
$sharedProfile = Join-Path $dotfiles "powershell\profile.ps1"

if (-not (Test-Path $sharedProfile)) {
    throw "Shared PowerShell profile not found."
}

# Create PowerShell profile directory
New-Item -ItemType Directory -Force `
    -Path (Split-Path $PROFILE) | Out-Null

# Back up existing profile
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.bak" -Force
}

# Create bootstrap profile
@'
$sharedProfile = Join-Path $HOME "dotfiles\powershell\profile.ps1"

if (Test-Path $sharedProfile) {
    . $sharedProfile
}
'@ | Set-Content -Path $PROFILE -Encoding utf8

Write-Host "PowerShell configuration installed."