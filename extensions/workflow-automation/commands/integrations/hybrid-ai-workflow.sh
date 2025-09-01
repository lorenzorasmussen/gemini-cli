#!/bin/bash
# hybrid-ai-workflow.sh - Multi-AI workflow coordination

echo "🔄 Starting hybrid AI workflow..."

# --- Check and Install claude-code if not available ---
if ! command -v claude-code &> /dev/null
then
    echo "claude-code not found. Attempting to install via npm..."
    if command -v npm &> /dev/null
    then
        npm install -g claude-code
        if [ $? -ne 0 ]; then
            echo "Error: npm installation of claude-code failed. Please install it manually."
            exit 1
        fi
        echo "claude-code installed successfully."
    else
        echo "Error: npm not found. Please install npm and claude-code manually."
        exit 1
    fi
fi

# Step 1: Claude Code analysis (reasoning)
echo "📊 Claude Code: Architectural analysis..."
claude_analysis=$(claude-code analyze "$PROJECT_DIR" --output=json)

# Step 2: Extract actionable items
actionable_items=$(echo "$claude_analysis" | jq -r '.action_items[]')

# Step 3: Gemini CLI implementation (context + execution)
echo "🚀 Gemini CLI: Implementation phase..."
for item in $actionable_items; do
    gemini -p "Context from Claude analysis: $claude_analysis. Implement: $item"
done

# Step 4: Validation cycle
echo "✅ Validation: Running test suite..."
gemini -p "/test:comprehensive $(pwd)"

echo "🎯 Hybrid workflow complete"