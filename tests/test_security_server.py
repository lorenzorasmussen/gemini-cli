import asyncio
import json
import os
import subprocess
from pathlib import Path

async def run_test():
    print("Starting run_test function...")
    # Path to the security server script
    script_path = Path(__file__).resolve().parent.parent / "scripts" / "lorenzo-security-server.py"
    print(f"Script path: {script_path}")
    
    # Start the server as a subprocess
    process = await asyncio.create_subprocess_exec(
        "python3", str(script_path),
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    print("Subprocess started.")

    # Construct the list_tools request
    request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "list_tools",
        "params": {}
    }
    
    print(f"Sending request: {json.dumps(request)}")
    # Send the request to the server
    process.stdin.write(json.dumps(request).encode() + b'\n')
    await process.stdin.drain()
    print("Request sent.")

    # Add a small delay to allow the server to respond
    await asyncio.sleep(0.5) # Increased sleep time
    print("After sleep.")

    # Read the response from the server
    response_data = await process.stdout.readline()
    print(f"Received response: {response_data.decode().strip()}")

    # Read stderr output
    stderr_data = await process.stderr.read()
    if stderr_data:
        print(f"Received stderr: {stderr_data.decode().strip()}")
    
    # Close the server
    process.stdin.close()
    await process.wait()
    print("Subprocess closed.")

    # Check if the response is valid
    if not response_data:
        print("Test failed: No response data.")
        return False
    try:
        response = json.loads(response_data)
        print(f"Parsed response: {response}")
        if "result" not in response:
            print("Test failed: 'result' not in response.")
            return False
        if not isinstance(response["result"], list):
            print("Test failed: 'result' is not a list.")
            return False
        if not len(response["result"]) > 0:
            print("Test failed: 'result' list is empty.")
            return False
    except json.JSONDecodeError:
        print("Test failed: Invalid JSON response.")
        return False

    print("Test passed!")
    return True

if __name__ == "__main__":
    asyncio.run(run_test())
