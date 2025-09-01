#!/usr/bin/env python3

# This script saves a fact to the user_memory.jsonl file.

import json
import sys
import os
from datetime import datetime, timezone

def save_to_memory(fact, importance=0.5):
    """Saves a fact to the user_memory.jsonl file."""

    script_dir = os.path.dirname(os.path.realpath(__file__))
    memory_dir = os.path.join(script_dir, "..", "memory")
    memory_file = os.path.join(memory_dir, "user_memory.jsonl")

    if not os.path.exists(memory_dir):
        os.makedirs(memory_dir)

    memory_entry = {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "fact": fact,
        "importance": importance,
    }

    with open(memory_file, "a") as f:
        f.write(json.dumps(memory_entry) + "\n")

    print(f"Saved to memory: {fact}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: save_to_mem0.py <fact_to_save> [importance]")
        sys.exit(1)

    fact_to_save = sys.argv[1]
    importance_score = float(sys.argv[2]) if len(sys.argv) > 2 else 0.5

    save_to_memory(fact_to_save, importance_score)