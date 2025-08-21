# Refact + Gemini CLI Tooling Setup

This project is configured to expose the Gemini CLI as a Refact tool and to use project-scoped variables. This allows AI assistants to run `gemini` commands safely from the workspace without modifying your global config.

## Files

- `.refact/variables.yaml`
  - `GEMINI_SANDBOX: false`
  - `GOOGLE_APPLICATION_CREDENTIALS: $GOOGLE_APPLICATION_CREDENTIALS`
- `.refact/.gitignore`
  - Ignores `.refact/secrets.yaml` from git
- `~/.config/refact/integrations.d/cmdline_mcp_hub.yaml`
  - Integration to run `gemini` commands via Refact

## Local secrets (not committed)

- `.refact/secrets.yaml` (create locally; ignored by git)

Example (choose one `GOOGLE_APPLICATION_CREDENTIALS` path):

```yaml
# Option A: gcloud default ADC
GOOGLE_APPLICATION_CREDENTIALS: /Users/lorenzorasmussen/.config/gcloud/application_default_credentials.json

# Option B: project-local service account key
# GOOGLE_APPLICATION_CREDENTIALS: /Users/lorenzorasmussen/gemini-cli/.gcp/service-account.json

# Optional additional context
GOOGLE_CLOUD_PROJECT: your-project-id-here
GOOGLE_CLOUD_REGION: us-central1
GOOGLE_CLOUD_ZONE: us-central1-a
```

## How it works

- Refact tool `cmdline_mcp_hub` runs `gemini` from the project root (`/Users/lorenzorasmussen/gemini-cli`).
- Default sandbox is none (`GEMINI_SANDBOX=false`). You can override per-call.
- Credentials: The tool reads `GOOGLE_APPLICATION_CREDENTIALS` via project-level variables, which can resolve from `.refact/secrets.yaml` or your user environment.

## Usage examples

- Terminal
  - `gemini projects list`
- Refact tool
  - `cmd: "projects list"`
  - `verbose: "--verbose"`
  - `env: "GOOGLE_CLOUD_PROJECT=your-project-id-here"`
- Sandbox override
  - `env: "GEMINI_SANDBOX=docker"`

## Setup steps

1. Authenticate for ADC (recommended):
   - `gcloud auth application-default login`
   - Verify file exists: `/Users/lorenzorasmussen/.config/gcloud/application_default_credentials.json`
2. Or use a service account:
   - Place JSON at: `/Users/lorenzorasmussen/gemini-cli/.gcp/service-account.json`
   - Ensure roles and permissions are sufficient.
3. Create local secrets:
   - `.refact/secrets.yaml` with your chosen `GOOGLE_APPLICATION_CREDENTIALS` path and optional variables.
4. Optional: Set default project variables:
   - `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_REGION`, `GOOGLE_CLOUD_ZONE` in `.refact/secrets.yaml`

## Troubleshooting

- Auth error: Check `GOOGLE_APPLICATION_CREDENTIALS` path and file permissions.
- Missing `gemini` command: Ensure project is built and bin is available (`npm run build` or `npm run bundle`).
- Sandbox issues: Start with `GEMINI_SANDBOX=false` (default) and switch to docker/podman only if required.
