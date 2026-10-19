
# --------------------------------------------------
# Environment
# --------------------------------------------------

# Use UTF-8 for console output
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# Git workspace
$githome = Join-Path $HOME "githome"


# --------------------------------------------------
# Custom functions
# --------------------------------------------------

function Remove-GoneBranches {
    git fetch --prune

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Git fetch failed. No branches were deleted."
        return
    }

    $goneBranches = git for-each-ref `
        --format='%(refname:short) %(upstream:track)' `
        refs/heads |
        Where-Object { $_ -match '\[gone\]$' } |
        ForEach-Object { ($_ -split ' ', 2)[0] }

    foreach ($branch in $goneBranches) {
        git branch -d -- $branch
    }
}

function Show-Tree {
    param(
        [string]$Path = ".",
        [string[]]$Exclude = @(),
        [string]$Prefix = ""
    )

    # Get directory contents
    $items = @(
        Get-ChildItem -LiteralPath $Path |
            Where-Object { $Exclude -notcontains $_.Name }
    )

    for ($i = 0; $i -lt $items.Count; $i++) {
        $item = $items[$i]
        $isLast = $i -eq ($items.Count - 1)

        # Draw tree branches
        $branch = if ($isLast) { "└──" } else { "├──" }
        Write-Host "$Prefix$branch $($item.Name)"

        # Recursively process directories
        if ($item.PSIsContainer) {
            $newPrefix = $Prefix + $(if ($isLast) { "    " } else { "│   " })

            Show-Tree `
                -Path $item.FullName `
                -Exclude $Exclude `
                -Prefix $newPrefix
        }
    }
}


# --------------------------------------------------
# Prompt
# --------------------------------------------------

# Load shared Starship configuration
$env:STARSHIP_CONFIG = Join-Path $HOME "dotfiles\starship\starship.toml"

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}