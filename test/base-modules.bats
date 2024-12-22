#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

import-libs() {
	source /code/base.sh
	source "$BATS_TEST_DIRNAME/sample-modules/parent.sh"
}

@test "script module path" {
	import-libs

	[[ "$PARENT_PATH" == "$BATS_TEST_DIRNAME/sample-modules" ]]
}

@test "function exists" {
	import-libs

	run -0 sh_is_function parent_func1
	run -0 ! sh_is_function parent_func_not_found
}

