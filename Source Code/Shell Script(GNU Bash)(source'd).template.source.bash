# shellcheck shell=bash
# shellcheck disable=SC2034

# <Source Description>
# <Copyright Holder Name> © <Copyright Activation Latest Year, for determining year of end of copyright protection>
## Include Guard to prevent multiple sourcing
## TODO: rename INCLUDE_GUARD to something sensible for each file, like INCLUDE_GUARD_FOO
if [ -n "${INCLUDE_GUARD}" ]; then
	return 0
fi

## TODO: Put your code here

## Set Include Guard
declare INCLUDE_GUARD=1

## This script is based on the GNU Bash Shell Script Template project
## https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template
## and is based on the following version:
declare -r META_BASED_ON_GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="@@TEMPLATE_VERSION@@"
## You may rebase your script to incorporate new features and fixes from the template