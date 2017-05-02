# shellcheck shell=bash
# shellcheck disable=SC2034

# <Source Description>
# <Copyright Holder Name> © <Copyright Activation Latest Year, for determining year of end of copyright protection>
## Include Guard to prevent multiple sourcing
## TODO: rename INCLUDE_GUARD to something sensible for each file, like INCLUDE_GUARD_FOO
if [ -z "${INCLUDE_GUARD}" ]; then
	return 0
fi

## TODO: Put your code here

## Set Include Guard
declare INCLUDE_GUARD=1

## Template version this script based on, for incorporating new features from the template
declare -r META_BASED_ON_GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="@@TEMPLATE_VERSION@@"
