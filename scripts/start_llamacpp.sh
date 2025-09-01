start_llamacpp() {
  local model_path="$1"

  # Source ollama_blob_function.sh to make ollama_blob available
  source "/Users/lorenzorasmussen/.gemini/scripts/ollama_blob_function.sh"

  if ! command -v llama-server &>/dev/null; then
    echo "❌ 'llama-server' not found. Ensure 'nixpkgs#llama-cpp' is installed in your profile." >&2
    return 1
  fi
  if [[ ! -f "$model_path" ]]; then
    echo "❌ Model file not found at '$model_path'." >&2; return 1
  fi
  if pgrep -f "llama.cpp/server" >/dev/null; then
    echo "✅ Llama.cpp server is already running."
  else
    echo "🚀 Starting Llama.cpp server with model: $(basename $model_path)..."
    # Capture stderr to log file for debugging
    nohup llama-server -m "$model_path" --host 0.0.0.0 --port 8080 > "/Users/lorenzorasmussen/.gemini/llama_server.log" 2>&1 &
    PID=$!
    sleep 3 # Give it a moment to start or fail

    if ! kill -0 $PID 2>/dev/null; then
      echo "❌ Failed to start Llama.cpp server. Check log for errors: /Users/lorenzorasmussen/.gemini/llama_server.log"
      cat "/Users/lorenzorasmussen/.gemini/llama_server.log" >&2 # Print log content to stderr
      return 1
    fi
    echo "✅ Llama.cpp server started."
  fi
}
