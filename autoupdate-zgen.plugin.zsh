# Copyright 2014-2020 Joe Block <jpb@unixorn.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

_zgen-check-interval() {
  now=$(date +%s)
  if [[ ! -f ~/"${1}" ]]; then
    # We've never run, set the last run time to the dawn of time, or at
    # least the dawn of posix time.
    echo 0 > ~/"${1}"
  fi
  last_update=$(cat ~/"${1}")
  interval=$(expr ${now} - ${last_update})
  echo "${interval}"
}

_zgen-check-for-updates() {
  if [ -z "${ZGEN_PLUGIN_UPDATE_DAYS}" ]; then
    ZGEN_PLUGIN_UPDATE_DAYS=7
  fi

  if [ -z "${ZGEN_SYSTEM_UPDATE_DAYS}" ]; then
    ZGEN_SYSTEM_UPDATE_DAYS=7
  fi

  if [ -z "${ZGEN_SYSTEM_RECEIPT_F}" ]; then
    if [ -n "${ZGEN_DIR}" ]; then
      # Since the $ZGEN_{SYSTEM|PLUGIN}_RECEIPT_F variables are with
      # respect to the home directory but $ZGEN_DIR is an absolute path,
      # $ZGEN_{SYSTEM|PLUGIN}_RECEIPT_F is set to $ZGEN_DIR (if it is defined)
      # with the $HOME directory as the prefix removed
      # (That's what the "${${ZGEN_DIR}#${HOME}}" syntax does: it removes the
      # "$HOME" prefix from "$ZGEN_DIR")
      ZGEN_SYSTEM_RECEIPT_F="${${ZGEN_DIR}#${HOME}}/.zgen_system_lastupdate"
    else
      ZGEN_SYSTEM_RECEIPT_F='.zgen_system_lastupdate'
    fi
  fi

  if [ -z "${ZGEN_PLUGIN_RECEIPT_F}" ]; then
    if [ -n "${ZGEN_DIR}" ]; then
      ZGEN_PLUGIN_RECEIPT_F="${${ZGEN_DIR}#${HOME}}/.zgen_plugin_lastupdate"
    else
      ZGEN_PLUGIN_RECEIPT_F='.zgen_plugin_lastupdate'
    fi
  fi

  local day_seconds=$(expr 24 \* 60 \* 60)
  local system_seconds=$(expr "${day_seconds}" \* "${ZGEN_SYSTEM_UPDATE_DAYS}")
  local plugins_seconds=$(expr ${day_seconds} \* ${ZGEN_PLUGIN_UPDATE_DAYS})

  local last_plugin=$(_zgen-check-interval ${ZGEN_PLUGIN_RECEIPT_F})
  local last_system=$(_zgen-check-interval ${ZGEN_SYSTEM_RECEIPT_F})

  if [[ ${last_plugin} -gt ${plugins_seconds} ]]; then
    if [[ ! -z "${ZGEN_AUTOUPDATE_VERBOSE}" ]]; then
      echo "It has been $(expr ${last_plugin} / $day_seconds) days since your zgen plugins were updated"
      echo "Updating plugins"
    fi
    zgen update
    date +%s >! ~/${ZGEN_PLUGIN_RECEIPT_F}
  fi

  if [[ ${last_system} -gt ${system_seconds} ]]; then
    if [[ ! -z "${ZGEN_AUTOUPDATE_VERBOSE}" ]]; then
      echo "It has been $(expr ${last_plugin} / ${day_seconds}) days since your zgen was updated"
      echo "Updating zgen..."
    fi
    zgen selfupdate
    date +%s >! ~/${ZGEN_SYSTEM_RECEIPT_F}
  fi
}

# Don't update if we're running as different user than whoever
# owns ~/.zgen. This prevents sudo runs from leaving root-owned
# files & directories in ~/.zgen that will break future updates
# by the user.
#
# Use ls and awk instead of stat because stat has incompatible arguments
# on linux, macOS and FreeBSD.
local zgen_owner=$(ls -ld ${ZGEN_DIR:-$HOME/.zgen} | awk '{print $3}')
if [[ "$zgen_owner" == "$USER" ]]; then
  zmodload zsh/system
  lockfile=~/.zgen_autoupdate_lock
  touch $lockfile
  if ! which zsystem &> /dev/null || zsystem flock -t 1 $lockfile; then
    _zgen-check-for-updates
    command rm -f $lockfile
  fi
fi
