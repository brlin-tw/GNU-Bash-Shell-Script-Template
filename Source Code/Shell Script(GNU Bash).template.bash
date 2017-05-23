#!/usr/bin/env bash
#shellcheck disable=SC2034
# The above line will be here next to the shebang instead of below of "## Meta about This Program" due to ShellCheck <0.4.6's bug.  This should be moved after Ubuntu's provided version of ShellCheck <0.4.6 EoL'd.  Refer https://github.com/koalaman/shellcheck/issues/779 for more information.
# Comments prefixed by BASHDOC: are hints to specific GNU Bash Manual's section:
# https://www.gnu.org/software/bash/manual/

## META_PROGRAM_*: Metadata about This Program
## Fill in metadata about this program for reusing in the script and documenting purposes
## You may safely remove this entire section if you don't need it
### Program's name, by default it is determined in runtime according to the filename, set this variable to override the autodetection, default: ${RUNTIME_EXECUTABLE_NAME}(optional)
declare META_PROGRAM_NAME_OVERRIDE=""

### Program's identifier, program's name with character limitation exposed by platform(optional)
declare META_PROGRAM_IDENTIFIER=""

### Program's description, default(optional)
declare META_PROGRAM_DESCRIPTION=""

### Intellectual property license applied to this program(optional)
### Choose a License
### https://choosealicense.com/
declare META_PROGRAM_LICENSE=""

### Years since any fraction of copyright material is activated, indicates the year when copyright protection will be outdated(optional)
declare META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE=""

### Whether program should pause and expect user pressing enter when program ended, which is useful when launching scripts in GUI, which may undesirebly close the terminal emulator window when the script is exited and leaving user no chance to check execution result
### 0: Don't pause(default)
### 1: Pause
### This parameter is overridable, in case of command-line options like --interactive and --no-interactive
declare -i META_PROGRAM_PAUSE_BEFORE_EXIT="0"

## META_APPLICATION_*: Metadata about the application this program belongs to
## https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#meta_application_
## You may safely remove this entire section if you don't need it
### Human-readable name of application(optional)
declare META_APPLICATION_NAME=""

### Application's identifier, application's name with limitation posed by other software, default(not implemented): unnamed-application
declare META_APPLICATION_IDENTIFIER=""

### Developers' name of application(optional)
declare META_APPLICATION_DEVELOPER_NAME=""

### Application's official site URL(optional)
declare META_APPLICATION_SITE_URL=""

### Application's issue tracker, if there's any(optional)
declare META_APPLICATION_ISSUE_TRACKER_URL=""

### An action to let user get help from developer or other sources when error occurred
declare META_APPLICATION_SEEKING_HELP_OPTION="contact developer"

### The Software Directory Configuration this application uses, refer below section for more info
declare META_APPLICATION_INSTALL_STYLE="STANDALONE"

## META_RUNTIME_*: Runtime dependencies information for dependency checking
## You may safely remove this entire section if you don't need it
### Human-friendly runtime dependency name definition
declare -r META_RUNTIME_DEPENDENCIES_DESCRIPTION_GNU_COREUTILS="GNU Coreutils"

### These are the dependencies that the script foundation needs, and needs to be checked IMMEDIATELY
### BASHDOC: Bash Features - Arrays(associative array)
declare -Ar META_RUNTIME_DEPENDENCIES_CRITICAL=(
	["basename"]="${META_RUNTIME_DEPENDENCIES_DESCRIPTION_GNU_COREUTILS}"
	["realpath"]="${META_RUNTIME_DEPENDENCIES_DESCRIPTION_GNU_COREUTILS}"
)

### These are the dependencies that are used later and also checked later
declare -Ar META_RUNTIME_DEPENDENCIES=()

## Common constant definitions
declare -ir COMMON_RESULT_SUCCESS=0
declare -ir COMMON_RESULT_FAILURE=1
declare -ir COMMON_BOOLEAN_TRUE=0
declare -ir COMMON_BOOLEAN_FALSE=1

## Notes
### realpath's commandline option, `--strip` will be replaced in favor of `--no-symlinks` after April 2019(Ubuntu 14.04's Support EOL)

