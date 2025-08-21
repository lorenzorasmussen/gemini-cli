#!/usr/bin/env bash
set -euo pipefail

echo "== Refact + Gemini CLI environment check =="

missing=0

check_file() {
  local name="$1"
  local path="$2"
  if [[ -z "${path}" ]]; then
    echo "[-] $name is not set"
    missing=$((missing+1))
  elif [[ ! -f "$path" ]]; then
    echo "[-] $name path does not exist: $path"
    missing=$((missing+1))
  elif [[ ! -r "$path" ]]; then
    echo "[-] $name path is not readable: $path"
    missing=$((missing+1))
  else
    echo "[+] $name OK: $path"
  fi
}

check_var() {
  local name="$1"
  local val="${!name:-}"
  if [[ -z "$val" ]]; then
    echo "[-] $name is not set"
  else
    echo "[+] $name: $val"
  fi
}

# Credentials
GAC="${GOOGLE_APPLICATION_CREDENTIALS:-}"
check_file "GOOGLE_APPLICATION_CREDENTIALS" "$GAC"

# Optional project context
check_var "GOOGLE_CLOUD_PROJECT"
check_var "GOOGLE_CLOUD_REGION"
check_var "GOOGLE_CLOUD_ZONE"

echo
echo "== Checking Node.js and gemini CLI availability =="

if command -v node >/dev/null 2>&1; then
  NODE_V=$(node -v || true)
  echo "[+] node found: $NODE_V"
  MAJOR=$(node -p "process.versions.node.split('.')[0]")
  if [[ "$MAJOR" -lt 20 ]]; then
    echo "[-] Node.js major version < 20; please install Node.js >= 20"
    missing=$((missing+1))
  fi
else
  echo "[-] node not found in PATH"
  missing=$((missing+1))
fi

if command -v gemini >/dev/null 2>&1; then
  echo "[+] gemini CLI found in PATH"
else
  echo "[-] gemini CLI not found in PATH"
  echo "    Try: npm run build or npm run bundle (this repo provides bin)"
fi

echo
if [[ "$missing" -gt 0 ]]; then
  echo "Environment check completed with $missing issue(s)."
  exit 1
else
  echo "Environment check passed."
fi
