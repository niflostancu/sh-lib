#!/bin/bash
[[ -n "$__MOD_PATH" ]] || { echo "Note: only usable as module (with @import)!" >&2; return 1; }

ORIG_FILES_IMPORT_COUNT=$(( ${ORIG_FILES_IMPORT_COUNT:-0} + 1 ))

function get_test_file() {
	echo -n "ORIGINAL"
}

function delete_files() {
	true  # dummy
}

