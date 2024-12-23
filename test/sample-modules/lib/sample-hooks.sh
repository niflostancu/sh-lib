#!/bin/bash
[[ -n "$__MOD_PATH" ]] || { echo "Note: only usable as module (with @import)!" >&2; return 1; }

HOOK_NAME=thehook

function hook1() {
	echo "one"
}
sh_hooks_add "$HOOK_NAME" hook1

function hook2() {
	echo "second"
}
sh_hooks_add "$HOOK_NAME" hook2

function hook3() {
	echo "third"
}
sh_hooks_add "$HOOK_NAME" hook3

# let's try with another hook key
function otter_hook() {
	echo "OTTER"
}
sh_hooks_add "otterhook" otter_hook
sh_hooks_add "otterhook" -hook1

