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
declare -r RUNTIME_SCRIPT_NAME="${RUNTIME_SCRIPT_FILENAME%.*}"
RUNTIME_SCRIPT_DIRECTORY="$(dirname "$(realpath --strip "${0}")")"
readonly RUNTIME_SCRIPT_DIRECTORY
readonly RUNTIME_SCRIPT_PATH_ABSOLUTE="${RUNTIME_SCRIPT_DIRECTORY}/${RUNTIME_SCRIPT_FILENAME}"
readonly RUNTIME_SCRIPT_PATH_RELATIVE="${0}"
readonly RUNTIME_COMMAND_BASE="${RUNTIME_COMMAND_BASE:-${0}}"

trap_errexit(){
	printf "An error occurred and the script is prematurely aborted\n" 1>&2
	return 0
}; readonly -f trap_errexit; trap trap_errexit ERR

trap_exit(){
	rm --recursive --force "${global_temp_directory}"
	return 0
}; readonly -f trap_exit; trap trap_exit EXIT

check_runtime_dependencies(){
	for a_command in cat mktemp mv; do
		if ! command -v "${a_command}" &>/dev/null; then
			printf "ERROR: %s command not found.\n" "${a_command}" 1>&2
			return 1
		fi
	done
	return 0
}

declare -i global_just_show_help="0"
declare -i global_enable_debug_mode="0"
declare -a global_input_file_list=()
declare global_temp_directory=""

print_help(){
	if [ "${#}" -ne 0 ]; then
		printf "%s: Function argument quantity illegal, got %u instead of 0\n" "${FUNCNAME[0]}" "${#}" 1>&2
		return 1
	fi

	cat <<-END_OF_HERE_DOCUMENT
		# "${RUNTIME_SCRIPT_NAME}"'s Helpful Note #
		This program replaces @@TEMPLATE_VERSION@@ pattern in template files to proper git revision description.

		## Usage ##
		\`\`\`bash
		"${RUNTIME_COMMAND_BASE}" (Commandline Options) (Files to be smudged...)
		\`\`\`

		## Commandline Options ##
		* -h / --help: display this help"
		* -d / --debug: enable traces for debugging"

		## Examples ##
		We <3 examples!

		* \`${RUNTIME_COMMAND_BASE} my_awesome_template.template.bash another_one.template.bash\`

		END_OF_HERE_DOCUMENT

	return 0
}; declare -fr print_help

parse_commandline_arguments(){
	for commandline_argument in "${@}"; do
		case "${commandline_argument}" in
			-h | --help)
				global_just_show_help="1"
			;;
			-d | --debug)
				global_enable_debug_mode="1"
			;;
			*)
				global_input_file_list+=("${commandline_argument}")
			;;
		esac
	done
	return 0
}; declare -fr parse_commandline_arguments

smudge_file(){
	if [ "${#}" -ne 1 ]; then
		printf "%s: Function argument quantity illegal, got %u instead of 1\n" "${FUNCNAME[0]}" "${#}" 1>&2
		return 1
	fi

	target_file="${1}"
	declare -r temp_file_name=stdout.bash
	declare -r temp_file="${global_temp_directory}/${temp_file_name}"

	# Workaround: Make Git don't consider tree is dirty even when it shouldn't because of the existing clean filter
	# Why does 'git status' ignore the .gitattributes clean filter? - Stack Overflow
	# http://stackoverflow.com/questions/19807979/why-does-git-status-ignore-the-gitattributes-clean-filter
	git add -u

	printf "Smudging %s...\n" "${target_file}"
	"${RUNTIME_SCRIPT_DIRECTORY}"/smudge-bash.bash <"${target_file}" >"${temp_file}"
	cat "${temp_file}" >"${target_file}"

	return 0;
}; declare -fr smudge_file

create_temp_directory(){
	if [ "${#}" -ne 0 ]; then
		printf "%s: Function argument quantity illegal, got %u instead of 0\n" "${FUNCNAME[0]}" "${#}" 1>&2
		return 1
	fi

	global_temp_directory="$(mktemp --tmpdir --directory "${RUNTIME_SCRIPT_NAME}.XXXX")"

	declare -gr global_temp_directory
	return 0
}; declare -fr create_temp_directory

## init function: program entrypoint
init(){
	if ! check_runtime_dependencies; then
		exit 1
	fi

	if [ "${#}" -eq 0 ]; then
		global_just_show_help="1"
	fi

	if ! parse_commandline_arguments "${@}"; then
		exit 1
	fi

	if [ "${global_enable_debug_mode}" -eq 1 ]; then
		set -o xtrace
	fi

	if [ "${global_just_show_help}" -eq 1 ]; then
		print_help
		exit 0
	fi

	if ! create_temp_directory; then
		exit 1
	fi

	# Unlike ${@}, ${array[@]} is NOT considered a unbounded variable exception
	# Bash empty array expansion with `set -u` - Stack Overflow
	# http://stackoverflow.com/questions/7577052/bash-empty-array-expansion-with-set-u
	( set +o nounset
		for a_file in "${global_input_file_list[@]}"; do
			smudge_file "${a_file}"
		done
	);
	exit 0
}; readonly -f init
init "${@}"