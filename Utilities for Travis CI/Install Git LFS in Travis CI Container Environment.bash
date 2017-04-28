#!/usr/bin/env bash
# Install Git LFS in Travis CI Container Environment
# 林博仁 Copyright 2017
# Run following command after this script in travis.yml:
#
# 	PATH="$(printf "${HOME}"/git-lfs-*):${PATH}"
#
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

fetch_latest_git_lfs_release_tag(){
	# How to get list of latest tags in remote git? - Stack Overflow
	# http://stackoverflow.com/questions/20734181/how-to-get-list-of-latest-tags-in-remote-git
	#Seems to be false-positive
	#shellcheck disable=SC2026
	git ls-remote https://github.com/git-lfs/git-lfs\
		| grep -o 'refs/tags/v[0-9]*\.[0-9]*\.[0-9]*' \
		| sort -r\
		| head --lines=1\
		| grep -o '[^\/]*$'
	return 0
}; readonly -f fetch_latest_git_lfs_release_tag

cleanup(){
	:
}; readonly -f cleanup
trap cleanup EXIT

errexit(){
	printf "%s: ERROR: Failed to download Git Large File Storage.\n" "${RUNTIME_SCRIPT_FILENAME}" 1>&2
}; readonly -f errexit
trap errexit ERR

## init function: program entrypoint
init(){
	declare latest_release_tag
	latest_release_tag="$(fetch_latest_git_lfs_release_tag)"
	readonly latest_release_tag

	wget --directory-prefix="${HOME}" "https://github.com/git-lfs/git-lfs/releases/download/${latest_release_tag}/git-lfs-linux-amd64-${latest_release_tag:1}.tar.gz"

	tar --extract --verbose --directory="${HOME}" --file "${HOME}/git-lfs-linux-amd64-${latest_release_tag:1}.tar.gz"

	printf "Git Large File Storage installed successfully, note that you should also run the following command in .travis.yml to add git-lfs to executable search path:\n"
	printf "\n"

	# Disable SC2016, the expansion isn't going to happen here
	# shellcheck disable=SC2016
	printf '\tPATH="$(printf "${HOME}"/git-lfs-*):${PATH}"\n'
	exit 0
}
readonly -f init
init "${@}"