#!/usr/bin/env python3
"""Sway-style numbered workspaces: odd on laptop, even on HDMI; moves never follow."""

import argparse
import fcntl
import json
import os
from pathlib import Path
import subprocess
import sys

LAPTOP = "eDP-1"
EXTERNAL = "HDMI-A-1"


def ipc(*args):
    result = subprocess.run(
        ["mmsg", *args], check=True, capture_output=True, text=True, timeout=5
    )
    data = json.loads(result.stdout)
    if "error" in data:
        raise RuntimeError(data["error"])
    return data


def dispatch(call, command, client=None):
    args = ["dispatch", command]
    if client is not None:
        args.append(f"client,{client}")
    return call(*args)


def restore_view(call, monitor):
    tags = "|".join(str(tag) for tag in monitor["active_tags"])
    dispatch(call, f"viewcrossmon,{tags},{monitor['name']}")


def route(action, tag=None, call=ipc):
    monitors = call("get", "all-monitors")["monitors"]
    source = next(m for m in monitors if m["active"])
    by_name = {m["name"]: m for m in monitors}

    if action == "init":
        # Don't disturb restored applications or an already-used workspace.
        changed = False
        for name, initial in ((LAPTOP, 1), (EXTERNAL, 2)):
            monitor = by_name.get(name)
            if monitor and monitor["active_tags"] != [initial]:
                if not any(t["client_count"] for t in monitor["tags"] if t["is_active"]):
                    dispatch(call, f"viewcrossmon,{initial},{name}")
                    changed = True
        if changed:
            dispatch(call, f"focusmon,{source['name']}")
        return

    if tag not in range(1, 11):
        raise ValueError("workspace must be 1–10 (the 0 key selects 10)")
    preferred = LAPTOP if tag % 2 else EXTERNAL
    target = by_name.get(preferred, by_name.get(LAPTOP, source))
    if action == "view":
        dispatch(call, f"viewcrossmon,{tag},{target['name']}")
        return

    client = source["active_client"]["id"]
    if client is None:
        return
    if target["name"] == source["name"]:
        dispatch(call, f"tagsilent,{tag}", client)
        return

    # ponytail: IPC isn't atomic; restore views/focus after the native follow move.
    # A compositor-side silent cross-monitor dispatcher would remove transient switching.
    try:
        dispatch(call, f"tagcrossmon,{tag},{target['name']}", client)
    finally:
        try:
            restore_view(call, target)
        finally:
            dispatch(call, f"focusmon,{source['name']}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=("view", "move", "init"))
    parser.add_argument("tag", nargs="?", type=int, choices=range(1, 11))
    args = parser.parse_args()
    if args.action != "init" and args.tag is None:
        parser.error("view/move requires a workspace number")
    # Serialize rapid shortcuts so one move cannot restore over the next action.
    runtime = Path(os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"))
    with (runtime / "mango-workspace.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        route(args.action, args.tag)


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.SubprocessError) as error:
        print(f"mango-workspace: {error}", file=sys.stderr)
        sys.exit(1)
