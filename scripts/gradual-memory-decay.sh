#!/bin/bash

# This script implements gradual memory decay by removing a percentage of the
# oldest memories from the memory bank.

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_FILE="${SCRIPT_DIR}/../settings.json"
MEMORY_BANK_FILE="${SCRIPT_DIR}/../memory/memory_bank.json"

# --- Main Logic ---
main() {
    if [ ! -f "$MEMORY_BANK_FILE" ]; then
        echo "Memory bank not found!"
        exit 1
    fi

    if [ ! -f "$SETTINGS_FILE" ]; then
        echo "settings.json not found!"
        exit 1
    fi

    # Get the rotation percentage from settings.json
    rotation_percentage=$(jq -r '.memory.rotation_percentage' "$SETTINGS_FILE")

    # Get the total number of memories
    total_memories=$(jq 'length' "$MEMORY_BANK_FILE")

    # Calculate the number of memories to remove
    # bc is used for floating point arithmetic
    num_to_remove=$(echo "$total_memories * $rotation_percentage" | bc | cut -d '.' -f 1)

    if [ "$num_to_remove" -eq 0 ]; then
        echo "No memories to decay."
        exit 0
    fi

    echo "Decaying $num_to_remove memories..."

    # Use jq to remove the oldest memories.
    # This assumes the memories are sorted by timestamp in ascending order.
    # We are removing the first `num_to_remove` memories.
    jq "del(.[0:${num_to_remove}])" "$MEMORY_BANK_FILE" > "${MEMORY_BANK_FILE}.tmp" && mv "${MEMORY_BANK_FILE}.tmp" "$MEMORY_BANK_FILE"

    echo "Memory decay complete."
}

main "$@"