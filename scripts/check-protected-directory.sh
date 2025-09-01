#!/bin/bash

# This script checks if a command is trying to operate in a protected directory.

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="${SCRIPT_DIR}/../settings.json"
LOG_FILE="${SCRIPT_DIR}/../logs/security-violations.log"

# --- Logging ---
log_violation() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") - Protected directory access attempt: $1" >> "$LOG_FILE"
}

# --- Main Logic ---
main() {
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo "settings.json not found!"
        exit 1
    fi

    # Use jq to parse the settings.json file and get the protected paths.
    # The -r flag outputs raw strings.
    protected_paths=$(jq -r '.security.protected_paths_list[]' "$SETTINGS_FILE")

    # The command to be checked is passed as arguments to the script.
    command_to_check=("$@")

    for arg in "${command_to_check[@]}"; do
        # Check if the argument is a path. This is a simplified check.
        # It looks for arguments that start with / or contain /../
        if [[ "$arg" == /* ]] || [[ "$arg" == */../* ]]; then
            for protected_path in $protected_paths; do
                # Check if the argument path starts with a protected path.
                if [[ "$arg" == "$protected_path"* ]]; then
                    log_violation "Command '${command_to_check[*]}' attempts to access protected path '$arg'"
                    echo "Error: Attempt to access a protected directory: $arg"
                    exit 1
                fi
            done
        fi
    done
}

main "$@"