## Makes debuggers' life easier - Unofficial Bash Strict Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
## BASHDOC: Shell Builtin Commands - Modifying Shell Behavior - The Set Builtin
### Prematurely terminates the script on any command returning non-zero, append " || true"(BASHDOC: Basic Shell Features » Shell Commands » Lists of Commands) if the non-zero return value is rather intended to happen.  A trap on `ERR', if set, is executed before the shell exits.
set -o errexit

### If set, any trap on `ERR' is also inherited by shell functions, command substitutions, and commands executed in a subshell environment.
set -o errtrace

### If set, the return value of a pipeline(BASHDOC: Basic Shell Features » Shell Commands » Pipelines) is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
set -o pipefail

### Treat unset variables and parameters other than the special parameters `@' or `*' as an error when performing parameter expansion.  An error message will be written to the standard error, and a non-interactive shell will exit.
### NOTE: errexit will NOT be triggered by this condition as this is not a command error
### bash - Correct behavior of EXIT and ERR traps when using `set -eu` - Unix & Linux Stack Exchange
### https://unix.stackexchange.com/questions/208112/correct-behavior-of-exit-and-err-traps-when-using-set-eu
set -o nounset

## Traps
## Functions that will be triggered if certain condition met
## BASHDOC: Shell Builtin Commands » Bourne Shell Builtins(trap)
### Collect all information useful for debugging
meta_trap_err_print_debugging_info(){
	if [ ${#} -ne 3 ]; then
		printf "ERROR: %s: Wrong function argument quantity!\n" "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	local -ir line_error_location=${1}; shift # The line number that triggers the error
	local -r failing_command="${1}"; shift # The failing command
	local -ir failing_command_return_status=${1} # The failing command's return value

	# Don't print trace for printf commands
	set +o xtrace

	printf \
		"ERROR: %s has encountered an error and is ending prematurely, %s for support.\n"\
		"${META_PROGRAM_NAME_OVERRIDE:-${RUNTIME_EXECUTABLE_NAME:-This program}}"\
		"${META_APPLICATION_SEEKING_HELP_OPTION:-contact developer}"\
		1>&2

	printf "\n" # Separate paragraphs

	printf "Technical information:\n"
	printf "\n" # Separate list title and items
	printf "* The failing command is \"%s\"\n" "${failing_command}"
	printf "* Failing command's return status is %s\n" "${failing_command_return_status}"
	printf "* Intepreter info: GNU Bash v%s on %s platform\n" "${BASH_VERSION}" "${MACHTYPE}"
	printf "* Stacktrace:\n"
	declare -i level=0; while [ "${level}" -lt "${#FUNCNAME[@]}" ]; do
		if [ "${level}" -eq 0 ]; then
			printf "	%u. %s(%s:%u)\n"\
				"${level}"\
				"${FUNCNAME[${level}]}"\
				"${BASH_SOURCE[${level}]}"\
				"${line_error_location}"
		else
			printf "	%u. %s(%s:%u)\n"\
				"${level}"\
				"${FUNCNAME[${level}]}"\
				"${BASH_SOURCE[${level}]}"\
				"${BASH_LINENO[((${level} - 1))]}"
		fi
		((level = level + 1))
	done; unset level
	printf "\n" # Separate list and further content

	return "${COMMON_RESULT_SUCCESS}"
}; declare -rf meta_trap_err_print_debugging_info

meta_trap_err(){
	if [ ${#} -ne 3 ]; then
		printf "ERROR: %s: Wrong function argument quantity!\n" "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	local -ir line_error_location=${1}; shift # The line number that triggers the error
	local -r failing_command="${1}"; shift # The failing command
	local -ir failing_command_return_status=${1} # The failing command's return value

	meta_trap_err_print_debugging_info "${line_error_location}" "${failing_command}" "${failing_command_return_status}"

	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_trap_err

# Variable is expanded when trap triggered, not now
#shellcheck disable=SC2016
declare -r TRAP_ERREXIT_ARG='meta_trap_err ${LINENO} "${BASH_COMMAND}" ${?}'
# We separate the arguments to TRAP_ERREXIT_ARG, so it should be expand here
#shellcheck disable=SC2064
trap "${TRAP_ERREXIT_ARG}" ERR

meta_util_is_parameter_set_and_not_null(){
	if [ "${#}" -ne 1 ]; then
		printf "%s: Error: argument quantity illegal\n" "${FUNCNAME[0]}" 1>&2
		exit "${COMMON_RESULT_FAILURE}"
	fi

	declare -n name_reference
	name_reference="${1}"

	if [ ! -v name_reference ]; then
		return "${COMMON_BOOLEAN_FALSE}"
	else
		if [ -z "${name_reference}" ]; then
			return "${COMMON_BOOLEAN_FALSE}"
		else
			return "${COMMON_BOOLEAN_TRUE}"
		fi
	fi
}; declare -fr meta_util_is_parameter_set_and_not_null

meta_util_make_parameter_readonly_if_not_null_otherwise_unset(){
	if [ "${#}" -eq 0 ]; then
		printf "%s: Error: argument quantity illegal\n" "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	for parameter_name in "${@}"; do
		if [ -v parameter_name ]; then
			if [ -z "${parameter_name}" ]; then
				unset "${parameter_name}"
			else
				declare -r "${parameter_name}"
			fi
		fi
	done; unset parameter_name

	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_make_parameter_readonly_if_not_null_otherwise_unset

### Introduce the program and software at leaving
meta_trap_exit_print_application_information(){
	# No need to debug this area, keep output simple
	set +o xtrace

	# Only print the line if:
	#
	# * There's info to be print
	# * Pausing program is desired(META_PROGRAM_PAUSE_BEFORE_EXIT=1)
	#
	# ...cause it's kinda stupid for a trailing line at end-of-program-output
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_NAME\
		|| meta_util_is_parameter_set_and_not_null META_APPLICATION_DEVELOPER_NAME\
		|| meta_util_is_parameter_set_and_not_null META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE\
		|| meta_util_is_parameter_set_and_not_null META_PROGRAM_LICENSE\
		|| meta_util_is_parameter_set_and_not_null META_APPLICATION_LICENSE\
		|| meta_util_is_parameter_set_and_not_null META_APPLICATION_SITE_URL\
		|| meta_util_is_parameter_set_and_not_null META_APPLICATION_ISSUE_TRACKER_URL\
		|| (\
			meta_util_is_parameter_set_and_not_null META_PROGRAM_PAUSE_BEFORE_EXIT\
			&& [ "${META_PROGRAM_PAUSE_BEFORE_EXIT}" -eq 1 ] \
		); then
		printf -- "------------------------------------\n"
	fi
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_NAME; then
		printf "%s\n" "${META_APPLICATION_NAME}"
	fi
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_DEVELOPER_NAME; then
		printf "%s et. al." "${META_APPLICATION_DEVELOPER_NAME}"
		if [ -n "${META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE}" ]; then
			printf " " # Separator with ${META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE}
		else
			printf "\n"
		fi
	fi
	if meta_util_is_parameter_set_and_not_null META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE; then
		printf "© %s\n" "${META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE}"
	fi
	if meta_util_is_parameter_set_and_not_null META_PROGRAM_LICENSE; then
		printf "Intellectual Property License: %s\n" "${META_PROGRAM_LICENSE}"
	elif meta_util_is_parameter_set_and_not_null META_APPLICATION_LICENSE; then
		printf "Intellectual Property License: %s\n" "${META_APPLICATION_LICENSE}"
	fi
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_SITE_URL; then
		printf "Official Website: %s\n" "${META_APPLICATION_SITE_URL}"
	fi
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_ISSUE_TRACKER_URL; then
		printf "Issue Tracker: %s\n" "${META_APPLICATION_ISSUE_TRACKER_URL}"
	fi
	if meta_util_is_parameter_set_and_not_null META_PROGRAM_PAUSE_BEFORE_EXIT\
		&& [ "${META_PROGRAM_PAUSE_BEFORE_EXIT}" -eq 1 ]; then
		local enter_holder

		printf "Press ENTER to quit the program.\n"
		read -r enter_holder
	fi
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_trap_exit_print_application_information

meta_trap_exit(){
	meta_trap_exit_print_application_information
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_trap_exit
trap 'meta_trap_exit' EXIT

## Unset all null META_PROGRAM_* parameters and readonly all others
meta_util_make_parameter_readonly_if_not_null_otherwise_unset\
	META_PROGRAM_NAME_OVERRIDE\
	META_PROGRAM_IDENTIFIER\
	META_PROGRAM_DESCRIPTION\
	META_PROGRAM_LICENSE\
	META_PROGRAM_PAUSE_BEFORE_EXIT\
	META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE

## Workarounds
### Temporarily disable errexit
meta_workaround_errexit_setup() {
	if [ ${#} -ne 1 ]; then
		printf "ERROR: %s: Wrong function argument quantity!\n" "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi
	local option=${1} # on: enable errexit; off: disable errexit

	if [ "${option}" == "on" ]; then
		set -o errexit
	elif [ "${option}" == "off" ]; then
		set +o errexit
	else
		printf "ERROR: %s: Wrong function argument format!\n" "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_workaround_errexit_setup

meta_util_declare_global_parameters(){
	if [ "${#}" -eq 0 ]; then
		printf "%s: Error: Function parameter quantity illegal\n" "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	for parameter_name in "${@}"; do
		declare -g "${parameter_name}"
	done; unset parameter_name
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_declare_global_parameters

meta_util_unset_global_parameters_if_null(){
	if [ "${#}" -eq 0 ]; then
		printf "%s: Error: Function parameter quantity illegal\n" "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	for parameter_name in "${@}"; do
		if [ -z "${parameter_name}" ]; then
			unset "${parameter_name}"
		fi
	done; parameter_name
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_unset_global_parameters_if_null

## Runtime Dependencies Checking
## shell - Check if a program exists from a Bash script - Stack Overflow
## http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
meta_checkRuntimeDependencies() {
	local -n array_ref="${1}"

	if [ "${#array_ref[@]}" -eq 0 ]; then
		return "${COMMON_RESULT_SUCCESS}"
	else
		declare -i exit_status; for a_command in "${!array_ref[@]}"; do

			meta_workaround_errexit_setup off
			command -v "${a_command}" >/dev/null 2>&1
			exit_status="${?}"
			meta_workaround_errexit_setup on
			if [ ${exit_status} -ne 0 ]; then
				printf "ERROR: Command \"%s\" not found, program cannot continue like this.\n" "${a_command}" 1>&2
				printf "ERROR: Please make sure %s is installed and it's executable path is in your operating system's executable search path.\n" "${array_ref["${a_command}"]}" >&2
				printf "Goodbye.\n"
				exit "${COMMON_RESULT_FAILURE}"
			fi
		done; unset a_command exit_status
		return "${COMMON_RESULT_SUCCESS}"
	fi
}; declare -fr meta_checkRuntimeDependencies
if meta_util_is_parameter_set_and_not_null META_RUNTIME_DEPENDENCIES_CRITICAL; then
	meta_checkRuntimeDependencies META_RUNTIME_DEPENDENCIES_CRITICAL
fi
if meta_util_is_parameter_set_and_not_null META_RUNTIME_DEPENDENCIES; then
	meta_checkRuntimeDependencies META_RUNTIME_DEPENDENCIES
fi

## RUNTIME_*: Info acquired from runtime environment
## --------------------------------------
## https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#runtime-determined-settings
## The following variables defines the environment aspects that can only be detected in runtime, we use RUNTIME_ namespace for these variables.
## These variables will not be set if technically not available(e.g. the program is provided to intepreter/etc. via stdin), or just not implemented yet

### The running executable's filename(without the underlying path)
declare RUNTIME_EXECUTABLE_FILENAME

### The running program's filename(like RUNTIME_EXECUTABLE_FILENAME, but without the filename extension
### (default: script's filename without extension, META_PROGRAM_NAME_OVERRIDE if set
declare RUNTIME_EXECUTABLE_NAME

### The path of the directory that the executable reside in
declare RUNTIME_EXECUTABLE_DIRECTORY

### Executable's absolute path(location + filename)
declare RUNTIME_EXECUTABLE_PATH_ABSOLUTE

### Executable's relative path(to current working directory)
declare RUNTIME_EXECUTABLE_PATH_RELATIVE

### Runtime environment's executable search path priority array
declare -a RUNTIME_PATH_DIRECTORIES
IFS=':' read -r -a RUNTIME_PATH_DIRECTORIES <<< "${PATH}" || true # Without this `read` will return 1
declare -r RUNTIME_PATH_DIRECTORIES

### The guessed user input base command (without the arguments), this is handy when showing help, where the proper base command can be displayed(default: auto-detect, unset if not available)
### If ${RUNTIME_EXECUTABLE_DIRECTORY} is in ${RUNTIME_PATH_DIRECTORIES}, this would be ${RUNTIME_EXECUTABLE_FILENAME}, if not this would be ./${RUNTIME_EXECUTABLE_PATH_RELATIVE}
declare RUNTIME_COMMAND_BASE

if [ ! -v BASH_SOURCE ]; then
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_INSTALL_STYLE\
		&& [ "${META_APPLICATION_INSTALL_STYLE}" == "SHC" ]; then
		printf "GNU Bash Shell Script Template: Error: META_APPLICATION_INSTALL_STYLE set to SHC, but is not possible due to unknown script location, make sure the program is not run as intepreter's standard input stream.\n" 1>&2
		exit "${COMMON_RESULT_FAILURE}"
	fi
	unset \
		RUNTIME_EXECUTABLE_FILENAME\
		RUNTIME_EXECUTABLE_NAME\
		RUNTIME_EXECUTABLE_DIRECTORY\
		RUNTIME_EXECUTABLE_PATH_ABSOLUTE\
		RUNTIME_EXECUTABLE_PATH_RELATIVE
else
	# BashFAQ/How do I determine the location of my script? I want to read some config files from the same place. - Greg's Wiki
	# http://mywiki.wooledge.org/BashFAQ/028
	RUNTIME_EXECUTABLE_FILENAME="$(basename "${BASH_SOURCE[0]}")"
	declare -r RUNTIME_EXECUTABLE_FILENAME
	RUNTIME_EXECUTABLE_NAME="${META_PROGRAM_NAME_OVERRIDE:-${RUNTIME_EXECUTABLE_FILENAME%.*}}"
	RUNTIME_EXECUTABLE_DIRECTORY="$(dirname "$(realpath --strip "${0}")")"
	declare -r RUNTIME_EXECUTABLE_DIRECTORY
	declare -r RUNTIME_EXECUTABLE_PATH_ABSOLUTE="${RUNTIME_EXECUTABLE_DIRECTORY}/${RUNTIME_EXECUTABLE_FILENAME}"
	declare -r RUNTIME_EXECUTABLE_PATH_RELATIVE="${0}"

	for pathdir in "${RUNTIME_PATH_DIRECTORIES[@]}"; do
		# It is possible that the pathdir is invalid (e.g. wrong configuration or misuse ":" as path content which is not allowed in PATH), simply ignore it
		if [ ! -d "${pathdir}" ]; then
			continue
		fi

		# If executable is in shell's executable search path, consider the command is the executable's filename
		# Also do so if the resolved path matches(symbolic linked)
		resolved_pathdir="$(realpath "${pathdir}")"

		if [ "${RUNTIME_EXECUTABLE_DIRECTORY}" == "${pathdir}" ]\
			|| [ "${RUNTIME_EXECUTABLE_DIRECTORY}" == "${resolved_pathdir}" ]; then
			RUNTIME_COMMAND_BASE="${RUNTIME_EXECUTABLE_FILENAME}"
			break
		fi
	done; unset pathdir resolved_pathdir
	declare -r RUNTIME_COMMAND_BASE="${RUNTIME_COMMAND_BASE:-${0}}"
fi

### Collect command-line arguments
declare -ir RUNTIME_COMMANDLINE_ARGUMENT_QUANTITY="${#}"
if [ "${RUNTIME_COMMANDLINE_ARGUMENT_QUANTITY}" -ne 0 ]; then
	declare -a RUNTIME_COMMANDLINE_ARGUMENT_LIST
	RUNTIME_COMMANDLINE_ARGUMENT_LIST=("${@:1}")
	declare -r RUNTIME_COMMANDLINE_ARGUMENT_LIST
fi

## Software Directories Configuration(S.D.C.)
## This section defines and determines the directories used by the software
## REFER: https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#software-directories-configurationsdc
meta_util_declare_global_parameters\
	SDC_EXECUTABLES_DIR\
	SDC_LIBRARIES_DIR\
	SDC_SHARED_RES_DIR\
	SDC_I18N_DATA_DIR\
	SDC_SETTINGS_DIR\
	SDC_TEMP_DIR

if meta_util_is_parameter_set_and_not_null META_APPLICATION_INSTALL_STYLE; then
	case "${META_APPLICATION_INSTALL_STYLE}" in
		FHS)
			# Filesystem Hierarchy Standard(F.H.S.) configuration paths
			# http://refspecs.linuxfoundation.org/FHS_3.0/fhs
			## Software installation directory prefix, should be overridable by configure/install script
			declare -r FHS_PREFIX_DIR="/usr/local"

			declare -r SDC_EXECUTABLES_DIR="${FHS_PREFIX_DIR}/bin"
			declare -r SDC_LIBRARIES_DIR="${FHS_PREFIX_DIR}/lib"
			declare -r SDC_I18N_DATA_DIR="${FHS_PREFIX_DIR}/share/locale"
			if [ -n "${META_APPLICATION_IDENTIFIER}" ]; then
				declare -r SDC_SHARED_RES_DIR="${FHS_PREFIX_DIR}/share/${META_APPLICATION_IDENTIFIER}"
				declare -r SDC_SETTINGS_DIR="/etc/${META_APPLICATION_IDENTIFIER}"
				declare -r SDC_TEMP_DIR="/tmp/${META_APPLICATION_IDENTIFIER}"
			else
				unset\
					SDC_SHARED_RES_DIR\
					SDC_SETTINGS_DIR\
					SDC_TEMP_DIR
			fi
			;;
		SHC)
			# Setup Self-contained Hierarchy Configuration(S.H.C.)
			# https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#self-contained-hierarchy-configurationshc
			# https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#path_to_software_installation_prefix_directorysourceshc-only
			# https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#shc_prefix_dirshc-only
			if [ -f "${RUNTIME_EXECUTABLE_DIRECTORY}/APPLICATION_METADATA.source" ]; then
				SHC_PREFIX_DIR="${RUNTIME_EXECUTABLE_DIRECTORY}"
			else
				if [ ! -f "${RUNTIME_EXECUTABLE_DIRECTORY}/PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY.source" ]; then
					printf "GNU Bash Script Template: Error: PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY.source not exist, can't setup Self-contained Hierarchy Configuration.\n" 1>&2
					exit 1
				fi
				# Scope of Flexible Software Installation Specification
				# shellcheck disable=SC1090,SC1091
				source "${RUNTIME_EXECUTABLE_DIRECTORY}/PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY.source"
				if ! meta_util_is_parameter_set_and_not_null PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY; then
					printf "GNU Bash Script Template: Error: PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY not defined, can't setup Self-contained Hierarchy Configuration.\n" 1>&2
					exit 1
				fi
				SHC_PREFIX_DIR="$(realpath --strip "${RUNTIME_EXECUTABLE_DIRECTORY}/${PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY}")"
			fi
			declare -r SHC_PREFIX_DIR

			# Read external software directory configuration(S.D.C.)
			# https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#software-directories-configurationsdc
			# Scope of Flexible Software Installation Specification
			# shellcheck disable=SC1090,SC1091
			source "${SHC_PREFIX_DIR}/SOFTWARE_DIRECTORY_CONFIGURATION.source" 2>/dev/null || true
			meta_util_unset_global_parameters_if_null\
				SDC_EXECUTABLES_DIR\
				SDC_LIBRARIES_DIR\
				SDC_SHARED_RES_DIR\
				SDC_I18N_DATA_DIR\
				SDC_SETTINGS_DIR\
				SDC_TEMP_DIR
			;;
		STANDALONE)
			# Standalone Configuration
			# This program don't rely on any directories, make no attempt defining them
			unset SDC_EXECUTABLES_DIR SDC_LIBRARIES_DIR SDC_SHARED_RES_DIR SDC_I18N_DATA_DIR SDC_SETTINGS_DIR SDC_TEMP_DIR
			;;
		*)
			printf "Error: Unknown software directories configuration, program can not continue.\n" 1>&2
			exit 1
			;;
	esac
fi

meta_util_make_parameter_readonly_if_not_null_otherwise_unset\
	SDC_EXECUTABLES_DIR\
	SDC_LIBRARIES_DIR\
	SDC_SHARED_RES_DIR\
	SDC_I18N_DATA_DIR\
	SDC_SETTINGS_DIR\
	SDC_TEMP_DIR

## Setup application metadata
if meta_util_is_parameter_set_and_not_null META_APPLICATION_INSTALL_STYLE; then
	case "${META_APPLICATION_INSTALL_STYLE}" in
		FHS)
			if [ -v "${SDC_SHARED_RES_DIR}" ] && [ -n "${SDC_SHARED_RES_DIR}" ]; then
				:
			else
				# Scope of external project
				# shellcheck disable=SC1090,SC1091
				source "${SDC_SHARED_RES_DIR}/APPLICATION_METADATA.source" 2>/dev/null || true
			fi
			;;
		SHC)
			# Scope of external project
			# shellcheck disable=SC1090,SC1091
			source "${SHC_PREFIX_DIR}/APPLICATION_METADATA.source" 2>/dev/null || true
			;;
		STANDALONE)
			: # metadata can only be set from header
			;;
		*)
			printf "Error: Unknown META_APPLICATION_INSTALL_STYLE, program can not continue.\n" 1>&2
			exit 1
			;;
	esac
fi

meta_util_make_parameter_readonly_if_not_null_otherwise_unset\
	META_APPLICATION_NAME\
	META_APPLICATION_DEVELOPER_NAME\
	META_APPLICATION_LICENSE\
	META_APPLICATION_SITE_URL\
	META_APPLICATION_ISSUE_TRACKER_URL\
	META_APPLICATION_SEEKING_HELP_OPTION

## Program's Commandline Options Definitions
declare -r COMMANDLINE_OPTION_DISPLAY_HELP_LONG="--help"
declare -r COMMANDLINE_OPTION_DISPLAY_HELP_SHORT="-h"
declare -r COMMANDLINE_OPTION_DISPLAY_HELP_DESCRIPTION="Display help message"

declare -r COMMANDLINE_OPTION_ENABLE_DEBUGGING_LONG="--debug"
declare -r COMMANDLINE_OPTION_ENABLE_DEBUGGING_SHORT="-d"
declare -r COMMANDLINE_OPTION_ENABLE_DEBUGGING_DESCRIPTION="Enable debug mode"

## Program Configuration Variables
declare -i global_just_show_help="${COMMON_BOOLEAN_FALSE}"
declare -i global_enable_debugging="${COMMON_BOOLEAN_FALSE}"

## Drop first element from array and shift remaining elements 1 element backward
meta_util_array_shift(){
	local -n array_ref="${1}"

	# Check input validity
	# When -v test is used against a nameref, the name is tested
	if [ "${#array_ref[@]}" -eq 0 ]; then
		printf "ERROR: array is empty!\n" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	# Unset the 1st element
	unset "array_ref[0]"

	# Repack array if element still available in array
	if [ "${#array_ref[@]}" -ne 0 ]; then
		array_ref=("${array_ref[@]}")
	fi

	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_array_shift

## Understand what argument is in the command, and set the global variables accordingly.
meta_processCommandlineArguments() {
	if [ "${RUNTIME_COMMANDLINE_ARGUMENT_QUANTITY}" -eq 0 ]; then
		return "${COMMON_RESULT_SUCCESS}"
	else
		local -a arguments=("${RUNTIME_COMMANDLINE_ARGUMENT_LIST[@]}")

		while :; do
			# BREAK if no arguments left
			if [ ! -v arguments ]; then
				break
			else
				case "${arguments[0]}" in
					"${COMMANDLINE_OPTION_DISPLAY_HELP_LONG}"\
					|"${COMMANDLINE_OPTION_DISPLAY_HELP_SHORT}")
						global_just_show_help="${COMMON_BOOLEAN_TRUE}"
						;;
					"${COMMANDLINE_OPTION_ENABLE_DEBUGGING_LONG}"\
					|"${COMMANDLINE_OPTION_ENABLE_DEBUGGING_SHORT}")
						global_enable_debugging="${COMMON_BOOLEAN_TRUE}"
						;;
					*)
						printf "ERROR: Unknown command-line argument \"%s\"\n" "${arguments[0]}" >&2
						return ${COMMON_RESULT_FAILURE}
						;;
				esac
				meta_util_array_shift arguments
			fi
		done
	fi

	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_processCommandlineArguments

## Print single segment of commandline option help
meta_util_printSingleCommandlineOptionHelp(){
	if [ "${#}" -ne 3 ] && [ "${#}" -ne 4 ]; then
		printf "ERROR: %s: Wrong parameter quantity!\n" "${FUNCNAME[0]}" >&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	local description="${1}"; shift # Option description
	local long_option="${1}"; shift # The long version of option
	local short_option="${1}"; shift # The short version of option
	declare -r description long_option short_option

	if [ "${#}" -ne 0 ]; then
		local current_value="${1}"; shift # Current value of option, if option has value
		declare -r current_value
	fi

	printf "### %s / %s ###\n" "${long_option}" "${short_option}"
	printf "%s\n" "${description}"

	if [ -v current_value ]; then
		printf "Current value: %s\n" "${current_value}"
	fi

	printf "\n" # Separate with next option(or next heading)
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_printSingleCommandlineOptionHelp

## Print help message whenever:
##   * User requests it
##   * An command syntax error has detected
meta_printHelpMessage(){
	printf "# %s #\n" "${RUNTIME_EXECUTABLE_NAME}"

	if meta_util_is_parameter_set_and_not_null META_PROGRAM_DESCRIPTION; then
		printf "%s\n" "${META_PROGRAM_DESCRIPTION}"
		printf "\n"
	fi

	printf "## Usage ##\n"
	printf "\t%s (Command-line Options)\n" "${RUNTIME_COMMAND_BASE}"
	printf "\n"
	printf "## Command-line Options ##\n"
	meta_util_printSingleCommandlineOptionHelp "${COMMANDLINE_OPTION_DISPLAY_HELP_DESCRIPTION}" "${COMMANDLINE_OPTION_DISPLAY_HELP_LONG}" "${COMMANDLINE_OPTION_DISPLAY_HELP_SHORT}"
	meta_util_printSingleCommandlineOptionHelp "${COMMANDLINE_OPTION_ENABLE_DEBUGGING_DESCRIPTION}" "${COMMANDLINE_OPTION_ENABLE_DEBUGGING_LONG}" "${COMMANDLINE_OPTION_ENABLE_DEBUGGING_SHORT}"
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_printHelpMessage

## Defensive Bash Programming - init function, program's entry point
## http://www.kfirlavi.com/blog/2012/11/14/defensive-bash-programming/
init() {
	if ! meta_processCommandlineArguments; then
		meta_printHelpMessage
		exit "${COMMON_RESULT_FAILURE}"
	fi

	# Secure configuration variables by marking them readonly
	declare -gr \
		global_just_show_help\
		global_enable_debugging

	if [ "${global_enable_debugging}" -eq "${COMMON_BOOLEAN_TRUE}" ]; then
		set -o xtrace
	fi
	if [ "${global_just_show_help}" -eq "${COMMON_BOOLEAN_TRUE}" ]; then
		meta_printHelpMessage
		exit "${COMMON_RESULT_SUCCESS}"
	fi

	exit "${COMMON_RESULT_SUCCESS}"
}; declare -fr init
init

## This script is based on the GNU Bash Shell Script Template project
## https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template
## and is based on the following version:
declare -r META_BASED_ON_GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="@@TEMPLATE_VERSION@@"
## You may rebase your script to incorporate new features and fixes from the template

## This script is comforming to Flexible Software Installation Specification
## https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification
## and is based on the following version: v1.5.0