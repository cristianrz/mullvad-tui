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
shellcheck -x "$0" || exit 1

if [ "$#" -gt 0 ] && [ x"$1" = "x-d" ]; then
	set -x
fi

_account=
while [ -z "$_account" ]; do
	printf 'Account number: ' && read -r _account
done

printf 'Autoconnect? [y/N]: ' && read -r _autoconnect
printf 'Block internet when disconnected? [Y/n]: ' && read -r _block
printf 'Allow LAN connections? [y/N]: ' && read -r _allow_lan

echo Configuring...

{
	mullvad account set "$_account"

	case "$_autoconnect" in
	y* | Y*) mullvad auto-connect set on ;;
	*) mullvad auto-connect set off ;;
	esac

	case "$_block" in
	n* | N*) mullvad block-when-disconnected set off ;;
	*) mullvad block-when-disconnected set on ;;
	esac

	case "$_allow_lan" in
	y* | Y*) mullvad lan set allow ;;
	*) mullvad lan set block ;;
	esac
} >/dev/null

echo Done

printf 'Connect now? [y/N]: ' && read -r _is_active

case "$_is_active" in
y* | Y*) mullvad connect ;;
*) mullvad disconnect ;;
esac

exit 0
