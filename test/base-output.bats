#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

import-base() {
	source /code/base.sh
}

@test "silence" {
	import-base

	# test silencing stdout
	run bats_pipe -0 @silent color_echo red "hello" \| xxd
	[ -z "$output" ]

	# test silencing stderr
	run -0 @silent sh_log_error "error goes to stderr"
	[ -z "$output" ]
}

@test "curly template interpolation" {
	import-base
	TEST_TPL='Hello {{NAME}},
Lets test if this works:
{{MULTI_MESSAGE}}|
The END Thanks {{N}}!'
	EXPECTED='Hello <Your Name>,
Lets test if this works:
one line

three line!|
The END Thanks 31337!'
	MULTI_MESSAGE='one line

three line!'

	run -0 sh_interpolate_vars "$TEST_TPL" \
		"NAME=<Your Name>" "N=31337" "MULTI_MESSAGE=$MULTI_MESSAGE"
	diff <(echo -n "$output" | xxd -g 1) <(echo -n "$EXPECTED" | xxd -g 1)
}

