#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"

# Verify repository structure
if [[ ! -f "$DOTFILES/bash/bashrc" ]]; then
    echo "Dotfiles repository not found at $DOTFILES"
    exit 1
fi

# Install Starship if missing
if ! command -v starship >/dev/null 2>&1; then
    echo "Installing Starship..."
    curl -fsSL https://starship.rs/install.sh -o /tmp/starship-install.sh
    sh /tmp/starship-install.sh
fi

# Back up existing Bash configuration
if [[ -f "$HOME/.bashrc" ]]; then
    cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi

# Add shared configuration only once
if ! grep -Fq '# BEGIN DOTFILES' "$HOME/.bashrc" 2>/dev/null; then
    cat >> "$HOME/.bashrc" <<'EOF'

# BEGIN DOTFILES
if [ -f "$HOME/dotfiles/bash/bashrc" ]; then
    source "$HOME/dotfiles/bash/bashrc"
fi
# END DOTFILES
EOF
fi

echo "Bash configuration installed."