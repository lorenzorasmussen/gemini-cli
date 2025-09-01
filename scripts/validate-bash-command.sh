#!/bin/bash

# This script checks if a command is in the list of blocked commands.

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="${SCRIPT_DIR}/../settings.json"
LOG_FILE="${SCRIPT_DIR}/../logs/security-violations.log"

# --- Logging ---
log_violation() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") - Blocked command attempt: $1" >> "$LOG_FILE"
}

# --- Main Logic ---
main() {
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo "settings.json not found!"
        exit 1
    fi

    # Use jq to parse the settings.json file and get the blocked commands.
    blocked_commands=$(jq -r '.security.rules.blocked_commands_list[]' "$SETTINGS_FILE")

    # The command to be checked is passed as arguments to the script.
    command_to_check="$*"

    for blocked_command in $blocked_commands; do
        # Check if the command to check starts with a blocked command.
        # This is a simple check and might not be perfect for all cases,
        # but it's a good starting point.
        if [[ "$command_to_check" == "$blocked_command"* ]]; then
            log_violation "Command '$command_to_check' is blocked."
            echo "Error: Attempt to execute a blocked command: $command_to_check"
            exit 1
        fi
    done
}

main "$@"