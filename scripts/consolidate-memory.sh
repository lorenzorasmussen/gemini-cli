#!/bin/bash

# This script consolidates the agent's memory from various .jsonl files
# into a single memory_bank.json file.

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_DIR="${SCRIPT_DIR}/../memory"
MEMORY_BANK_FILE="${MEMORY_DIR}/memory_bank.json"

# --- Main Logic ---
main() {
    if [ ! -d "$MEMORY_DIR" ]; then
        echo "Memory directory not found!"
        exit 1
    fi

    echo "Consolidating memory..."

    # Use jq to read all .jsonl files and combine them into a single JSON array.
    # The -s flag reads all input into a single array.
    jq -s . "${MEMORY_DIR}"/*.jsonl > "$MEMORY_BANK_FILE"

    echo "Memory consolidation complete. See ${MEMORY_BANK_FILE}"
}

main "$@"