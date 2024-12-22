#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

import-base() {
	source /code/base.sh
}

@test "silence" {
	import-base

	# test silencing stdout
	run bats_pipe -0 @silent sh_cecho red "hello" \| xxd
	[ -z "$output" ]

	# test silencing stderr
	run -0 @silent sh_log_error "error goes to stderr"
	[ -z "$output" ]
}

@test "str trim" {
	import-base
	
	run -0 sh_str_trim "	   LSPACE"
	[ "$output" = "LSPACE" ]

	run -0 sh_str_trim "RSPACE	"
	[ "$output" = "RSPACE" ]

	run -0 sh_str_trim "	   SPACES		"
	[ "$output" = "SPACES" ]
}

@test "str contains" {
	import-base
	run sh_str_contains "x" "1x71jasd781"
	run ! sh_str_contains "Y" "171jxasd781"
	run sh_str_contains "hello" "hello world"
	run ! sh_str_contains "HELLO" "Hey HeLlo there!"
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

