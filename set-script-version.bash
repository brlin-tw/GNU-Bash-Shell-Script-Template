#!/usr/bin/env bash
# shellcheck disable=SC2034
# Program to set the software product's version string
# 林博仁 © 2018

## Makes debuggers' life easier - Unofficial Bash Strict Mode
## BASHDOC: Shell Builtin Commands - Modifying Shell Behavior - The Set Builtin
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail

## Runtime Dependencies Checking
declare\
	runtime_dependency_checking_result=still-pass\
	required_software

for required_command in \
	basename\
	dirname\
	git\
	realpath\
	sed; do
	if ! command -v "${required_command}" &>/dev/null; then
		runtime_dependency_checking_result=fail

		case "${required_command}" in
			basename\
			|dirname\
			|realpath)
				required_software='GNU Coreutils'
				;;
			git)
				required_software='Git'
				;;
			sed)
				required_software='GNU Sed'
				;;
			*)
				required_software="${required_command}"
				;;
		esac

		printf --\
			'Error: This program requires "%s" to be installed and its executables in the executable searching paths.\n'\
			"${required_software}" 1>&2
		unset required_software
	fi
done; unset required_command required_software

if [ "${runtime_dependency_checking_result}" = fail ]; then
	printf --\
		'Error: Runtime dependency checking fail, the progrom cannot continue.\n' 1>&2
	exit 1
fi; unset runtime_dependency_checking_result

## Non-overridable Primitive Variables
## BASHDOC: Shell Variables » Bash Variables
## BASHDOC: Basic Shell Features » Shell Parameters » Special Parameters
if [ -v 'BASH_SOURCE[0]' ]; then
	RUNTIME_EXECUTABLE_PATH="$(realpath --strip "${BASH_SOURCE[0]}")"
	RUNTIME_EXECUTABLE_FILENAME="$(basename "${RUNTIME_EXECUTABLE_PATH}")"
	RUNTIME_EXECUTABLE_NAME="${RUNTIME_EXECUTABLE_FILENAME%.*}"
	RUNTIME_EXECUTABLE_DIRECTORY="$(dirname "${RUNTIME_EXECUTABLE_PATH}")"
	RUNTIME_COMMANDLINE_BASECOMMAND="${0}"
	declare -r\
		RUNTIME_EXECUTABLE_FILENAME\
		RUNTIME_EXECUTABLE_DIRECTORY\
		RUNTIME_EXECUTABLE_PATHABSOLUTE\
		RUNTIME_COMMANDLINE_BASECOMMAND
fi
declare -ar RUNTIME_COMMANDLINE_PARAMETERS=("${@}")

## init function: entrypoint of main program
## This function is called near the end of the file,
## with the script's command-line parameters as arguments
init(){
	if ! process_commandline_parameters; then
		printf --\
			'Error: %s: Invalid command-line parameters.\n'\
			"${FUNCNAME[0]}"\
			1>&2
		print_help
		exit 1
	fi

	local SHC_PREFIX_DIR="${RUNTIME_EXECUTABLE_DIRECTORY}"

	local \
		GIT_DIR="${RUNTIME_EXECUTABLE_DIRECTORY}/.git" \
		GIT_WORK_TREE="${RUNTIME_EXECUTABLE_DIRECTORY}"
	export GIT_DIR GIT_WORK_TREE

	# First clean the version string using clean filter
	printf --\
		'%s: Cleaning source files...\n'\
		"${RUNTIME_EXECUTABLE_NAME}"
	# shellcheck source=/dev/null
	source "${SHC_PREFIX_DIR}/SOFTWARE_DIRECTORY_CONFIGURATION.source"
	
	# Read lines seperated by '\0'
	# NOTE: 
	# - The '<()' part is a process substutution, its output is converted into a vertual file to be read via the '<' beforehand
	# - The "-d ''" means using the NUL(\0) character for line separation
	# - The 'IFS=' disables word separation and preserves all beginning and trailing whitespaces
	# - The '-a' option of `read` built-in can't be used because the lines are considers as LINEs, not WORDs in shell terminology, and `read` only read a LINE at once, programmer must fill the array with LINEs by them selves one by one.
	#
	# REFERENCE:
	# - delimiter - Reading null delimited strings through a Bash loop - Stack Overflow
	#   https://stackoverflow.com/questions/8677546/reading-null-delimited-strings-through-a-bash-loop
	# - linux - understanding shell script-- IFS, '' , ## - Stack Overflow
	#   https://stackoverflow.com/questions/25197146/understanding-shell-script-ifs?noredirect=1&lq=1
	declare -a templates
	while IFS= read -r -d '' template; do
		templates+=("${template}")
	done < <(find \
		"${SDC_SOURCE_CODE_DIR}" \
		-name '*.template.*bash' \
		-print0); unset template

	declare -i i; for (( i=0; i<"${#templates[@]}"; i+=1 )) ; do
		"${SDC_GIT_FILTERS_DIR}/clean-bash.manual-apply.bash" "${templates[i]}"
	done

	# Then set version string
	printf -- \
		'%s: Setting version string...\n'\
		"${RUNTIME_EXECUTABLE_NAME}"

	local version; version="$(determine_package_revision)"
	printf -- \
		'%s: DEBUG: Using "%s" as version.\n' \
		"${RUNTIME_EXECUTABLE_NAME}"\
		"${version}"
	sed\
		--in-place \
		"s/^## GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION=\"@@GBSST_VERSION@@\"$/## GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION=\"${version}\"/" \
		"${templates[@]}"

	# Workaround: Make Git don't consider tree is dirty even when it shouldn't because of the existing clean filter
	# Why does 'git status' ignore the .gitattributes clean filter? - Stack Overflow
	# http://stackoverflow.com/questions/19807979/why-does-git-status-ignore-the-gitattributes-clean-filter
	git add -u

	exit 0
}; declare -fr init

