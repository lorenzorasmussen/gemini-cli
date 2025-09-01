#!/bin/bash

# Self-healing wrapper script for workflow-state-server.js

SERVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_JS="$SERVER_DIR/workflow-state-server.js"

# --- Nix and Flake Setup Check ---
check_nix_and_flakes() {
    echo "Checking Nix installation and flake support..."

    # Check for Nix installation
    if ! command -v nix &> /dev/null; then
        echo "❌ Nix is not installed. Please install Nix to proceed."
        echo "   Recommended installation for macOS: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo "   Recommended installation for Linux: curl -L https://nixos.org/nix/install | sh"
        exit 1
    fi
    echo "✅ Nix is installed."

    # Check for flake support
    if ! nix --extra-experimental-features 'nix-command flakes' eval --raw --expr 'true' &> /dev/null; then
        echo "❌ Nix flakes are not enabled. Please enable them to proceed."
        echo "   Add the following line to /etc/nix/nix.conf or ~/.config/nix/nix.conf:"
        echo "   experimental-features = nix-command flakes"
        echo "   Then restart your shell."
        exit 1
    fi
    echo "✅ Nix flakes are enabled."
}

# --- Main Logic ---

# 1. Perform Nix and Flake setup check
check_nix_and_flakes

# 2. Start the server if not already running
if pgrep -f "node $SERVER_JS" > /dev/null; then
    echo "workflow-state-server.js is already running."
else
    echo "Starting workflow-state-server.js via Nix..."
    # Use nix run to execute the server within a Nix environment
    # The flake.nix will define the Node.js dependencies for this server.
    nix run .#workflow-state-server -- "$SERVER_JS" > "$SERVER_DIR/server.log" 2>&1 &
    PID=$!
    echo "workflow-state-server.js started with PID $PID."
fi
