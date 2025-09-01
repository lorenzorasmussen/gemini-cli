#!/bin/bash
# workflow_chain.sh - Multi-step workflow with state passing

# --- Intelligent Dependency Installation ---
install_dependency() {
    local dep_name="$1"
    local install_cmd="$2"
    local check_cmd="$3"

    if ! command -v "$check_cmd" &> /dev/null
    then
        echo "$dep_name not found. Attempting to install..."
        if eval "$install_cmd"; then
            echo "$dep_name installed successfully."
        else
            echo "Error: Failed to install $dep_name. Please install it manually: $install_cmd"
            exit 1
        fi
    fi
}

# Install claude-code (assuming npm for now)
install_dependency "claude-code" "npm install -g claude-code" "claude-code"

# Install inotifywait (assuming brew for macOS)
if [[ "$(uname)" == "Darwin" ]]; then
    install_dependency "inotifywait" "brew install inotify-tools" "inotifywait"
else
    # For Linux, assuming apt-get for now
    install_dependency "inotifywait" "sudo apt-get update && sudo apt-get install -y inotify-tools" "inotifywait"
fi

# Install jq (assuming brew for macOS)
if [[ "$(uname)" == "Darwin" ]]; then
    install_dependency "jq" "brew install jq" "jq"
else
    # For Linux, assuming apt-get for now
    install_dependency "jq" "sudo apt-get update && sudo apt-get install -y jq" "jq"
fi

# --- Main Workflow ---
# Integration pattern from Reddit user "casce"
function workflow_chain() {
    # Parse Claude's analysis output
    claude_output=$(claude-code analyze "$PROJECT_DIR")
    
    # Extract file paths and pipe to Gemini CLI  
    echo "$claude_output" | \
    sed 's/@/\/absolute\/path\//g' | \
    gemini -p "Implement the changes suggested above" | \
    tee /tmp/gemini_response.txt
    
    # Auto-trigger on file changes
    inotifywait -m "$PROJECT_DIR" -e modify --format '%w%f' |
    while read file;
    do
        gemini -p "Analyze changes in $file and suggest optimizations"
    done
}

# Call the function to execute the workflow
workflow_chain