## This function requires GIT_DIR and GIT_WORK_TREE to be set and exported
determine_package_revision(){
	if [ ! -d "${GIT_DIR}" ]; then
		# FIXME: This is a source tarball without git repository, currently we don't know how to deal with this case(may requires smudge filter)
		printf 'unknown-%s' "$(basename "${GIT_WORK_TREE}")"
		return 0
	fi

	# Workaround: Make Git don't consider tree is dirty even when it shouldn't because of the existing clean filter
	# Why does 'git status' ignore the .gitattributes clean filter? - Stack Overflow
	# http://stackoverflow.com/questions/19807979/why-does-git-status-ignore-the-gitattributes-clean-filter
	git add -u

	if ! git rev-parse --verify HEAD &>/dev/null; then
		# git repository is newly initialized
		printf not-version-controlled
		return 0
	else
		# Best effort to describe the revision
		# version control - How do you achieve a numeric versioning scheme with Git? - Software Engineering Stack Exchange
 		# https://softwareengineering.stackexchange.com/questions/141973/how-do-you-achieve-a-numeric-versioning-scheme-with-git
		printf '%s' "$(git describe --tags --dirty --always)"
		return 0
	fi
}; declare -fr determine_package_revision

## Traps: Functions that are triggered when certain condition occurred
## Shell Builtin Commands » Bourne Shell Builtins » trap
trap_errexit(){
	printf 'An error occurred and the script is prematurely aborted\n' 1>&2
	return 0
}; declare -fr trap_errexit; trap trap_errexit ERR

trap_exit(){
	return 0
}; declare -fr trap_exit; trap trap_exit EXIT

trap_return(){
	local returning_function="${1}"

	printf 'DEBUG: %s: returning from %s\n' "${FUNCNAME[0]}" "${returning_function}" 1>&2
}; declare -fr trap_return

trap_interrupt(){
	printf '\n' # Separate previous output
	printf 'Recieved SIGINT, script is interrupted.' 1>&2
	return 1
}; declare -fr trap_interrupt; trap trap_interrupt INT

print_help(){
	printf 'Currently no help messages are available for this program\n' 1>&2
	return 0
}; declare -fr print_help;

process_commandline_parameters() {
	if [ "${#RUNTIME_COMMANDLINE_PARAMETERS[@]}" -eq 0 ]; then
		return 0
	fi

	# modifyable parameters for parsing by consuming
	local -a parameters=("${RUNTIME_COMMANDLINE_PARAMETERS[@]}")

	# Normally we won't want debug traces to appear during parameter parsing, so we  add this flag and defer it activation till returning(Y: Do debug)
	local enable_debug=N

	while true; do
		if [ "${#parameters[@]}" -eq 0 ]; then
			break
		else
			case "${parameters[0]}" in
				--help\
				|-h)
					print_help;
					exit 0
					;;
				--debug\
				|-d)
					enable_debug=Y
					;;
				*)
					printf 'ERROR: Unknown command-line argument "%s"\n' "${parameters[0]}" >&2
					return 1
					;;
			esac
			# shift array by 1 = unset 1st then repack
			unset 'parameters[0]'
			if [ "${#parameters[@]}" -ne 0 ]; then
				parameters=("${parameters[@]}")
			fi
		fi
	done

	if [ "${enable_debug}" = Y ]; then
		trap 'trap_return "${FUNCNAME[0]}"' RETURN
		set -o xtrace
	fi
	return 0
}; declare -fr process_commandline_parameters;

init "${@}"

## This script is based on the GNU Bash Shell Script Template project
## https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template
## and is based on the following version:
## GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="@@GBSST_VERSION@@"
## You may rebase your script to incorporate new features and fixes from the template