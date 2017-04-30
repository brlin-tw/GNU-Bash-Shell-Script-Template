#!/usr/bin/env bash
## Makes debuggers' life easier - Unofficial Bash Strict Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
### Exit immediately if a pipeline, which may consist of a single simple command, a list, or a compound command returns a non-zero status.  The shell does not exit if the command that fails is part of the command list immediately following a `while' or `until' keyword, part of the test in an `if' statement, part of any command executed in a `&&' or `||' list except the command following the final `&&' or `||', any command in a pipeline but the last, or if the command's return status is being inverted with `!'.  If a compound command other than a subshell returns a non-zero status because a command failed while `-e' was being ignored, the shell does not exit.  A trap on `ERR', if set, is executed before the shell exits.
set -o errexit

### Treat unset variables and parameters other than the special parameters `@' or `*' as an error when performing parameter expansion.  An error message will be written to the standard error, and a non-interactive shell will exit.
set -o nounset

### If set, any trap on `ERR' is inherited by shell functions, command substitutions, and commands executed in a subshell environment.  The `ERR' trap is normally not inherited in such cases.
set -o errtrace

### If set, the return value of a pipeline is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.  This option is disabled by default.
set -o pipefail

## Non-overridable Primitive Variables
##
## BashFAQ/How do I determine the location of my script? I want to read some config files from the same place. - Greg's Wiki
## http://mywiki.wooledge.org/BashFAQ/028
RUNTIME_SCRIPT_FILENAME="$(basename "${BASH_SOURCE[0]}")"
readonly RUNTIME_SCRIPT_FILENAME
RUNTIME_SCRIPT_DIRECTORY="$(dirname "$(realpath --strip "${0}")")"
readonly RUNTIME_SCRIPT_DIRECTORY
readonly RUNTIME_SCRIPT_PATH_ABSOLUTE="${RUNTIME_SCRIPT_DIRECTORY}/${RUNTIME_SCRIPT_FILENAME}"
readonly RUNTIME_SCRIPT_PATH_RELATIVE="${0}"
readonly RUNTIME_COMMAND_BASE="${RUNTIME_COMMAND_BASE:-${0}}"

trap_errexit(){
	printf "An error occurred and script is prematurely aborted\n" 1>&2
	return 0
}; readonly -f trap_errexit; trap trap_errexit ERR

trap_exit(){
	printf "Goodbye.\n"
}; readonly -f trap_exit; trap trap_exit EXIT

## init function: program entrypoint
init(){

	exit 0
}; readonly -f init
init "${@}"