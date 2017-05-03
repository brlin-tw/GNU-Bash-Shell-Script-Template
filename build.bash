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

readonly APPLICATION_IDENTIFIER="gnu-bash-shell-script-template"

for a_command in mkdir tar git; do
	if ! command -v "${a_command}" &>/dev/null; then
		printf "%s: Error: %s command not found.\n" "${RUNTIME_SCRIPT_FILENAME}" "${a_command}"
		exit 1
	fi
done

determine_package_revision(){
	if [ ! -d "${RUNTIME_SCRIPT_DIRECTORY}/.git" ]; then
		# FIXME: This is a source tarball without git repository, currently we don't know how to deal with this case(may requires smudge filter)
		printf "unknown-%s" "$(basename "${RUNTIME_SCRIPT_DIRECTORY}")"
		return 0
	fi

	# Workaround: Make Git don't consider tree is dirty even when it shouldn't because of the existing clean filter
	# Why does 'git status' ignore the .gitattributes clean filter? - Stack Overflow
	# http://stackoverflow.com/questions/19807979/why-does-git-status-ignore-the-gitattributes-clean-filter
	git add -u

	if ! git rev-parse --verify HEAD &>/dev/null; then
		# git repository is newly initialized
		printf "not-version-controlled"
		return 0
	else
		# Best effort to describe the revision
		# version control - How do you achieve a numeric versioning scheme with Git? - Software Engineering Stack Exchange
 		# https://softwareengineering.stackexchange.com/questions/141973/how-do-you-achieve-a-numeric-versioning-scheme-with-git
		printf "%s" "$(git describe --tags --dirty --always)"
		return 0
	fi
}
readonly -f determine_package_revision

## init function: program entrypoint
init(){
	for commandline_argument in "${@}"; do
		if [ "${commandline_argument}" == "--help" ] || [ "${commandline_argument}" == "-h" ]; then
			printf "This program doesn't have any command line arguments.\n"
			printf "\n"
			exit 0
		fi
	done

	# Software installation directory prefix, should be overridable by configure/install script
	# Scope of external project
	#shellcheck disable=SC1090,SC1091
	source "${RUNTIME_SCRIPT_DIRECTORY}/SOFTWARE_INSTALLATION_PREFIX_DIR.source" || true
	SHC_PREFIX_DIR="$(realpath --strip "${RUNTIME_SCRIPT_DIRECTORY}/${SOFTWARE_INSTALLATION_PREFIX_DIR:-.}")" # By default we expect that the software installation directory prefix is same directory as script
	readonly SHC_PREFIX_DIR

	# Scope of external project
	#shellcheck disable=SC1090,SC1091
	source "${SHC_PREFIX_DIR}/SOFTWARE_DIRECTORY_CONFIGURATION.source"

	# Workaround: git tag always dirty even when it's isn't, manually fixing it
	# Make Git don't consider tree is dirty even when it shouldn't because of the existing clean filter
	find "${SDC_SOURCE_CODE_DIR}" -name "*.bash" -print0 | xargs --null --max-args=1 --verbose "${SDC_GIT_FILTERS_DIR}/clean-bash.manual-apply.bash"
	"${SDC_GIT_FILTERS_DIR}/smudge-bash.manual-apply.bash" "${SDC_SOURCE_CODE_DIR}/"*.bash

	if [ ! -d "${SDC_RELEASE_DIR}" ]; then
		mkdir --parents "${SDC_RELEASE_DIR}"
	fi
	tar --create --verbose --bzip2 --directory "${SHC_PREFIX_DIR}" --file "${SDC_RELEASE_DIR}/${APPLICATION_IDENTIFIER}-$(determine_package_revision).tar.bz2" -- *.source "install.bash" "README.markdown" "Source Code" "Template Setup for KDE" "Pictures"

	exit 0
}
readonly -f init
init "${@}"