#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

SAMPLE_DIR="$BATS_TEST_DIRNAME/sample-modules"

import-parent() {
	source /code/base.sh
	source "$SAMPLE_DIR/parent.sh"
}
import-base() {
	source /code/base.sh
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
	import-base
	SH_MOD_PATH="$SAMPLE_DIR/lib:"

	@import 'tools'
	[[ "$TOOLS_IMPORT_COUNT" -eq 1 ]]
	run -0 sh_is_function 'use_tool'

	@import 'files'
	[[ "$ORIG_FILES_IMPORT_COUNT" -eq 1 ]]
	run -0 get_test_file
	[[ "$output" == "ORIGINAL" ]]
}

@test "no duplicate imports" {
	import-base
	SH_MOD_PATH="$SAMPLE_DIR/lib:"

	@import 'tools'
	@import 'tools.sh'
	@import 'tools'
	@import 'tools.sh'

	[[ "$TOOLS_IMPORT_COUNT" -eq 1 ]]
}

@test "module not found" {
	import-base
	SH_MOD_PATH="$SAMPLE_DIR/lib:"
	run -0 ! @import 'bad'
	run -0 ! @import 'invalid-module2'
}

@test "module overrides" {
	import-base
	SH_MOD_PATH="$SAMPLE_DIR/newlib:$SAMPLE_DIR/lib:"
	@import 'files'

	run -0 get_test_file
	[[ "$output" == "OVERWRITTEN" ]]
}

@test "recursive module imports" {
	import-base
	SH_MOD_PATH="$SAMPLE_DIR/newlib:$SAMPLE_DIR/lib:"
	@import 'allmodrec.sh'
	@import 'allmodrec'

	run -0 get_test_file
	[[ "$output" == "OVERWRITTEN" ]]
	[[ "$TOOLS_IMPORT_COUNT" -eq 1 ]]
	[[ "$NEW_FILES_IMPORT_COUNT" -eq 1 ]]
}

