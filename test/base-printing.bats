#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
	[[ -n "$BATS_DELAY" ]] && sleep "$BATS_DELAY" || true
}

import-base() {
	source /code/base.sh
}
_comm() {
	echo -n "# " >&3
}

@test "source base library" {
	import-base
}

@test "colors" {
	import-base
	# force terminal colors
	export TERM_COLORS=1

	# compare binary output
	run bats_pipe -0 color_echo red "hello" \| xxd
	[ "$output" = "$(echo -n $'\e[31mhello\e[0m\n' | xxd)" ]
	# also test -n parameter
	run bats_pipe -0 color_echo -n red "hello" \| xxd
	[ "$output" = "$(echo -n $'\e[31mhello\e[0m' | xxd)" ]
	_comm; color_echo red "Hello in red" >&3

	run bats_pipe -0 color_echo '*red' "hello" \| xxd
	[ "$output" = "$(echo -n $'\e[91mhello\e[0m\n' | xxd)" ]
	_comm; color_echo '*red' "Hello in *red" >&3

	run bats_pipe -0 color_echo b-red "hello" \| xxd
	[ "$output" = "$(echo -n $'\e[1;31mhello\e[0m\n' | xxd)" ]
	_comm; color_echo b-red "Hello in b-red" >&3

	run bats_pipe -0 color_echo green "hello" \| xxd
	[ "$output" = "$(echo -n $'\e[32mhello\e[0m\n' | xxd)" ]
	_comm; color_echo green "Hello in green" >&3

	run bats_pipe -0 color_echo blue "hello" \| xxd
	[ "$output" = "$(echo -n $'\e[34mhello\e[0m\n' | xxd)" ]
	_comm; color_echo blue "Hello in blue" >&3

	run bats_pipe -0 color_echo u-cyan "hello" \| xxd
	[ "$output" = "$(echo -n $'\e[4;36mhello\e[0m\n' | xxd)" ]
	_comm; color_echo u-cyan "Hello in u-cyan" >&3

	run bats_pipe -0 color_echo i-magenta "hello" \| xxd
	[ "$output" = "$(echo -n $'\e[3;35mhello\e[0m\n' | xxd)" ]
	_comm; color_echo i-magenta "Hello in i-magenta" >&3
}

@test "color_echo with invalid color" {
	import-base
	export TERM_COLORS=1
	run ! color_echo "invalid" "invalid color"
}

@test "logging functions" {
	import-base
	export TERM_COLORS=1
	export DEBUG=

	run -0 sh_log_info "This is information"
	[ -n "$output" ] && [[ "$output" == *$'\e['* ]]
	_comm; sh_log_info "This is information" >&3

	run -0 sh_log_error "This is a bug"
	[ -n "$output" ] && [[ "$output" == *$'\e['* ]]
	_comm; sh_log_error "This is a bug" 2>&3

	run -0 sh_log_debug "This should not be logged"
	[ -z "$output" ]
	export DEBUG=1
	run -0 sh_log_debug "This is a DEBUG message!"
	[ -n "$output" ]
	_comm; sh_log_debug "This is a DEBUG message!" >&3
}

_log_cb_test() {
	echo "Hey, LOG_CB_CALLED!"
}

@test "logging callback" {
	import-base
	SH_LOG_CALLBACK=_log_cb_test
	run -0 sh_log_info "Lets test this"
	[ -n "$output" ] && [[ "$output" == *'LOG_CB_CALLED'* ]]
}

