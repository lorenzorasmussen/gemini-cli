# Function to start llama-server with a model managed by Ollama
start_ollama_model() {
  MODEL_NAME=$1
  if [ -z "$MODEL_NAME" ]; then
    echo "Usage: start_ollama_model <model_name>"
    return 1
  fi
  
  pkill llama-server
  sleep 1
  
  MANIFEST_PATH=~/.ollama/models/manifests/registry.ollama.ai/library/$MODEL_NAME/latest
  if [ ! -f "$MANIFEST_PATH" ]; then
    echo "Error: Manifest for model '$MODEL_NAME' not found."
    return 1
  fi
  
  MODEL_DIGEST=$(cat $MANIFEST_PATH | jq -r '.layers[] | select(.mediaType=="application/vnd.ollama.image.model") | .digest')
  MODEL_FILENAME=$(echo $MODEL_DIGEST | sed 's/:/-/')
  MODEL_PATH=~/.ollama/models/blobs/$MODEL_FILENAME
  
  echo "Starting server for $MODEL_NAME..."
  # Customize your flags here (e.g., --port)
  llama-server -m $MODEL_PATH -c 2048 -t 4 --port 8080 &
}

# Create simple aliases
alias phi3-server="start_ollama_model phi3"
alias moondream-server="start_ollama_model moondream"
