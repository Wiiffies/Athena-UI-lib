#!/usr/bin/env python3
"""Bundles src/Athena into dist/Athena.luau (single file for loadstring)."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SRC = ROOT / "src" / "Athena"
OUT = ROOT / "dist" / "Athena.luau"

REQUIRE_RE = re.compile(r"require\(\s*script((?:\.[A-Za-z_][A-Za-z0-9_]*)+)\s*\)")
SCRIPT_REF_RE = re.compile(r"\bscript\.")


def module_key(path: Path) -> str:
    rel = path.relative_to(SRC).with_suffix("")
    parts = list(rel.parts)
    if parts[-1] == "init":
        parts = parts[:-1]
    if not parts:
        return "Athena"
    return ".".join(parts)


def module_parts(path: Path) -> list[str]:
    rel = path.relative_to(SRC).with_suffix("")
    parts = ["Athena"] + list(rel.parts)
    if parts[-1] == "init":
        parts = parts[:-1]
    return parts


def resolve_require(path: Path, chain: list[str]) -> str:
    parts = module_parts(path)
    for token in chain:
        if token == "Parent":
            parts = parts[:-1]
        else:
            parts.append(token)
    if not parts:
        raise SystemExit(f"Unresolvable require in {path}: {chain}")
    # Drop the root module name when present.
    if parts[0] == "Athena":
        parts = parts[1:]
    return ".".join(parts)


def rewrite(path: Path, source: str) -> str:
    def replace(match: re.Match[str]) -> str:
        chain = [part for part in match.group(1).split(".") if part]
        key = resolve_require(path, chain)
        return f'require("{key}")'

    return REQUIRE_RE.sub(replace, source)


def collect() -> dict[str, Path]:
    modules: dict[str, Path] = {}
    for path in sorted(SRC.rglob("*.luau")):
        modules[module_key(path)] = path
    return modules


def main() -> int:
    modules = collect()
    if "Athena" not in modules:
        raise SystemExit("Missing src/Athena/init.luau")

    ordered = [key for key in modules if key != "Athena"]
    ordered.sort()
    ordered.append("Athena")

    chunks: list[str] = []
    total_lines = 0

    for key in ordered:
        path = modules[key]
        source = rewrite(path, path.read_text(encoding="utf-8"))

        if SCRIPT_REF_RE.search(source):
            raise SystemExit(f"Unresolved script reference in {path}")

        if f'__modules["{key}"]' in "\n".join(chunks):
            raise SystemExit(f"Duplicate module key: {key}")

        total_lines += source.count("\n") + 1
        chunks.append(
            f'__modules["{key}"] = function(require)\n'
            f"{source.rstrip()}\n"
            f"end\n"
        )

    # Validate every required module exists.
    body = "\n".join(chunks)
    for name in re.findall(r'require\("([A-Za-z0-9_.]+)"\)', body):
        if name not in modules:
            raise SystemExit(f"Unknown module referenced in bundle: {name}")

    header = """--[[
	Athena UI · v1.2.7
	A close recreation of the Athena client interface for Roblox.

	Load it in a LocalScript:

		local Athena = loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/Wiiffies/Athena-UI-lib/main/dist/Athena.luau"
		))()

		local Window = Athena:CreateWindow({
			Title = "My Application",
			Theme = "Athena",
			DynamicIsland = { Enabled = true },
		})
		Window:SetDynamicIslandEnabled(true)
		local Tab = Window:CreateTab("Main")
		local Section = Tab:CreateSection("General")

		Section:CreateButton({
			Name = "Example Button",
			Callback = function()
				print("Clicked!")
			end,
		})

	Documentation: docs/API.md
	This file is generated from src/Athena by build.py. Do not edit by hand.
]]

local __modules = {}
local __cache = {}

local function __require(name)
	local cached = __cache[name]
	if cached ~= nil then
		return cached
	end

	local loader = __modules[name]
	if not loader then
		error("[Athena] Unknown module: " .. tostring(name), 2)
	end

	local module = loader(__require)
	__cache[name] = module
	return module
end

"""

    bundle = header + body + '\nreturn __require("Athena")\n'
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(bundle, encoding="utf-8")

    print(f"Bundled {len(modules)} modules, {total_lines} source lines -> {OUT}")
    print(f"Output size: {OUT.stat().st_size} bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
