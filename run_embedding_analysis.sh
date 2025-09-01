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

# --- Helper function to get Ollama model blob path (extracted from .zshrc) ---
ollama_blob() {
  local model_name="$1"
  local manifest_path="$HOME/.ollama/models/manifests/registry.ollama.ai/library/$model_name/latest"
  
  if [ ! -f "$manifest_path" ]; then
    echo "Error: Ollama manifest for $model_name not found at $manifest_path. Please ensure the model is pulled." >&2
    return 1
  fi

  # Put jq command on a single line to avoid syntax issues
  jq -r '.layers[]|select(.mediaType=="application/vnd.ollama.image.model").digest'
      "$manifest_path"
    | sed 's/:/-/' | xargs -I{} echo "$HOME/.ollama/models/blobs/{}"
}

# --- Source start_llamacpp.sh ---
source "/Users/lorenzorasmussen/.gemini/scripts/start_llamacpp.sh"

# --- Step 1: Ensure nomic-embed-text model is pulled in Ollama (and cache blob path) ---
OLLAMA_BLOB_CACHE="$HOME/.gemini/nomic_embed_blob_cache.txt"

echo "Ensuring nomic-embed-text model is pulled in Ollama..."

NOMIC_EMBED_BLOB=""
if [ -f "$OLLAMA_BLOB_CACHE" ]; then
    NOMIC_EMBED_BLOB=$(cat "$OLLAMA_BLOB_CACHE")
    echo "Using cached nomic-embed-text model path: $NOMIC_EMBED_BLOB"
else
    # Only pull if cache does not exist
    ollama pull nomic-embed-text
    NOMIC_EMBED_BLOB=$(ollama_blob nomic-embed-text)
    if [ $? -ne 0 ] || [ -z "$NOMIC_EMBED_BLOB" ]; then
        echo "Error: Could not get nomic-embed-text model blob. Ensure Ollama is running and the model is pulled."
        exit 1
    fi
    echo "Nomic-embed-text model file path: $NOMIC_EMBED_BLOB"
    echo "$NOMIC_EMBED_BLOB" > "$OLLAMA_BLOB_CACHE"
    echo "Nomic-embed-text model path cached to: $OLLAMA_BLOB_CACHE"
fi

# --- Step 2: Install llama.cpp if not present ---
install_llama_cpp

# --- Step 3: Start the llama.cpp server with the nomic-embed-text model ---
echo "Starting llama.cpp server with nomic-embed-text model..."
start_llamacpp "$NOMIC_EMBED_BLOB"

# Give the server a moment to start
sleep 5

# --- Step 4: Get the entire conversation history ---
echo "Extracting conversation history..."
# In a real scenario, you would replace this with the actual conversation history.
# For this example, we'll use a placeholder.
CONVERSATION_HISTORY="""
(This is a placeholder for the actual conversation history. You would paste the full thread content here.)
"""

# --- Step 5: Send the conversation history to llama.cpp for embedding and save the output ---

EMBEDDINGS_CACHE_FILE="/Users/lorenzorasmussen/.gemini/thread_embeddings_cache.json"
OUTPUT_FILE="/Users/lorenzorasmussen/.gemini/thread_embeddings.json"

# Check for existing cache and resume if possible
if [ -f "$EMBEDDINGS_CACHE_FILE" ]; then
    echo "Resuming embedding analysis from cache: $EMBEDDINGS_CACHE_FILE"
    # Read existing embeddings to determine where to resume
    EXISTING_EMBEDDINGS=$(cat "$EMBEDDINGS_CACHE_FILE")
    # In a real scenario, you'd use this to skip already processed chunks.
else
    echo "Starting new embedding analysis. Cache will be saved to: $EMBEDDINGS_CACHE_FILE"
    echo "[]" > "$EMBEDDINGS_CACHE_FILE" # Initialize empty JSON array
    EXISTING_EMBEDDINGS="[]"
fi

# Process conversation history in chunks and add metadata
# For simplicity, we'll split by line and embed each line as a chunk.
# For very long lines, you might need more sophisticated chunking.

# Use a temporary file to store the conversation history for line processing
TEMP_HISTORY_FILE=$(mktemp)
echo "$CONVERSATION_HISTORY" > "$TEMP_HISTORY_FILE"

CURRENT_LINE=0
TOTAL_LINES=$(wc -l < "$TEMP_HISTORY_FILE")
SOURCE_THREAD_ID="$(basename "$PWD")-$(date +%s)" # Unique ID for this thread/run

while IFS= read -r line; do
    CURRENT_LINE=$((CURRENT_LINE + 1))
    if [ -z "$line" ]; then # Skip empty lines
        continue
    fi

    # Create a unique ID for this chunk
    CHUNK_ID="$(uuidgen)"
    TIMESTAMP=$(date -Iseconds)

    # Send the line for embedding
    EMBEDDING_RESULT=$(curl -s http://localhost:8083/v1/embeddings \
      -d "{\"input\":\"$(echo -n "$line" | sed 's/"/\\"/g')\"}")

    if [ $? -eq 0 ]; then
        # Extract the embedding vector from the result
        EMBEDDING_VECTOR=$(echo "$EMBEDDING_RESULT" | jq -c '.embedding')

        # Construct the JSON object for this chunk
        CHUNK_JSON=$(jq -n \
            --arg id "$CHUNK_ID" \
            --arg ts "$TIMESTAMP" \
            --arg thread_id "$SOURCE_THREAD_ID" \
            --arg text "$line" \
            --argjson start_line "$CURRENT_LINE" \
            --argjson end_line "$CURRENT_LINE" \
            --argjson embedding "$EMBEDDING_VECTOR" \
            '{id: $id, timestamp: $ts, source_thread_id: $thread_id, chunk_text: $text, chunk_start_line: $start_line, chunk_end_line: $end_line, embedding: $embedding}')

        # Append new embedding to the cache file
        jq ". += [ $CHUNK_JSON ]" "$EMBEDDINGS_CACHE_FILE" > "$EMBEDDINGS_CACHE_FILE.tmp" && mv "$EMBEDDINGS_CACHE_FILE.tmp" "$EMBEDDINGS_CACHE_FILE"

        echo "Processed line $CURRENT_LINE/$TOTAL_LINES. Embeddings saved to cache."
    else
        echo "Error processing line $CURRENT_LINE/$TOTAL_LINES: Failed to get embeddings from llama.cpp. Check if the server is running and accessible."
        # In a real scenario, you might want to implement retry logic or error logging.
    fi

done < "$TEMP_HISTORY_FILE"

# Clean up temporary history file
rm "$TEMP_HISTORY_FILE"

# Copy the cached embeddings to the final output file
cp "$EMBEDDINGS_CACHE_FILE" "$OUTPUT_FILE"

echo "Final embeddings saved to: $OUTPUT_FILE"
