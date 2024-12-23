#!/bin/bash
[[ -n "$__MOD_PATH" ]] || { echo "Note: only usable as module (with @import)!" >&2; return 1; }

NEW_FILES_IMPORT_COUNT=$(( ${NEW_FILES_IMPORT_COUNT:-0} + 1 ))

function get_test_file() {
	echo -n "OVERWRITTEN"
}

function new_files_func() {
	true  # dummy
}

