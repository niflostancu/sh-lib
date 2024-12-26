# SH[ell] Library - Useful shell scripts collection

Opinionated `bash` library implementing some common shell scripting idioms.
Designed to be small, flexible & modular, well documented and tested!

## Features

- color printing & logging routines;
- text output / string manipulation utils;
- versatile bash module system (`@import`) + function hooks;
- other modules: linux user/permissions utils, files handling (WIP);
- everything is unit-tested using [BATS](https://bats-core.readthedocs.io) + Docker containers!

## Installation / distribution

You will want to bundle some or all of the modules with your project.
There are many ways of doing this:

1. Using Git Submodules

    Recommended only if you already use git submodules in your project:
    ```sh
    # will clone this repo as submodule inside the ./sh-lib directory
    git submodule add "https://github.com/niflostancu/sh-lib.git" ./sh-lib
    ```

2. Manual downloading

    You can use wget to manually download the desired script, e.g.:
    ```sh
    wget -O lib/base.sh "https://raw.githubusercontent.com/niflostancu/sh-lib/refs/heads/main/base.sh"
    ```

    _(or check out [fetch.sh](https://github.com/niflostancu/fetch.sh)!)_

3. Makefile-based automatic distribution

    You can use Makefile script to manage your dependencies, check out this sample:
    [dist/Makefile.dist](./dist/Makefile.dist)

## Usage / Examples

### Base library (`base.sh`) 

Simply source it.
You can either close the repository inside a subdirectory in your project or 
simply download/copy the script inside a subdirectory, e.g., `lib/`.

A common pattern is to use the parent script's base directory to find the library 
location, which you can do easily in `bash`:

```sh
set -eo pipefail  # RECOMMENDED: exit on first failed command
# find the script's base directory
SCRIPT_BASE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# source base.sh relative to the parent script's base
source "$SCRIPT_BASE/lib/base.sh"
```

OR, as a shorter one-liner version (not caring about path sanitization):

```sh
set -eo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/lib/base.sh"
```

In order to keep existing namespaces clean, almost every function from the 
`base.sh` module is prefixed using `sh_`. There are small exceptions to this
(see the `@import` function), but they can be disabled by setting 
`SH_NO_ALIASES=1`.

#### Color printing + logging utils

The `sh_cecho` is an enhanced `echo` that takes the color as its first argument: 

```sh
sh_cecho "red" "Code red"
sh_cecho -n "blue" "Feeling blue, no newline appended!"
sh_cecho "b-green" "Bold green (if terminal supports)"
```

The logging functions are `sh_log*` with three levels (though yo can define
many more by altering some variables, see the source code!):

```sh
sh_log_info "Information here!"
# note: these two output their message to stderr:
sh_log_error "Something bad happened!"
sh_log_panic "PANIC: will print this error and exit 1!"
# all of the above are actually convenient wrappers for `sh_log`:
sh_log error "Oh noes!" >&2

DEBUG=1
sh_log_debug "Printed only if \$DEBUG=1"
```

### String / text output routines

The base module also has several commonly-used functions for string/output manipulation:

```sh
# silences both stdout & stderr!
@silent echo "This will not get printed!"

VALUE=$(sh_str_trim "   spaces around trimmed    ")
if sh_str_contains "hello world" "hell"; then true; fi
# string templating:
sh_interpolate_vars "Hello {{NAME}}, welcome to {{HOST}}!" \
    NAME=root HOST=localhost
```

### Modules & hooks

The `sh_import` (aliased as `@import`) can be used to source other bash modules.
It searches a special PATH-like variable: `SH_MOD_PATH`, which defaults to the
directory containing `base.sh` (wherever it is! see `sh_get_script_path`).

```sh
# you can also omit the .sh extension:
@import 'linux.sh'
sh_user_must_be_root  # function from linux.sh
# importing the same module again will be a NOOP
@import 'linux.sh'  # already imported, does nothing
```

Now, let's say you want to modify the behavior of the logging functions to also
send the message to syslog. Hooks are execution points where the user may
register their own functions to be called whenever an action/event happens.

For our syslog example, `sh_log` actually calls `sh_hooks_run sh_log_cb ...`,
allowing us to implement additional features:

```sh
function log_to_syslog() {
    shift # first argument is the callback name
    local LEVEL="$1"; shift; # sh_log gives us the level, then message
    logger -t 'myscript' -p "user.$LEVEL" "$*"
}
# append our function as hook to `sh_log_cb`
sh_hooks_add sh_log_cb log_to_syslog
```

