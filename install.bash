#!/usr/bin/env bash
# shellcheck disable=SC2034

## ############ META_PROGRAM_*: Metadata about This Program ###################
## Fill in metadata about this program for reusing in the script and documenting purposes
## You may safely remove this entire section if you don't need it
### Program's name, by default it is determined in runtime according to the filename, set this variable to override the autodetection, default: ${RUNTIME_EXECUTABLE_NAME}(optional)
declare META_PROGRAM_NAME_OVERRIDE='「GNU Bash Shell Script 範本」應用安裝程式'

### Program's identifier, program's name with character limitation exposed by platform(optional)
declare META_PROGRAM_IDENTIFIER=''

### Program's description, default(optional)
declare META_PROGRAM_DESCRIPTION=''

### Intellectual property license applied to this program(optional)
declare META_PROGRAM_LICENSE='GPLv3+'

### Years since any fraction of copyright material is activated, indicates the year when copyright protection will be outdated(optional)
declare META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE='2018'

### Whether program should pause and expect user pressing enter when program ended, which is useful when launching scripts in GUI, which may undesirebly close the terminal emulator window when the script is exited and leaving user no chance to check execution result
### 0: Don't pause(default)
### 1: Pause
### This parameter is overridable, in case of command-line options like --interactive and --no-interactive
declare -i META_PROGRAM_PAUSE_BEFORE_EXIT=0
## ######################## End of META_PROGRAM_* #############################

## META_APPLICATION_*: Metadata about the application this program belongs to
## https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#meta_application_
## You may safely remove this entire section if you don't need it
### Application's identifier, application's name with limitation posed by other software, default(not implemented): unnamed-application
declare -r META_APPLICATION_IDENTIFIER="gnu-bash-shell-script-template"

### The Software Directory Configuration this application uses, refer below section for more info
declare META_APPLICATION_INSTALL_STYLE=SHC
## ####################### End of META_APPLICATION_* ##########################

## META_RUNTIME_DEPENDENCIES: Runtime dependencies information for dependency checking
## You may safely remove this entire section if you don't need it
### Human-friendly runtime dependency name definition
declare -r META_RUNTIME_DEPENDENCIES_DESCRIPTION_GNU_COREUTILS='GNU Coreutils'

### These are the dependencies that the script foundation needs, and needs to be checked IMMEDIATELY
### BASHDOC: Bash Features - Arrays(associative array)
declare -Ar META_RUNTIME_DEPENDENCIES_CRITICAL=(
	[basename]="${META_RUNTIME_DEPENDENCIES_DESCRIPTION_GNU_COREUTILS}"
	[realpath]="${META_RUNTIME_DEPENDENCIES_DESCRIPTION_GNU_COREUTILS}"
)

### These are the dependencies that are used later and also checked later
declare -Ar META_RUNTIME_DEPENDENCIES=(
	["cp"]="${META_RUNTIME_DEPENDENCIES_DESCRIPTION_GNU_COREUTILS}"
	["tr"]="${META_RUNTIME_DEPENDENCIES_DESCRIPTION_GNU_COREUTILS}"
)

## #################### End of META_RUNTIME_DEPENDENCIES ######################

### Program's Commandline Options Definitions
declare -r COMMANDLINE_OPTION_DISPLAY_HELP_LONG=--help
declare -r COMMANDLINE_OPTION_DISPLAY_HELP_SHORT=-h
declare -r COMMANDLINE_OPTION_DISPLAY_HELP_DESCRIPTION='Display help message'

declare -r COMMANDLINE_OPTION_ENABLE_DEBUGGING_LONG=--debug
declare -r COMMANDLINE_OPTION_ENABLE_DEBUGGING_SHORT=-d
declare -r COMMANDLINE_OPTION_ENABLE_DEBUGGING_DESCRIPTION='Enable debug mode'

declare -r COMMANDLINE_OPTION_JUST_UNINSTALL_LONG='--uninstall'
declare -r COMMANDLINE_OPTION_JUST_UNINSTALL_SHORT='-u'
declare -r COMMANDLINE_OPTION_jUST_UNINSTALL_DESCRIPTION='Uninstall the software\nBy default the installer will install the software after removing previous installation, this option inhibits it'

