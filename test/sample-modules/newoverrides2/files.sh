#!/bin/bash
[[ -n "$__MOD_PATH" ]] || { echo "Note: only usable as module (with @import)!" >&2; return 1; }

OVERR2_FILES_IMPORT_COUNT=$(( ${OVERR2_FILES_IMPORT_COUNT:-0} + 1 ))

# import parent module
@import --parent 'files'

# override function
function get_test_file() {
	echo -n "SECOND!!!"
}

