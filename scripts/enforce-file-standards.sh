#!/bin/bash

# This script enforces file standards by running linters on files.

set -euo pipefail

# --- Main Logic ---
main() {
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <file_to_check>"
        exit 1
    fi

    file_to_check="$1"

    if [ ! -f "$file_to_check" ]; then
        echo "File not found: $file_to_check"
        exit 1
    fi

    echo "Enforcing file standards for: $file_to_check"

    case "$file_to_check" in
        *.py)
            if command -v flake8 &> /dev/null; then
                echo "Running flake8..."
                flake8 "$file_to_check"
            else
                echo "flake8 not found. Skipping Python style check."
            fi
            ;;
        *.sh)
            if command -v shellcheck &> /dev/null; then
                echo "Running shellcheck..."
                shellcheck "$file_to_check"
            else
                echo "shellcheck not found. Skipping shell script style check."
            fi
            ;;
        *)
            echo "Unsupported file type: $file_to_check"
            ;;
    esac

    echo "File standards check complete."
}

main "$@"