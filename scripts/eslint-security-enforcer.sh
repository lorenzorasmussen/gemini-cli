#!/bin/bash

# This script enforces ESLint security rules on JavaScript/TypeScript files.

set -euo pipefail

# --- Configuration ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/../logs/security-violations.log"
ESLINT_CONFIG="${SCRIPT_DIR}/../.eslintrc.json"

# --- Logging ---
log_violation() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") - ESLint security violation: $1" >> "$LOG_FILE"
}

# --- Main Logic ---
main() {
    # Check if there are any .js or .ts files to lint.
    if ! find . -name "*.js" -o -name "*.ts" | read; then
        echo "No JavaScript or TypeScript files found. Skipping ESLint check."
        exit 0
    fi

    # Check for a local eslint installation first, then a global one.
    if [ -x "./node_modules/.bin/eslint" ]; then
        ESLINT_CMD="./node_modules/.bin/eslint"
    elif command -v eslint &> /dev/null; then
        ESLINT_CMD="eslint"
    else
        echo "ESLint is not installed. Skipping security check."
        exit 0
    fi

    echo "Running ESLint security check..."
    # We are assuming that the project has its own .eslintrc file.
    # If not, we can use the one in the .gemini directory.
    if [ ! -f ".eslintrc.json" ] && [ ! -f ".eslintrc.js" ]; then
        LINT_CONFIG_ARG="--config $ESLINT_CONFIG"
    else
        LINT_CONFIG_ARG=""
    fi

    # Run eslint and capture the output.
    # We are linting all .js and .ts files in the current directory.
    if ! $ESLINT_CMD . --ext .js,.ts $LINT_CONFIG_ARG --format json > eslint_report.json; then
        log_violation "ESLint found security issues. See eslint_report.json for details."
        echo "Error: ESLint found security issues. See eslint_report.json for details."
        exit 1
    fi

    echo "ESLint security check passed."
    rm eslint_report.json
}

main "$@"