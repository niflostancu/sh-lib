# Shell Lib - Useful shell scripts collection

Small libraries implementing common shell scripting idioms (mainly in bash).

## Features

- versatile color printing & logging routines;
- text outputting / manipulation utils;
- everything is unit-tested using BATS + Docker containers!

## Examples

Simply source the library (for example, `base.sh`). You can either close the
repository inside a subdirectory in your project or simply copy download the
script (e.g., inside a `lib/` subdirectory.

A common pattern is to use the parent script's base directory to find the library 
location, which you can do easily in `bash`:

```sh
# find the script's base directory
SCRIPT_BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# source base.sh relative to the parent script's base
source "$SCRIPT_BASE/lib/base.sh"
```

Color printing & logging routines:
```sh
sh_cecho "red" "Code red"
sh_cecho -n "blue" "Feeling blue, no newline appended!"
sh_cecho "b-green" "Bold green (if terminal supports)"

sh_log_info "Information here!"
sh_log_error "Something bad happened!"
sh_log_panic "PANIC: will print this error and exit 1!"

DEBUG=1
sh_log_debug "Printed only if \$DEBUG=1"
```

## Installation

1. Using Git Submodules

Recommended only if you already use git submodules in your project:
```sh
# will clone this repo as submodule inside the ./sh-lib directory
git submodule add "https://github.com/niflostancu/sh-lib.git" ./sh-lib
```

2. Manual and/or Makefile-managed distribution

You can use wget to manually download the desired script, e.g.:
```sh
wget -O lib/base.sh "https://raw.githubusercontent.com/niflostancu/sh-lib/refs/heads/main/base.sh"
chmod lib/base.sh
```

Or you can use Makefile script to do that, check out this sample:
[dist/Makefile.dist](./dist/Makefile.dist)

