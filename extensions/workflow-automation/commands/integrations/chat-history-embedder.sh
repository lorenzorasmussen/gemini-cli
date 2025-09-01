#!/bin/bash

# chat-history-embedder.sh - Periodically embeds chat history data.

EMBEDDING_INTERVAL_SECONDS=$((30 * 60)) # 30 minutes
OUTPUT_DIR="$HOME/.gemini/chat_embeddings"
OUTPUT_FILE="$OUTPUT_DIR/chat_embeddings.jsonl"

# --- Ensure output directory exists ---
mkdir -p "$OUTPUT_DIR"

# --- Function to get chat history (placeholder) ---
get_chat_history() {
    # In a real scenario, this would involve reading chat logs, database, etc.
    # For demonstration, let's use a dummy string.
    echo "This is a dummy chat history entry at $(date)."
    # Example: cat ~/.zsh_history # (Not recommended for actual chat history)
}

# --- Main Embedding Loop ---
embed_chat_history() {
    echo "Starting chat history embedder..."

    while true; do
        echo "Embedding chat history... (Timestamp: $(date))"
        
        CHAT_HISTORY=$(get_chat_history)

        if [ -z "$CHAT_HISTORY" ]; then
            echo "No new chat history to embed. Skipping this interval."
        else
            # Send the chat history to llama.cpp for embedding
            EMBEDDING_RESULT=$(curl -s http://localhost:8083/v1/embeddings \
              -d "{\"input\":\"$(echo -n \"$CHAT_HISTORY\" | sed 's/\"/\\\"/g')\"}")

            if [ $? -eq 0 ]; then
                # Append new embeddings to the JSONL file
                echo "$EMBEDDING_RESULT" >> "$OUTPUT_FILE"
                echo "Chat history embedded and saved to: $OUTPUT_FILE"
            else
                echo "Error: Failed to get embeddings from llama.cpp. Check if the server is running and accessible."
            fi
        fi
        
        echo "Waiting for next interval..."
        sleep "$EMBEDDING_INTERVAL_SECONDS"
    done
}

# Run the embedder in the background
embed_chat_history &
