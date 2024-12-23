#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

SAMPLE_DIR="$BATS_TEST_DIRNAME/sample-modules"

import-parent() {
	source /code/base.sh
	source "$SAMPLE_DIR/parent.sh"
}
import-mods() {
	source /code/base.sh
	SH_MOD_PATH="$SAMPLE_DIR/lib"
}
import-newmods() {
	source /code/base.sh
	SH_MOD_PATH="$SAMPLE_DIR/newlib:$SAMPLE_DIR/lib"
}

@test "script module path" {
	import-parent

	[[ "$PARENT_PATH" == "$BATS_TEST_DIRNAME/sample-modules" ]]
}

@test "function exists" {
	import-parent

	run -0 sh_is_function parent_func1
	run -0 ! sh_is_function parent_func_not_found
}

@test "module @import" {
	import-mods

	@import 'tools'
	[[ "$TOOLS_IMPORT_COUNT" -eq 1 ]]
	run -0 sh_is_function 'use_tool'

	@import 'files'
	[[ "$ORIG_FILES_IMPORT_COUNT" -eq 1 ]]
	run -0 get_test_file
	[[ "$output" == "ORIGINAL" ]]
}

@test "no duplicate imports" {
	import-mods

	@import 'tools'
	@import 'tools.sh'
	@import 'tools'
	@import 'tools.sh'

	[[ "$TOOLS_IMPORT_COUNT" -eq 1 ]]
}

function _import_bad_seterr() {
	set -e
	printf BASHOPTS:%s\\n "$-"
	sh_log_info "Importing module with bad imports..."
	@import "$@" 'bad' || { echo "SAMIBAGPULAAA"; return 2; } 
}

@test "module not found" {
	import-newmods
	run ! @import 'invalid-module1'
	# workaround for BATS disabling errexit (-e)
	run ! bash -c "$(declare -p import-newmods); $(declare -p _import_bad_seterr); _import_bad_seterr"
}

@test "optional modules" {
	import-newmods
	run -0 @import --optional 'invalid-module-1001'
	run -0 @import --opt 'invalid_1337_module'
	# the optional flag should not propagate!
	run ! bash -c "$(declare -p import-newmods); $(declare -p _import_bad_seterr); _import_bad_seterr --opt"
}

@test "module overrides" {
	import-newmods
	@import 'files'

	run -0 get_test_file
	[[ "$output" == "OVERWRITTEN" ]]
}

@test "recursive module imports" {
	import-newmods
	@import 'allmodrec.sh'
	@import 'allmodrec'

	run -0 get_test_file
	[[ "$output" == "OVERWRITTEN" ]]
	[[ "$TOOLS_IMPORT_COUNT" -eq 1 ]]
	[[ "$NEW_FILES_IMPORT_COUNT" -eq 1 ]]
}

@test "module parent import from overrides" {
	import-newmods
	SH_MOD_PATH=":$SAMPLE_DIR/newoverrides2:$SH_MOD_PATH:"
	FILES_IMPORT_PARENTS=1
	@import 'allmodrec'

	[[ "$ORIG_FILES_IMPORT_COUNT" -eq 1 ]]
	[[ "$NEW_FILES_IMPORT_COUNT" -eq 1 ]]
	[[ "$OVERR2_FILES_IMPORT_COUNT" -eq 1 ]]

	run -0 get_test_file
	[[ "$output" == "SECOND!!!" ]]
}

@test "simple hooks" {
	import-mods
	EXPECTED1=$'one\nsecond\nthird'
	EXPECTED2=$'one\nOTTER'

	@import 'sample-hooks'
	run -0 sh_hooks_run thehook
	[[ "$output" == "$EXPECTED1" ]]
	run -0 sh_hooks_run otterhook
	[[ "$output" == "$EXPECTED2" ]]
}

@test "full script with overrides and hooks" {
	EXPECTED_OTTER=$'{PRE}\none\nOTTER\n{POST}'
	run -0 bash "$SAMPLE_DIR/full.sh"
	[[ "$output" == "$EXPECTED_OTTER" ]]
}

