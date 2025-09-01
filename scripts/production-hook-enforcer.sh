#!/bin/bash

# This script is the primary hook for pre-execution validation.
# It performs security checks and monitors performance.

set -euo pipefail

# --- Configuration ---
# Get the script's directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/../logs/execution.log"

# --- Logging ---
# Function to log messages to the execution log.
log_message() {
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ") - $1" >> "$LOG_FILE"
}

# --- Security Checks ---
# Function to run all security checks.
run_security_checks() {
    log_message "Running security checks..."

    # Call the other security scripts.
    # The command to be executed is passed as arguments to this function.
    "$SCRIPT_DIR/check-protected-directory.sh" "$@"
    "$SCRIPT_DIR/validate-bash-command.sh" "$@"
    # eslint-security-enforcer.sh is more for javascript/typescript projects,
    # but we can call it here as a placeholder.
    # It should be smart enough to only run on relevant files.
    "$SCRIPT_DIR/eslint-security-enforcer.sh" "$@"

    log_message "Security checks passed."
}

# --- Performance Monitoring ---
# Function to monitor and log performance.
monitor_performance() {
    local command_to_run=("$@")
    log_message "Starting performance monitoring for: ${command_to_run[*]}"

    # Using /usr/bin/time to get detailed performance metrics.
    # The output is appended to the log file.
    # The -p flag provides POSIX-standard output.
    /usr/bin/time -p "${command_to_run[@]}" 2>> "$LOG_FILE"

    log_message "Performance monitoring finished."
}

# --- Main Execution ---
main() {
    if [ "$#" -eq 0 ]; then
        echo "Usage: $0 <command_to_execute>"
        exit 1
    fi

    log_message "--- New Execution ---"
    log_message "Command: $*"

    # Run security checks before executing the command.
    run_security_checks "$@"

    # Execute the command with performance monitoring.
    monitor_performance "$@"

    log_message "--- Execution Finished ---"
}

main "$@"