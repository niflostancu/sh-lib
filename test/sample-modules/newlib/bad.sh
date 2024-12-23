#!/bin/bash
[[ -n "$__MOD_PATH" ]] || { echo "Note: only usable as module (with @import)!" >&2; return 1; }

@import 'inexisistent-bad.sh'
echo "Bad ret code: $?"

