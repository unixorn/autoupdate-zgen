# Copyright 2014-2015 Joe Block <jpb@unixorn.net>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

_zgen-check-interval() {
  now=$(date +%s)
  if [ -f ~/"${1}" ]; then
    last_update=$(cat ~/"${1}")
  else
    last_update=0
  fi
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
    ZGEN_SYSTEM_RECEIPT_F='.zgen_system_lastupdate'
  fi

  if [ -z "${ZGEN_PLUGIN_RECEIPT_F}" ]; then
    ZGEN_PLUGIN_RECEIPT_F='.zgen_plugin_lastupdate'
  fi

  local day_seconds=$(expr 24 \* 60 \* 60)
  local system_seconds=$(expr "${day_seconds}" \* "${ZGEN_SYSTEM_UPDATE_DAYS}")
  local plugins_seconds=$(expr ${day_seconds} \* ${ZGEN_PLUGIN_UPDATE_DAYS})

  local last_plugin=$(_zgen-check-interval ${ZGEN_PLUGIN_RECEIPT_F})
  local last_system=$(_zgen-check-interval ${ZGEN_SYSTEM_RECEIPT_F})

  if [ ${last_plugin} -gt ${plugins_seconds} ]; then
    if [ ! -z "${ZGEN_AUTOUPDATE_VERBOSE}" ]; then
      echo "It has been $(expr ${last_plugin} / $day_seconds) days since your zgen plugins were updated"
      echo "Updating plugins"
    fi
    zgen update
    date +%s >! ~/${ZGEN_PLUGIN_RECEIPT_F}
  fi

  if [ ${last_system} -gt ${system_seconds} ]; then
    if [ ! -z "${ZGEN_AUTOUPDATE_VERBOSE}" ]; then
      echo "It has been $(expr ${last_plugin} / ${day_seconds}) days since your zgen was updated"
      echo "Updating zgen..."
    fi
    zgen selfupdate
    date +%s >! ~/${ZGEN_SYSTEM_RECEIPT_F}
  fi
}

zmodload zsh/system
lockfile=~/.zgen_autoupdate_lock
touch $lockfile
if ! which zsystem &> /dev/null || zsystem flock -t 1 $lockfile; then
  _zgen-check-for-updates
  rm $lockfile
fi
