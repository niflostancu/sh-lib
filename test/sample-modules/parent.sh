#!/bin/bash

source /code/base.sh

export PARENT_PATH=$(sh_get_script_path)

# sample function
function parent_func1() {
	echo "I AM TEST!"
}

