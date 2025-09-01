# --- Helper function to get Ollama model blob path (extracted from .zshrc) ---
ollama_blob() {
  local model_name="$1"
  local manifest_path="$HOME/.ollama/models/manifests/registry.ollama.ai/library/$model_name/latest"
  
  if [ ! -f "$manifest_path" ]; then
    echo "Error: Ollama manifest for $model_name not found at $manifest_path. Please ensure the model is pulled." >&2
    return 1
  fi

  # Put jq command on a single line to avoid syntax issues
  jq -r '.layers[]|select(.mediaType=="application/vnd.ollama.image.model").digest' \
      "$manifest_path" \
    | sed 's/:/-/' | xargs -I{} echo "$HOME/.ollama/models/blobs/{}"
}