## init function: the main program's entry point
## This function is called from the end of this file,
## with the command-line parameters as it's arguments
init() {
	local -i just_uninstall="${COMMON_BOOLEAN_FALSE}"

	if ! meta_processCommandlineParameters\
			just_uninstall; then
		meta_printHelpMessage
		exit "${COMMON_RESULT_FAILURE}"
	fi

	# NOTE: We've done it in build script, but let's just do it again anyway to avoid forgetting to run build before install
	printf -- \
		'Setting product version string...'
	"${SHC_PREFIX_DIR}"/set-script-version.bash && printf 'done.\n'

	if ! determine_install_directory; then
		printf -- \
			'錯誤：無法判斷安裝目錄。安裝程式無法繼續運行\n' \
			1>&2
		exit "${COMMON_RESULT_FAILURE}"
	else
		printf -- \
			'將會安裝到：%s\n' \
			"${global_install_directory}"
		printf '\n'
	fi

	remove_old_installation
	if [ "${just_uninstall}" -eq "${COMMON_BOOLEAN_TRUE}" ]; then
		printf -- \
			'已解除安裝軟體\n'
		exit "${COMMON_RESULT_SUCCESS}"
	fi

	printf -- \
		'正在安裝範本檔案……\n'
	cp \
		--force \
		--verbose \
		"${SDC_SOURCE_CODE_DIR}"/*.bash \
		"${XDG_TEMPLATES_DIR}"
	printf '\n' # Seperate output from different operations

	while :; do
		printf -- \
			'請問是否安裝 KDE 所需的範本設定（警告：會造成 GNOME Files 等應用軟體中出現非預期的範本項目）(y/N)？'
		read -r answer

		if [ -z "${answer}" ]; then
			break
		else
			# lowercasewize
			answer="$(
				printf -- \
					'%s'\
					"${answer}"\
					| tr '[:upper:]' '[:lower:]'\
			)"

			if [ "${answer}" != n ] && [ "${answer}" != y ]; then
				# wrong format, re-ask
				continue
			elif [ "${answer}" == n ]; then
				break
			else
				printf '正在設定適用於 KDE 的範本……\n'
				cp \
					--force \
					--verbose \
					"${SDC_SOURCE_CODE_DIR}"/*.bash \
					"${HOME}/.local/share/templates"
				cp \
					--force \
					--verbose \
					"${SDC_KDE_TEMPLATE_SETUP_DIR}"/*.desktop \
					"${HOME}/.local/share/templates"
				break
			fi
		fi
	done; unset answer

	printf '已完成安裝。\n'

	exit "${COMMON_RESULT_SUCCESS}"
}; declare -fr init

## Attempt to remove old installation files
remove_old_installation(){
	printf '正在清除過去安裝範本（如果有的話）……\n'
	rm --verbose --force "${XDG_TEMPLATES_DIR}"/*.bash* || true
	printf '完成\n'

	printf '\n' # Additional blank line for separating output
	return "${COMMON_RESULT_SUCCESS}"
}
readonly -f remove_old_installation

determine_install_directory(){
	# For $XDG_TEMPLATES_DIR
	if [ -f "${HOME}"/.config/user-dirs.dirs ];then
		# external file, disable check
		#shellcheck disable=SC1090
		source "${HOME}"/.config/user-dirs.dirs

		if [ -v XDG_TEMPLATES_DIR ]; then
			global_install_directory="${XDG_TEMPLATES_DIR}"
			return "${COMMON_RESULT_SUCCESS}"
		fi
	fi

	printf -- \
		'%s - 警告 - 安裝程式找不到 user-dirs 設定，汰退到預設目錄\n' \
		"${FUNCNAME[0]}"

	if [ ! -d "${HOME}"/Templates ]; then
		return "${COMMON_RESULT_FAILURE}"
	else
		global_install_directory="${HOME}"/Templates
	fi

}; readonly -f determine_install_directory

## ##################### Start of GBSST Support Code ##########################
## The following section are GNU Bash Shell Script's support code, you may
## remove the entire section if you want, just leave the last init call
declare -r GBSS_NAME='GNU Bash Shell Script Template'

### Common constant definitions
declare -ir COMMON_RESULT_SUCCESS=0
declare -ir COMMON_RESULT_FAILURE=1
declare -ir COMMON_BOOLEAN_TRUE=0
declare -ir COMMON_BOOLEAN_FALSE=1

### NOTE: realpath's commandline option, `--strip` will be replaced in favor of `--no-symlinks` after April 2019(Ubuntu 14.04's Support EOL)

### Makes debuggers' life easier - Unofficial Bash Strict Mode
### http://redsymbol.net/articles/unofficial-bash-strict-mode/
### BASHDOC: Shell Builtin Commands - Modifying Shell Behavior - The Set Builtin
#### Prematurely terminates the script on any command returning non-zero, append " || true"(BASHDOC: Basic Shell Features » Shell Commands » Lists of Commands) if the non-zero return value is rather intended to happen.  A trap on `ERR', if set, is executed before the shell exits.
set -o errexit

#### If set, any trap on `ERR' is also inherited by shell functions, command substitutions, and commands executed in a subshell environment.
set -o errtrace

#### If set, the return value of a pipeline(BASHDOC: Basic Shell Features » Shell Commands » Pipelines) is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands in the pipeline exit successfully.
set -o pipefail

#### Treat unset variables and parameters other than the special parameters `@' or `*' as an error when performing parameter expansion.  An error message will be written to the standard error, and a non-interactive shell will exit.
#### NOTE: errexit will NOT be triggered by this condition as this is not a command error
#### bash - Correct behavior of EXIT and ERR traps when using `set -eu` - Unix & Linux Stack Exchange
#### https://unix.stackexchange.com/questions/208112/correct-behavior-of-exit-and-err-traps-when-using-set-eu
set -o nounset

### Traps
### Functions that will be triggered if certain condition met
### BASHDOC: Shell Builtin Commands » Bourne Shell Builtins(trap)
meta_setup_traps(){
	# Variable is expanded when trap triggered, not now
	# shellcheck disable=SC2016
	declare -gr TRAP_ERREXIT_ARG='meta_trap_err ${LINENO} "${BASH_COMMAND}" ${?} ${FUNCNAME[0]}'
	# We separate the arguments to TRAP_ERREXIT_ARG, so it should be expand here
	# shellcheck disable=SC2064
	trap "${TRAP_ERREXIT_ARG}" ERR

	trap meta_trap_exit EXIT

	trap meta_trap_int INT

	# setup run guard
	declare -gr meta_setup_traps_called=yes
}; declare -fr meta_setup_traps

#### Collect all information useful for debugging
meta_trap_err_print_debugging_info(){
	if [ ${#} -ne 4 ]; then
		printf 'ERROR: %s: Wrong function argument quantity!\n' "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	local -ir line_error_location=${1}; shift # The line number that triggers the error
	local -r failing_command="${1}"; shift # The failing command
	local -ir failing_command_return_status=${1}; shift # The failing command's return value
	local -r failing_function="${1}"

	# Don't print trace for printf commands
	set +o xtrace

	printf \
		'ERROR: %s has encountered an error and is ending prematurely, %s for support.\n'\
		"${META_PROGRAM_NAME_OVERRIDE:-${RUNTIME_EXECUTABLE_NAME:-This program}}"\
		"${META_APPLICATION_SEEKING_HELP_OPTION:-contact developer}"\
		1>&2

	printf '\n' # Separate paragraphs

	printf 'Technical information:\n'
	printf '\n' # Separate list title and items
	printf '* The failing command is "%s"\n' "${failing_command}"
	printf "* Failing command's return status is %s\\n" "${failing_command_return_status}"
	printf '* Intepreter info: GNU Bash v%s on %s platform\n' "${BASH_VERSION}" "${MACHTYPE}"
	printf '* Stacktrace:\n'

	# Skip the trap functions in stack
	declare -i level=0; while [ "${failing_function}" != "${FUNCNAME[$level]}" ];do
		((level = level +1))
	done
	declare -i counter=0; while [ "${level}" -lt "${#FUNCNAME[@]}" ]; do
		printf '	%u. %s(%s:%u)\n'\
			"${counter}"\
			"${FUNCNAME[${level}]}"\
			"${BASH_SOURCE[${level}]}"\
			"${BASH_LINENO[((${level} - 1))]}"
		((level = level + 1))
		((counter = counter +1))
	done; unset level counter
	printf '\n' # Separate list and further content

	return "${COMMON_RESULT_SUCCESS}"
}; declare -rf meta_trap_err_print_debugging_info

meta_trap_err(){
	if [ ${#} -ne 4 ]; then
		printf 'ERROR: %s: Wrong function argument quantity!\n' "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	local -ir line_error_location=${1}; shift # The line number that triggers the error
	local -r failing_command="${1}"; shift # The failing command
	local -ir failing_command_return_status=${1}; shift # The failing command's return value
	local -r failing_function="${1}"

	meta_trap_err_print_debugging_info "${line_error_location}" "${failing_command}" "${failing_command_return_status}" "${failing_function}"

	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_trap_err

meta_trap_int(){
	# No need to debug abort script
	set +o xtrace

	# Separate from output messages
	printf '\n\n' 1>&2

	printf '中斷程式運行\n' 1>&2
	exit "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_trap_int

meta_trap_return(){
	if [ ${#} -ne 1 ]; then
		printf '%s: %s: ERROR: Wrong function argument quantity!\n' "${GBSS_NAME}" "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi
	local returning_function="${1}"

	printf 'DEBUG: %s: returning from %s\n' "${FUNCNAME[0]}" "${returning_function}" 1>&2
}; declare -fr meta_trap_return

# NOTE: Associative arrays are NOT supported by this function
meta_util_is_array_set_and_not_null(){
	if [ "${#}" -ne 1 ]; then
		printf '%s: Error: argument quantity illegal\n' "${FUNCNAME[0]}" 1>&2
		exit "${COMMON_RESULT_FAILURE}"
	fi

	declare -n array_nameref="${1}"

	if [ "${#array_nameref[@]}" -eq 0 ]; then
		return "${COMMON_BOOLEAN_FALSE}"
	fi
	return "${COMMON_BOOLEAN_TRUE}"
}; declare -fr meta_util_is_array_set_and_not_null

# NOTE: Array and nameref are NOT supported by this function
meta_util_is_parameter_set_and_not_null(){
	if [ "${#}" -ne 1 ]; then
		printf '%s: Error: argument quantity illegal\n' "${FUNCNAME[0]}" 1>&2
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
		printf '%s: Error: argument quantity illegal\n' "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	for parameter_name in "${@}"; do
		declare -n parameter_reference="${parameter_name}"
		if [ -v parameter_reference ]; then
			if [ -z "${parameter_reference}" ]; then
				unset parameter_reference
			else
				declare -r "${parameter_name}"
			fi
		fi
		unset -n parameter_reference
	done; unset parameter_name

	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_make_parameter_readonly_if_not_null_otherwise_unset

#### Introduce the program and software at leaving
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
		printf -- '------------------------------------\n'
	fi
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_NAME; then
		printf '%s\n' "${META_APPLICATION_NAME}"
	fi
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_DEVELOPER_NAME; then
		printf '%s et. al.' "${META_APPLICATION_DEVELOPER_NAME}"
		if meta_util_is_parameter_set_and_not_null META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE; then
			printf " " # Separator with ${META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE}
		else
			printf '\n'
		fi
	fi
	if meta_util_is_parameter_set_and_not_null META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE; then
		printf '© %s\n' "${META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE}"
	fi
	if meta_util_is_parameter_set_and_not_null META_PROGRAM_LICENSE; then
		printf 'Intellectual Property License: %s\n' "${META_PROGRAM_LICENSE}"
	elif meta_util_is_parameter_set_and_not_null META_APPLICATION_LICENSE; then
		printf 'Intellectual Property License: %s\n' "${META_APPLICATION_LICENSE}"
	fi
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_SITE_URL; then
		printf 'Official Website: %s\n' "${META_APPLICATION_SITE_URL}"
	fi
	if meta_util_is_parameter_set_and_not_null META_APPLICATION_ISSUE_TRACKER_URL; then
		printf 'Issue Tracker: %s\n' "${META_APPLICATION_ISSUE_TRACKER_URL}"
	fi
	if meta_util_is_parameter_set_and_not_null META_PROGRAM_PAUSE_BEFORE_EXIT\
		&& [ "${META_PROGRAM_PAUSE_BEFORE_EXIT}" -eq 1 ]; then
		local enter_holder

		printf 'Press ENTER to quit the program.\n'
		read -r enter_holder
	fi
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_trap_exit_print_application_information

meta_trap_exit(){
	meta_trap_exit_print_application_information
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_trap_exit

### Workarounds
#### Temporarily disable errexit
meta_workaround_errexit_setup() {
	if [ ! -v meta_setup_traps_called ]; then
		printf '%s: %s: Error: This function requires meta_setup_traps to be called beforehand.\n'\
			"${GBSS_NAME}"\
			"${FUNCNAME[0]}"
		exit "${COMMON_RESULT_FAILURE}"
	fi
	if [ ${#} -ne 1 ]; then
		printf 'ERROR: %s: Wrong function argument quantity!\n' "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi
	local option=${1} # on: enable errexit; off: disable errexit

	if [ "${option}" == on ]; then
		set -o errexit
		# We separate the arguments to TRAP_ERREXIT_ARG, so it should be expand here
		#shellcheck disable=SC2064
		trap "${TRAP_ERREXIT_ARG}" ERR
	elif [ "${option}" == off ]; then
		set +o errexit
		trap - ERR
	else
		printf 'ERROR: %s: Wrong function argument format!\n' "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_workaround_errexit_setup

meta_util_declare_global_parameters(){
	if [ "${#}" -eq 0 ]; then
		printf '%s: Error: Function parameter quantity illegal\n' "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	for parameter_name in "${@}"; do
		declare -g "${parameter_name}"
	done; unset parameter_name
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_declare_global_parameters

meta_util_unset_global_parameters_if_null(){
	if [ "${#}" -eq 0 ]; then
		printf '%s: Error: Function parameter quantity illegal\n' "${FUNCNAME[0]}" 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	for parameter_name in "${@}"; do
		if [ -z "${parameter_name}" ]; then
			unset "${parameter_name}"
		fi
	done; unset parameter_name
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_unset_global_parameters_if_null

### Runtime Dependencies Checking
### shell - Check if a program exists from a Bash script - Stack Overflow
### http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
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
				printf 'ERROR: Command "%s" not found, program cannot continue like this.\n' "${a_command}" 1>&2
				printf "ERROR: Please make sure %s is installed and it's executable path is in your operating system's executable search path.\\n" "${array_ref["${a_command}"]}" >&2
				printf 'Goodbye.\n'
				exit "${COMMON_RESULT_FAILURE}"
			fi
		done; unset a_command exit_status
		return "${COMMON_RESULT_SUCCESS}"
	fi
}; declare -fr meta_checkRuntimeDependencies

### RUNTIME_*: Info acquired from runtime environment
### https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#runtime-determined-settings
### The following variables defines the environment aspects that can only be detected in runtime, we use RUNTIME_ namespace for these variables.
### These variables will not be set if technically not available(e.g. the program is provided to intepreter/etc. via stdin), or just not implemented yet
meta_fsis_setup_runtime_parameters(){
	meta_util_declare_global_parameters\
		RUNTIME_EXECUTABLE_FILENAME\
		RUNTIME_EXECUTABLE_NAME\
		RUNTIME_EXECUTABLE_DIRECTORY\
		RUNTIME_EXECUTABLE_PATH_ABSOLUTE\
		RUNTIME_EXECUTABLE_PATH_RELATIVE\
		RUNTIME_COMMAND_BASE

	# Runtime environment's executable search path priority array
	declare -a RUNTIME_PATH_DIRECTORIES
	IFS=':' \
		read -r -a RUNTIME_PATH_DIRECTORIES <<< "${PATH}"\
		|| true # Without this `read` will return 1
	declare -r RUNTIME_PATH_DIRECTORIES

	if [ ! -v BASH_SOURCE ]; then
		if meta_util_is_parameter_set_and_not_null META_APPLICATION_INSTALL_STYLE\
			&& [ "${META_APPLICATION_INSTALL_STYLE}" == SHC ]; then
			printf "GNU Bash Shell Script Template: Error: META_APPLICATION_INSTALL_STYLE set to SHC, but is not possible due to unknown script location, make sure the program is not run as intepreter's standard input stream.\\n" 1>&2
			exit "${COMMON_RESULT_FAILURE}"
		fi
	else
		# BashFAQ/How do I determine the location of my script? I want to read some config files from the same place. - Greg's Wiki
		# http://mywiki.wooledge.org/BashFAQ/028
		RUNTIME_EXECUTABLE_FILENAME="$(basename "${BASH_SOURCE[0]}")"
		RUNTIME_EXECUTABLE_NAME="${META_PROGRAM_NAME_OVERRIDE:-${RUNTIME_EXECUTABLE_FILENAME%.*}}"
		RUNTIME_EXECUTABLE_DIRECTORY="$(dirname "$(realpath --strip "${0}")")"
		RUNTIME_EXECUTABLE_PATH_ABSOLUTE="${RUNTIME_EXECUTABLE_DIRECTORY}/${RUNTIME_EXECUTABLE_FILENAME}"
		RUNTIME_EXECUTABLE_PATH_RELATIVE="${0}"

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
		RUNTIME_COMMAND_BASE="${RUNTIME_COMMAND_BASE:-${0}}"
	fi
	meta_util_make_parameter_readonly_if_not_null_otherwise_unset\
		RUNTIME_EXECUTABLE_FILENAME\
		RUNTIME_EXECUTABLE_NAME\
		RUNTIME_EXECUTABLE_DIRECTORY\
		RUNTIME_EXECUTABLE_PATH_ABSOLUTE\
		RUNTIME_EXECUTABLE_PATH_RELATIVE\
		RUNTIME_COMMAND_BASE

	# Collect command-line parameters
	declare -igr RUNTIME_COMMANDLINE_ARGUMENT_QUANTITY="${#}"
	if [ "${RUNTIME_COMMANDLINE_ARGUMENT_QUANTITY}" -ne 0 ]; then
		declare -ag RUNTIME_COMMANDLINE_ARGUMENT_LIST
		RUNTIME_COMMANDLINE_ARGUMENT_LIST=("${@}")
		declare -agr RUNTIME_COMMANDLINE_ARGUMENT_LIST
	fi

	# Set run guard
	declare -gr meta_fsis_setup_runtime_parameters_called=yes
}; declare -fr meta_fsis_setup_runtime_parameters

### Flexible Software Installation Specification - Software Directories Configuration(S.D.C.)
### This function defines and determines the directories used by the software
### https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#software-directories-configurationsdc
meta_fsis_setup_software_directories_configuration(){
	# Run guard
	if [ ! -v meta_fsis_setup_runtime_parameters_called ]; then
		printf '%s: %s: %u: Error: This function cannot be called before meta_fsis_setup_runtime_parameters, please contact developer.\n'\
			"${GBSS_NAME}"\
			"${FUNCNAME[0]}"\
			"${LINENO}"\
			1>&2
		exit "${COMMON_RESULT_FAILURE}"
	fi

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
				meta_util_declare_global_parameters FHS_PREFIX_DIR
				declare -r FHS_PREFIX_DIR="/usr/local"

				declare -r SDC_EXECUTABLES_DIR="${FHS_PREFIX_DIR}/bin"
				declare -r SDC_LIBRARIES_DIR="${FHS_PREFIX_DIR}/lib"
				declare -r SDC_I18N_DATA_DIR="${FHS_PREFIX_DIR}/share/locale"
				if meta_util_is_parameter_set_and_not_null META_APPLICATION_IDENTIFIER; then
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
				meta_util_declare_global_parameters SHC_PREFIX_DIR
				if [ -f "${RUNTIME_EXECUTABLE_DIRECTORY}/APPLICATION_METADATA.source" ]; then
					SHC_PREFIX_DIR="${RUNTIME_EXECUTABLE_DIRECTORY}"
				else
					if [ ! -f "${RUNTIME_EXECUTABLE_DIRECTORY}/PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY.source" ]; then
						printf "GNU Bash Script Template: Error: PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY.source not exist, can't setup Self-contained Hierarchy Configuration.\\n" 1>&2
						exit 1
					fi
					# Scope of Flexible Software Installation Specification
					# shellcheck disable=SC1090,SC1091
					source "${RUNTIME_EXECUTABLE_DIRECTORY}/PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY.source"
					if ! meta_util_is_parameter_set_and_not_null PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY; then
						printf "GNU Bash Script Template: Error: PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY not defined, can't setup Self-contained Hierarchy Configuration.\\n" 1>&2
						exit 1
					fi
					SHC_PREFIX_DIR="$(realpath --strip "${RUNTIME_EXECUTABLE_DIRECTORY}/${PATH_TO_SOFTWARE_INSTALLATION_PREFIX_DIRECTORY}")"
				fi
				declare -gr SHC_PREFIX_DIR

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
				printf 'Error: Unknown software directories configuration, program can not continue.\n' 1>&2
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

	# Set run guard
	declare -gr meta_fsis_setup_software_directories_configuration_called=yes
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_fsis_setup_software_directories_configuration

### Flexible Software Installation Specification - Setup application metadata
### This function locates and loads the metadata of the application
### https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification#application_metadatasource
meta_fsis_setup_application_metadata(){
	# Run guard
	if [ ! -v meta_fsis_setup_software_directories_configuration_called ]; then
		printf '%s: %s: %u: Error: This function cannot be called before meta_fsis_setup_software_directories_configuration_called, please contact developer.\n'\
			"${GBSS_NAME}"\
			"${FUNCNAME[0]}"\
			"${LINENO}"\
			1>&2
		exit "${COMMON_RESULT_FAILURE}"
	fi

	meta_util_declare_global_parameters\
		META_APPLICATION_NAME\
		META_APPLICATION_DEVELOPER_NAME\
		META_APPLICATION_LICENSE\
		META_APPLICATION_SITE_URL\
		META_APPLICATION_ISSUE_TRACKER_URL\
		META_APPLICATION_SEEKING_HELP_OPTION

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
				printf 'Error: Unknown META_APPLICATION_INSTALL_STYLE, program can not continue.\n' 1>&2
				exit 1
				;;
		esac
	fi

	# FIXME: META_APPLICATION_LICENSE isn't unset by this call
	meta_util_make_parameter_readonly_if_not_null_otherwise_unset\
		META_APPLICATION_NAME\
		META_APPLICATION_DEVELOPER_NAME\
		META_APPLICATION_LICENSE\
		META_APPLICATION_SITE_URL\
		META_APPLICATION_ISSUE_TRACKER_URL\
		META_APPLICATION_SEEKING_HELP_OPTION
}; declare -fr meta_fsis_setup_application_metadata

### Drop first element from array and shift remaining elements to replace the first one
### FIXME: command error in this function doesn't not trigger ERR trap for some reason
meta_util_array_shift(){
	if [ "${#}" -ne 1 ]; then
		printf '%s: Error: argument quantity illegal\n' "${FUNCNAME[0]}" 1>&2
		exit "${COMMON_RESULT_FAILURE}"
	fi

	local -n array_ref="${1}"
	if [ "${#array_ref[@]}" -eq 0 ]; then
		printf 'ERROR: array is empty!\n' 1>&2
		return "${COMMON_RESULT_FAILURE}"
	fi

	# Unset the 1st element
	unset 'array_ref[0]'

	# Repack array if element still available in array
	if [ "${#array_ref[@]}" -ne 0 ]; then
		array_ref=("${array_ref[@]}")
	fi

	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_array_shift

### Understand what argument is in the command, and set the global variables accordingly.
meta_processCommandlineParameters() {
	if [ "${RUNTIME_COMMANDLINE_ARGUMENT_QUANTITY}" -eq 0 ]; then
		return "${COMMON_RESULT_SUCCESS}"
	else
		local -n just_uninstall_ref="${1}"

		# modifyable parameters for parsing by consuming
		local -a parameters=("${RUNTIME_COMMANDLINE_ARGUMENT_LIST[@]}")

		# Normally we won't want debug traces to appear during parameter parsing, so we  add this flag and defer it activation till returning(Y: Do debug)
		local enable_debug=N

		while :; do
			# BREAK if no parameters left
			if [ ! -v parameters ]; then
				break
			else
				case "${parameters[0]}" in
					"${COMMANDLINE_OPTION_DISPLAY_HELP_LONG}"\
					|"${COMMANDLINE_OPTION_DISPLAY_HELP_SHORT}")
						meta_printHelpMessage
						exit 0
						;;
					"${COMMANDLINE_OPTION_ENABLE_DEBUGGING_LONG}"\
					|"${COMMANDLINE_OPTION_ENABLE_DEBUGGING_SHORT}")
						enable_debug=Y
						;;
					"${COMMANDLINE_OPTION_JUST_UNINSTALL_LONG}" \
					|"${COMMANDLINE_OPTION_JUST_UNINSTALL_SHORT}")
						just_uninstall_ref="${COMMON_BOOLEAN_TRUE}"
						;;
					*)
						printf 'ERROR: Unknown command-line parameter "%s"\n' "${parameters[0]}" >&2
						return ${COMMON_RESULT_FAILURE}
						;;
				esac
				meta_util_array_shift parameters
			fi
		done
	fi
	if [ "${enable_debug}" = Y ]; then
		trap 'meta_trap_return "${FUNCNAME[0]}"' RETURN
		set -o xtrace
	fi
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_processCommandlineParameters

### Print single segment of commandline option help
meta_util_printSingleCommandlineOptionHelp(){
	if [ "${#}" -ne 3 ] && [ "${#}" -ne 4 ]; then
		printf 'ERROR: %s: Wrong parameter quantity!\n' "${FUNCNAME[0]}" >&2
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

	printf '### %s / %s ###\n' "${long_option}" "${short_option}"
	printf '%s\n' "${description}"

	if [ -v current_value ]; then
		printf 'Current value: %s\n' "${current_value}"
	fi

	printf '\n' # Separate with next option(or next heading)
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_util_printSingleCommandlineOptionHelp

### Print help message whenever:
###   * User requests it
###   * An command syntax error has detected
meta_printHelpMessage(){
	printf '# %s #\n' "${RUNTIME_EXECUTABLE_NAME}"

	if meta_util_is_parameter_set_and_not_null META_PROGRAM_DESCRIPTION; then
		printf '%s\n' "${META_PROGRAM_DESCRIPTION}"
		printf '\n'
	fi

	printf '## Usage ##\n'
	printf '\t%s (command-line options and parameters)\n' "${RUNTIME_COMMAND_BASE}"
	printf '\n'
	printf '## Command-line Options ##\n'
	meta_util_printSingleCommandlineOptionHelp \
		"${COMMANDLINE_OPTION_DISPLAY_HELP_DESCRIPTION}" \
		"${COMMANDLINE_OPTION_DISPLAY_HELP_LONG}" \
		"${COMMANDLINE_OPTION_DISPLAY_HELP_SHORT}"
	meta_util_printSingleCommandlineOptionHelp \
		"${COMMANDLINE_OPTION_ENABLE_DEBUGGING_DESCRIPTION}" \
		"${COMMANDLINE_OPTION_ENABLE_DEBUGGING_LONG}" \
		"${COMMANDLINE_OPTION_ENABLE_DEBUGGING_SHORT}"
	meta_util_printSingleCommandlineOptionHelp \
		"${COMMANDLINE_OPTION_jUST_UNINSTALL_DESCRIPTION}" \
		"${COMMANDLINE_OPTION_JUST_UNINSTALL_LONG}" \
		"${COMMANDLINE_OPTION_JUST_UNINSTALL_SHORT}"
	return "${COMMON_RESULT_SUCCESS}"
}; declare -fr meta_printHelpMessage

meta_setup_traps

### Unset all null META_PROGRAM_* parameters and readonly all others
### META_APPLICATION_IDENTIFIER also as it can't be determined in runtime
meta_util_make_parameter_readonly_if_not_null_otherwise_unset\
	META_PROGRAM_NAME_OVERRIDE\
	META_PROGRAM_IDENTIFIER\
	META_PROGRAM_DESCRIPTION\
	META_PROGRAM_LICENSE\
	META_PROGRAM_PAUSE_BEFORE_EXIT\
	META_PROGRAM_COPYRIGHT_ACTIVATED_SINCE\
	META_APPLICATION_IDENTIFIER

if meta_util_is_array_set_and_not_null META_RUNTIME_DEPENDENCIES_CRITICAL; then
	meta_checkRuntimeDependencies META_RUNTIME_DEPENDENCIES_CRITICAL
fi
if meta_util_is_array_set_and_not_null META_RUNTIME_DEPENDENCIES; then
	meta_checkRuntimeDependencies META_RUNTIME_DEPENDENCIES
fi

meta_fsis_setup_runtime_parameters "${@}"
meta_fsis_setup_software_directories_configuration
meta_fsis_setup_application_metadata

## This script is based on the GNU Bash Shell Script Template project
## https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template
## and is based on the following version: 
## GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="v2.0.1-59-g44ce005"
## You may rebase your script to incorporate new features and fixes from the template

### This script is comforming to Flexible Software Installation Specification
### https://github.com/Lin-Buo-Ren/Flexible-Software-Installation-Specification
### and is based on the following version: v1.5.0
## ###################### End of GBSST Support Code #########################

init "${@}"
