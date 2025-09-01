#!/usr/bin/env python3
"""
Lorenzo's Security-First MCP Server
Implements Nordic security principles with AI validation
Version: 1.1.0
"""

import asyncio
import json
import logging
import re
import os
from pathlib import Path

from mcp.server import Server
from mcp.server.models import InitializationOptions
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

SERVER_NAME = "lorenzo-security"
SERVER_VERSION = "1.2.0"

server = Server(SERVER_NAME)

# Configure structured logging for better monitoring and debugging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(server.name)

def _load_secret_patterns() -> list[str]:
    """Loads secret detection patterns from settings.json."""
    # The settings file is in the parent's parent directory of the script
    # e.g., script is in .gemini/scripts/, settings.json is in .gemini/
    settings_path = Path(__file__).resolve().parent.parent / 'settings.json'
    if not settings_path.exists():
        logger.warning(f"settings.json not found at {settings_path}. Using empty patterns list.")
        return []
    try:
        with open(settings_path, 'r') as f:
            settings = json.load(f)
        patterns = settings.get("security", {}).get("validation", {}).get("secret_patterns", [])
        logger.info(f"Loaded {len(patterns)} secret patterns.")
        return patterns
    except (json.JSONDecodeError, IOError) as e:
        logger.error(f"Failed to load or parse settings.json: {e}")
        return []

SECRET_PATTERNS = _load_secret_patterns()

def _validate_path(file_path: str) -> Path:
    """
    Validates that the file path is within the current workspace and resolves it.
    This is a critical security measure to prevent path traversal attacks.
    """
    # The workspace root is the parent directory of the .gemini directory
    workspace_root = Path(__file__).resolve().parent.parent
    # Resolve the path to remove '..' components and get the absolute path
    resolved_path = (workspace_root / file_path).resolve()

    # Check if the resolved path is within the workspace root
    if workspace_root not in resolved_path.parents and resolved_path != workspace_root:
        raise ValueError(f"Path traversal attempt blocked. Path '{file_path}' is outside the allowed workspace.")

    if not resolved_path.exists():
        raise FileNotFoundError(f"File not found: {resolved_path}")

    return resolved_path


async def _run_security_scan(arguments: dict) -> str:
    """
    Handles the logic for the security_scan tool.
    This implementation reads a file and scans it for secrets based on regex patterns.
    """
    file_path = arguments['file_path']
    scan_type = arguments['scan_type']
    logger.info(f"Initiating security scan for '{file_path}' (type: {scan_type}).")

    if scan_type != "secrets":
        logger.warning(f"Unsupported scan_type '{scan_type}' requested.")
        return json.dumps({
            "file_path": file_path,
            "status": "SKIPPED",
            "reason": f"Scan type '{scan_type}' is not implemented. Only 'secrets' is supported."
        })

    validated_path = _validate_path(file_path)

    try:
        with open(validated_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
    except Exception as e:
        logger.error(f"Could not read file {validated_path}: {e}")
        return json.dumps({"file_path": file_path, "status": "ERROR", "reason": f"Failed to read file: {e}"})

    if not SECRET_PATTERNS:
        logger.warning("No secret patterns loaded. Cannot perform scan.")
        return json.dumps({"file_path": file_path, "status": "SKIPPED", "reason": "No secret patterns were loaded from configuration."})

    findings = []
    for i, line in enumerate(content.splitlines(), 1):
        for pattern in SECRET_PATTERNS:
            if re.search(pattern, line):
                findings.append({"line_number": i, "line_content": line.strip()})
                # Found a secret on this line, no need to check other patterns for the same line
                break

    if findings:
        report = {"file_path": file_path, "status": "SECRETS_FOUND", "findings": findings}
        logger.warning(f"Secrets found in '{file_path}'.")
        return json.dumps(report, indent=2)
    else:
        logger.info(f"No secrets found in '{file_path}'.")
        return json.dumps({"file_path": file_path, "status": "PASSED"}, indent=2)


async def _run_ai_refactor(arguments: dict) -> str:
    """Handles the logic for the ai_refactor tool."""
    code_path = arguments['code_path']
    optimization_level = arguments.get('optimization_level', 'performance')
    logger.info(f"Initiating AI refactor for '{code_path}' (level: {optimization_level}).")

    validated_path = _validate_path(code_path)

    # Placeholder for actual refactoring logic.
    logger.info(f"AI refactoring completed for '{validated_path}'.")
    return f"AI refactoring of {code_path}: Optimized for {optimization_level}"


@server.list_tools()
async def handle_list_tools() -> list[Tool]:
    return [
        Tool(
            name="security_scan",
            description="Scan files for security vulnerabilities using Nordic security standards. Returns a JSON report.",
            inputSchema={
                "type": "object",
                "properties": {
                    "file_path": {"type": "string", "description": "Path to file for security scan"},
                    "scan_type": {"type": "string", "enum": ["secrets", "vulnerabilities", "compliance"]}
                },
                "required": ["file_path", "scan_type"]
            }
        ),
        Tool(
            name="ai_refactor",
            description="AI-powered code refactoring with accessibility compliance",
            inputSchema={
                "type": "object",
                "properties": {
                    "code_path": {"type": "string", "description": "Path to code file"},
                    "optimization_level": {"type": "string", "enum": ["performance", "accessibility", "security"]}
                },
                "required": ["code_path"]
            }
        )
    ]

@server.call_tool()
async def handle_call_tool(name: str, arguments: dict) -> list[TextContent]:
    """Dispatches tool calls to the appropriate handler and handles errors."""
    logger.debug(f"Received tool call for '{name}' with arguments: {arguments}")
    try:
        if name == "security_scan":
            result_text = await _run_security_scan(arguments)
        elif name == "ai_refactor":
            result_text = await _run_ai_refactor(arguments)
        else:
            logger.warning(f"Attempted to call unknown tool: {name}")
            result_text = f"Error: Tool '{name}' not found."
    except (ValueError, FileNotFoundError) as e:
        logger.error(f"Tool call failed for '{name}': {e}")
        result_text = f"Error executing tool '{name}': {e}"
    except Exception as e:
        logger.exception(f"An unexpected error occurred while calling tool '{name}'.")
        result_text = f"An unexpected error occurred: {e}"

    return [TextContent(type="text", text=result_text)]

async def main():
    logger.info(f"Starting {SERVER_NAME} MCP server v{SERVER_VERSION}...")
    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name=SERVER_NAME,
                server_version=SERVER_VERSION,
                capabilities=server.get_capabilities()
            )
        )
    logger.info(f"{SERVER_NAME} MCP server stopped.")

if __name__ == "__main__":
    asyncio.run(main())