#!/bin/bash
[[ -n "$__MOD_PATH" ]] || { echo "Note: only usable as module (with @import)!" >&2; return 1; }

@import --parent 'sample-hooks'

# prepend + append callbacks
function otter_hook_pre() {
	echo "{PRE}"
}
function otter_hook_post() {
	echo "{POST}"
}
sh_hooks_add "otterhook" -otter_hook_pre
sh_hooks_add "otterhook" otter_hook_post

