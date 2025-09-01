#!/bin/bash

# start-resource-monitor.sh - Periodically monitors system resources when run.

MONITOR_INTERVAL_SECONDS=$((10 * 60)) # 10 minutes

echo "Starting periodic resource monitoring (every 10 minutes). To stop, find and kill this process."

while true; do
    echo "--- Running resource monitor (Timestamp: $(date)) ---"
    # Invoke the Gemini CLI command
    gemini -p "/system:monitor-resources"
    echo "--- Resource monitor complete. Waiting for next interval. ---"
    sleep "$MONITOR_INTERVAL_SECONDS"
done
