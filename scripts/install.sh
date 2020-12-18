#!/usr/bin/env bash

set -e

action="${1:-"install"}"

profile_files=(
  etc/udev/hwdb.d/sennheiser-gsx.hwdb
  lib/udev/rules.d/91-sennheiser-gsx-1000.rules
  lib/udev/rules.d/91-sennheiser-gsx-1200.rules
  usr/share/pulseaudio/alsa-mixer/profile-sets/sennheiser-gsx-1000-profile-set.conf
  usr/share/pulseaudio/alsa-mixer/profile-sets/sennheiser-gsx-1200-profile-set.conf
  usr/share/pulseaudio/alsa-mixer/paths/sennheiser-gsx-1000-output-comm.conf
  usr/share/pulseaudio/alsa-mixer/paths/sennheiser-gsx-1000-output-main.conf
)

need_alias() {
  if [[ "${1}" != *"usr/share/pulseaudio"* ]]; then
    return 1
  fi

  if [ -d /usr/share/alsa-card-profile/mixer/profile-sets ]; then
    return 0
  else
    return 1
  fi
}

alias_path() {
  echo "$1" | sed "s/pulseaudio\/alsa-mixer/alsa-card-profile\/mixer/"
}

install() {
  echo "Installing GSX 1000 / 1200 Pro"
  echo -n "Installing files... "

  for file in "${profile_files[@]}"; do
    f_orig=$(readlink -f "src/${file}")
    f_dest="/${file}"
    sudo cp "${f_orig}" "${f_dest}"
    if need_alias "${f_orig}"; then
        sudo ln -sf "${f_dest}" "$(alias_path "${f_dest}")"
    fi
  done

  echo "OK"
}

uninstall() {
  echo "Uninstalling GSX 1000 / 1200 Pro"
  echo -n "removing files... "
  for file in "${profile_files[@]}"; do
    f_dest="/${file}"
    sudo rm -f "${f_dest}"
    if need_alias "${file}"; then
      sudo rm -f "$(alias_path "${f_dest}")"
    fi
  done
  echo "OK"
}

"${action}"
./scripts/restart-devices.sh
