#!/bin/bash
set -eo pipefail
# debug breaks output checks
DEBUG=
source "$(dirname -- "${BASH_SOURCE[0]}")/../../base.sh"

export PARENT_PATH=$(sh_get_script_path)
SH_MOD_PATH="$PARENT_PATH/newlib:$PARENT_PATH/lib:$SH_MOD_PATH"

@import 'tools'
@import 'sample-hooks'

sh_hooks_run otterhook

