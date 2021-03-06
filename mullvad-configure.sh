#!/usr/bin/env sh
#
# Copyright (c) 2019, Cristian Ariza
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Provides a terminal UI for the mullvad cli app
set -u

_quiet() {
	"$@" >/dev/null 2>&1
}

_get_status() (
	case "$(mullvad status)" in
	*Discon*) _is_active=false ;;
	*) _is_active=true ;;
	esac

	printf '%s' "$_is_active"
)

_toggle_status() {
	case "$1" in
	true) _quiet mullvad disconnect && echo false ;;
	false) _quiet mullvad connect && echo true ;;
	esac
}

_toggle_block() {
	case "$1" in
	true) _quiet mullvad block-when-disconnected set off && echo false ;;
	*) _quiet mullvad block-when-disconnected set on && echo true ;;
	esac
}

_toggle_allow_lan() {
	case "$1" in
	true) _quiet mullvad lan set block && echo false ;;
	*) _quiet mullvad lan set allow && echo true ;;
	esac
}

_toggle_autoconnect() {
	case "$1" in
	true) _quiet mullvad auto-connect set off && echo false ;;
	*) _quiet mullvad auto-connect set on && echo true ;;
	esac
}

_get_autoconnect() {
	case "$(mullvad auto-connect get)" in
	*off*) _autoconnect=false ;;
	*) _autoconnect=true ;;
	esac

	printf '%s' "$_autoconnect"
}

_get_block() {
	case "$(mullvad block-when-disconnected get)" in
	*block*) _block=true ;;
	*) _block=false ;;
	esac

	printf '%s' "$_block"
}

_get_allow_lan() {
	case "$(mullvad lan get)" in
	*allow*) _allow_lan=true ;;
	*) _allow_lan=false ;;
	esac

	printf '%s' "$_allow_lan"
}

_quit_warning() {
	printf '\n"q" to exit\n'
}

if [ "$#" -gt 0 ] && [ x"$1" = "x-d" ]; then
	set -x
fi

_quit_warning() {
	printf '\n"q" to exit\n'
}

_version="$(mullvad version &)"
_autoconnect="$(_get_autoconnect &)"
_block="$(_get_block &)"
_is_active="$(_get_status &)"
_allow_lan="$(_get_allow_lan &)"

_account_output="$(timeout 1 mullvad account get)"
_account="$(printf '%s' "$_account_output" | awk 'NR==1{ print $3 }')"
_expire="$(printf '%s' "$_account_output" | awk 'NR==2{for(i=4;i<=NF;++i)printf "%s ",$i; printf "\n" }')"

wait

echo '****************************'
echo MULLVAD VERSION
printf '%s\n' "$_version"
echo '****************************'
echo

while :; do

	printf '1) Is connected? %s\n' "$_is_active"
	printf '2) Account: %s\n' "$_account"
	printf '   Expire: %s\n' "$_expire"
	printf '3) Autoconnect? %s\n' "$_autoconnect"
	printf '4) Block internet when disconnected? %s\n' "$_block"
	printf '5) LAN allowed? %s\n' "$_allow_lan"

	again=true

	while "$again"; do
		again=false
		trap '_quit_warning' 2
		printf 'option> ' && read -r _option
		trap 2

		case "$_option" in
		1)
			_is_active="$(_toggle_status "$_is_active")"
			;;
		2)
			printf 'new account no.: ' && read -r _account
			_account="$(mullvad account set "$_account")"
			;;
		3)
			_autoconnect="$(_toggle_autoconnect "$_autoconnect")"
			;;
		4)
			_block="$(_toggle_block "$_block")"
			;;
		5)
			_allow_lan="$(_toggle_allow_lan "$_allow_lan")"
			;;
		q)
			exit 0
			;;
		*)
			printf 'Invalid option: "%s"\n' "$_option"
			again=true
			;;
		esac
	done

	printf '\n'
done

