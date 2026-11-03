#!/usr/bin/env python3
"""Run with: python3 ~/.config/mango/test_workspace.py (no desktop changes)."""

from copy import deepcopy
from workspace import EXTERNAL, LAPTOP, route


def monitor(name, active, tags, client=None):
    return {
        "name": name,
        "active": active,
        "active_tags": tags,
        "active_client": {"id": client},
        "tags": [
            {"index": n, "is_active": n in tags, "client_count": int(client is not None and n in tags)}
            for n in range(1, 11)
        ],
    }


class Desktop:
    def __init__(self, external=True, focus=LAPTOP):
        self.monitors = [monitor(LAPTOP, focus == LAPTOP, [1], 7)]
        if external:
            self.monitors.append(monitor(EXTERNAL, focus == EXTERNAL, [4], 8))
        self.commands = []
        self.location = {7: (LAPTOP, [1]), 8: (EXTERNAL, [4])}

    def call(self, *args):
        if args == ("get", "all-monitors"):
            return {"monitors": deepcopy(self.monitors)}
        assert args[0] == "dispatch", args
        self.commands.append(args)
        command, *values = args[1].split(",")
        if command == "tagsilent":
            client = int(args[2].split(",")[1])
            self.location[client] = (self.location[client][0], [int(values[0])])
            return {}
        name = values[-1]
        for m in self.monitors:
            m["active"] = m["name"] == name
            if m["active"] and command in ("viewcrossmon", "tagcrossmon"):
                m["active_tags"] = [int(n) for n in values[0].split("|")]
        if command == "tagcrossmon":
            client = int(args[2].split(",")[1])
            self.location[client] = (name, [int(values[0])])
        return {}


def check():
    for external in (False, True):
        for focus in ([LAPTOP, EXTERNAL] if external else [LAPTOP]):
            for tag in range(1, 11):
                target = EXTERNAL if external and tag % 2 == 0 else LAPTOP
                desktop = Desktop(external, focus)
                route("view", tag, desktop.call)
                assert next(m for m in desktop.monitors if m["active"])["name"] == target
                assert next(m for m in desktop.monitors if m["active"])["active_tags"] == [tag]

                desktop = Desktop(external, focus)
                views = {m["name"]: m["active_tags"][:] for m in desktop.monitors}
                client = 7 if focus == LAPTOP else 8
                route("move", tag, desktop.call)
                assert desktop.location[client] == (target, [tag])
                assert next(m for m in desktop.monitors if m["active"])["name"] == focus
                assert {m["name"]: m["active_tags"] for m in desktop.monitors} == views

    desktop = Desktop()
    desktop.monitors[0]["active_client"]["id"] = None
    route("move", 2, desktop.call)
    assert not desktop.commands

    desktop = Desktop()
    desktop.monitors[1]["active_tags"] = [2, 4]
    route("move", 6, desktop.call)
    assert desktop.monitors[1]["active_tags"] == [2, 4]

    desktop = Desktop()
    desktop.monitors[1] = monitor(EXTERNAL, False, [1])
    route("init", call=desktop.call)
    assert desktop.monitors[1]["active_tags"] == [2]
    assert desktop.monitors[0]["active"]
    desktop.commands.clear()
    route("init", call=desktop.call)
    assert not desktop.commands

    for tag in (None, 0, 11, -1):
        try:
            route("move", tag, Desktop().call)
        except ValueError:
            pass
        else:
            raise AssertionError(f"accepted invalid tag: {tag}")
    print("PASS: odd/even view + silent move, both directions, laptop fallback, empty focus, multitag, startup, validation")


if __name__ == "__main__":
    check()
