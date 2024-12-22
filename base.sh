#!/bin/bash
: <<'DOCS'
Base bash functions library
https://github.com/niflostancu/sh-lib

* color print / debug routines;
* captioned / indented / silent printing of a function's output;
* basic string manipulation / interpolation routines;

DOCS

##============================================================================##
##------------------- Color Printing & Logging routines ----------------------##
##----------------------------------------------------------------------------##

# test if the terminal supports colors
TERM_COLORS=${TERM_COLORS:-}
if test -t 1; then
	_tput_colors=$(tput colors 2>/dev/null || true)
	if test -z "$_tput_colors"; then
		[[ "$TERM" != *"color"* ]] || TERM_COLORS=1
	elif test "$_tput_colors" -ge 8; then TERM_COLORS=1; fi
fi
export TERM_COLORS

# Associative map with log level colors & ANSI constants
declare -g -A SH_COLOR_PRINT_MAP=(
	['black']=30    ['red']=31       ['green']=32
	['yellow']=33   ['blue']=34      ['magenta']=35
	['cyan']=36     ['white']=37     ['default']=39
)
# supplementary text styles ("b-<color>" for bold etc, '*<color>' for bright)
for c in "${!SH_COLOR_PRINT_MAP[@]}"; do
	_cc="${SH_COLOR_PRINT_MAP[$c]}"
	SH_COLOR_PRINT_MAP+=( ["b-$c"]="1;$_cc" ["i-$c"]="3;$_cc" ["u-$c"]="4;$_cc"
		["x-$c"]="2;$_cc" ["*$c"]="$(( _cc + 60 ))" )
done

# Usage: sh_cecho [-ne] COLOR TEXT...
function sh_cecho() {
	local EARGS=() ESC=$'\e[' RST=$'\e[0m'
	while [[ $# -gt 1 ]]; do case "$1" in
		-*) EARGS+=("$1"); ;;
		*) break; ;;
	esac; shift; done
	local COLOR="${SH_COLOR_PRINT_MAP[$1]}"; shift
	[[ -n "$COLOR" ]] || return 1
	# handle color aliases:
	[[ ! -v "SH_COLOR_PRINT_MAP[$COLOR]" ]] || COLOR="${SH_COLOR_PRINT_MAP[$COLOR]}"
	COLOR="${ESC}${COLOR}m"
	[[ -n "$TERM_COLORS" ]] || { COLOR=''; ESC=''; RST=''; }
	# finally, compose the message
	echo "${EARGS[@]}" "${COLOR}$*${RST}";
}
# and some aliases:
function sh_color_echo() { sh_cecho "$@"; }

## ---- Logging functions ----
# log colors (alias key from the same map)
SH_COLOR_PRINT_MAP+=([debug]="cyan" [info]="b-green" [err]="b-red" [emerg]="b-red")
# environment log prefix: prepended to all logged messages
SH_LOG_PREFIX=${SH_LOG_PREFIX:-}
# you can register a logging callback (e.g., to also send to syslog)
SH_LOG_CALLBACK=
# debug enable environment var (if non-null)
DEBUG=${DEBUG:-}

# generic logging function
function sh_log() {
	local LEVEL="$1"; shift
	[[ "$LEVEL" != "error" ]] || LEVEL="err"
	! sh_is_function "$SH_LOG_CALLBACK" || "$SH_LOG_CALLBACK" "$LEVEL" "$*"
	sh_cecho "$LEVEL" "${SH_LOG_PREFIX:+"$SH_LOG_PREFIX: "}$*"
}

# only logs if the DEBUG variable is non-null
function sh_log_debug() {
	[[ -n "$DEBUG" ]] || return 0
	sh_log "debug" "$@"
}
function sh_log_info() { sh_log "info" "$@"; }
function sh_log_error() { sh_log "err" "$@" >&2; }
function sh_log_panic() { sh_log "emerg" "$@" >&2; exit 1; }


##============================================================================##
##-------------------------- String / output helpers -------------------------##
##----------------------------------------------------------------------------##

# Silences the output of a command (use in front)
function @silent() {
	"$@" >/dev/null 2>&1
}

# Removes whitespace from beginning/end of string
function sh_str_trim() {
	local VAR="$1"
	VAR="${VAR#"${VAR%%[![:space:]]*}"}"
	VAR="${VAR%"${VAR##*[![:space:]]}"}"    
	echo -n "$VAR"
}

# Checks if a string contains a given substring
# str_contains NEEDLE HAYSTACK
function sh_str_contains() {
	[[ "$1" == *"$2"* ]]
}

# Interpolates multiple curly braced '{{VARIABLE}}'s within a given TEMPLATE.
# Uses env's syntax for VAR[=VALUE], first argument is the TEMPLATE.
function sh_interpolate_vars() {
	local TEMPLATE="$1"; shift
	for var in "$@"; do
		TEMPLATE="${TEMPLATE//"{{${var%%=*}}}"/"${var#*=}"}"
	done
	printf "%s" "$TEMPLATE"
}

##============================================================================##
##-------------------------- Function/module helpers -------------------------##
##----------------------------------------------------------------------------##

function sh_is_function() {
	[[ -n "$1" && $(type -t "$1") == "function" ]]
}
