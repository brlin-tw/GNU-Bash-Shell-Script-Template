#!/usr/bin/env bash
# shellcheck disable=SC2034

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
	realpath; do
	if ! command -v "${required_command}" &>/dev/null; then
		runtime_dependency_checking_result=fail

		case "${required_command}" in
			basename\
			|dirname\
			|realpath)
				required_software='GNU Coreutils'
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
if [ -v "BASH_SOURCE[0]" ]; then
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

## Traps: Functions that are triggered when certain condition occurred
## Shell Builtin Commands » Bourne Shell Builtins » trap
trap_errexit(){
	printf 'An error occurred and the script is prematurely aborted\n' 1>&2
	return 0
}; declare -fr trap_errexit; trap trap_errexit ERR

trap_exit(){
	printf 'DEBUG: %s is leaving\n' "${RUNTIME_EXECUTABLE_FILENAME}" 1>&2
	if ! rm "${temp_file}"; then
		printf --\
			'%s: %s: Error: Unable to remove temporary file\n'\
			"${RUNTIME_EXECUTABLE_FILENAME}"\
			"${FUNCNAME[0]}"\
			1>&2
		exit 1
	fi
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
			unset "parameters[0]"
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

## init function: program entrypoint
init(){
	printf --\
		'DEBUG: %s called\n'\
		"${RUNTIME_EXECUTABLE_FILENAME}"\
		1>&2
	if ! check_runtime_dependencies; then
		exit 1
	fi

	declare -g temp_file
	temp_file="$(mktemp --tmpdir "${RUNTIME_EXECUTABLE_FILENAME}.tmp.XXXXXX")"

	# dump current stdin to temp_file
	cat >"${temp_file}"

	# undo version injection
	sed\
		--in-place\
		's/^## GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION=.*$/## GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="@@GBSST_VERSION@@"/'\
		"${temp_file}"

	# enforce coding style
	# Scope of "Flexible Software Installation Specification" project
	# shellcheck disable=SC1090
	if ! source "${RUNTIME_EXECUTABLE_DIRECTORY}"/PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY.source 2>/dev/null \
		|| [ ! -v PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY ]; then
		printf -- \
			'%s: Error: Unable to acquire installation prefix location\n' \
			"${RUNTIME_EXECUTABLE_FILENAME}" \
			1>&2
		exit 1
	fi

# 	SDC_GIT_FILTERS_DIR="${RUNTIME_EXECUTABLE_DIRECTORY}"
# 	# Scope of "Flexible Software Installation Specification" project
# 	# shellcheck disable=SC1090
# 	if ! source "${SDC_GIT_FILTERS_DIR}"/SOFTWARE_DIRECTORY_CONFIGURATION.source 2>/dev/null\
# 		|| [ ! -v SDC_CLEAN_FILTER_FOR_BASH_DIR ]; then
# 		printf -- \
# 			'%s: Error: Unable to acquire Clean Filter for GNU Bash Scripts directory\n' \
# 			"${RUNTIME_EXECUTABLE_FILENAME}" \
# 			1>&2
# 		exit 1
# 	fi
# 	unset exit_status
# 
# 	"${SDC_CLEAN_FILTER_FOR_BASH_DIR}/Clean Filter for GNU Bash Scripts.manual-apply.bash" "${temp_file}"

	# dump temp_file to stdout
	cat "${temp_file}"

	printf -- \
		'DEBUG: %s is done\n' \
		"${RUNTIME_EXECUTABLE_FILENAME}" \
		1>&2
	exit 0
}; declare -fr init

check_runtime_dependencies(){
	for a_command in sed python; do
		if ! command -v "${a_command}" &>/dev/null; then
			printf -- \
				'ERROR: %s command not found.\n' \
				"${a_command}"\
				1>&2
			return 1
		fi
	done
	return 0
}; declare -fr check_runtime_dependencies

init "${@}"