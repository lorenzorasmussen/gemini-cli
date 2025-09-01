#!/bin/bash

# --- Intelligent Dependency Installation for llama.cpp ---
install_llama_cpp() {
    if ! command -v llama-server &> /dev/null
    then
        echo "llama-server not found. Attempting to install via Nix..."
        if command -v nix &> /dev/null
        then
            nix profile add nixpkgs#llama-cpp
            if [ $? -ne 0 ]; then
                echo "Error: Nix installation of llama-cpp failed. Please install it manually: nix profile add nixpkgs#llama-cpp"
                exit 1
            fi
            echo "llama-cpp installed successfully."
        else
            echo "Error: Nix not found. Please install Nix and llama-cpp manually."
            exit 1
        fi
    fi
}

# --- Step 1: Ensure nomic-embed-text model is pulled in Ollama ---
echo "Ensuring nomic-embed-text model is pulled in Ollama..."
ollama pull nomic-embed-text

# --- Step 2: Get the nomic-embed-text model file path (blob) from Ollama ---
echo "Getting nomic-embed-text model file path..."
# This assumes you are in a zsh shell where ollama_blob is defined.
# If not, you might need to source your ~/.zshrc first.
NOMIC_EMBED_BLOB=$(ollama_blob nomic-embed-text)
if [ -z "$NOMIC_EMBED_BLOB" ]; then
    echo "Error: Could not get nomic-embed-text model blob. Ensure Ollama is running and the model is pulled."
    exit 1
fi
echo "Nomic-embed-text model file path: $NOMIC_EMBED_BLOB"

# --- Step 3: Install llama.cpp if not present ---
install_llama_cpp

# --- Step 4: Start the llama.cpp server with the nomic-embed-text model ---
echo "Starting llama.cpp server with nomic-embed-text model..."
# This assumes you are in a zsh shell where start_llamacpp is defined.
# If not, you might need to source your ~/.zshrc first.
start_llamacpp "$NOMIC_EMBED_BLOB"

# Give the server a moment to start
sleep 5

# --- Step 5: Get the entire conversation history ---
echo "Extracting conversation history..."
# In a real scenario, you would replace this with the actual conversation history.
# For this example, we'll use a placeholder.
CONVERSATION_HISTORY="""
(This is a placeholder for the actual conversation history. You would paste the full thread content here.)
"""

# --- Step 6: Send the conversation history to llama.cpp for embedding and save the output ---
echo "Sending conversation history to llama.cpp for embedding..."
OUTPUT_FILE="/Users/lorenzorasmussen/.gemini/thread_embeddings.json"

curl -s http://localhost:8083/v1/embeddings \
  -d "{\"input\":\"$(echo -n "$CONVERSATION_HISTORY" | sed 's/"/\\"/g')\"}" > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "Embeddings saved to: $OUTPUT_FILE"
else
    echo "Error: Failed to get embeddings from llama.cpp. Check if the server is running and accessible."
fi