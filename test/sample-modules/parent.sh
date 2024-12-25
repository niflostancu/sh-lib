#!/bin/bash
set -eo pipefail
# import base.sh relative to the script's directory (go up 2 times)
source "$(dirname -- "${BASH_SOURCE[0]}")/../../base.sh"

export PARENT_PATH=$(sh_get_script_path)

# sample function
function parent_func1() {
	echo "I AM TEST!"
}

