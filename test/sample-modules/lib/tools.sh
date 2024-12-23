#!/bin/bash
[[ -n "$__MOD_PATH" ]] || { echo "Note: only usable as module (with @import)!" >&2; return 1; }

TOOLS_IMPORT_COUNT=$(( ${TOOLS_IMPORT_COUNT:-0} + 1 ))


function use_tool() {
	true  # dummy
}

