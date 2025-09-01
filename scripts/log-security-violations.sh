#!/bin/bash

# This script logs a security violation message to the security-violations.log file.

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/../logs/security-violations.log"

# --- Main Logic ---
main() {
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <message>"
        exit 1
    fi

    log_message="$1"
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") - $log_message" >> "$LOG_FILE"
}

main "$@"