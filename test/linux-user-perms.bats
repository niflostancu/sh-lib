#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

import-libs() {
	source /code/base.sh
	source /code/linux.sh
}

@test "check root user" {
	import-libs
	run -0 sh_user_must_be_root
}

@test "create test user" {
	import-libs
	SHELL=/bin/bash
	run -0 sh_create_user "test" 2002
	run -0 id -u test
	[ "$output" = "2002" ]
	run -0 sh_create_user "test" 2002

	run -0 ! su test -c "$(declare -f import-libs); import-libs; sh_user_must_be_root;"
	[[ "$output" =~ must.+be.+root ]]
}

@test "change owner & permissions" {
	import-libs
	SHELL=/bin/bash
	run -0 sh_create_user "test" 2002

	local DIR="/tmp/perms-test"
	mkdir -p "$DIR/inner/dir" "$DIR/inner2/dir2"
	touch "$DIR/inner/dir/file"
	touch "$DIR/inner2/dir2/file"
	run -0 sh_change_perms test:test 750 "$DIR"
	run -0 stat -c '%U:%G %a' "$DIR/inner/dir/file"
	[[ "$output" == "test:test 750" ]]

	run -0 sh_change_perms test:test 504 "$DIR/inner2"
	run -0 stat -c '%U:%G %a' "$DIR/inner2/dir2/file"
	[[ "$output" == "test:test 504" ]]
}

