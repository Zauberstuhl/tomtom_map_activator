#!/bin/bash
#
# TomTom Map Activator for Linux
# Copyright (C) 2017 Lukas Matt <lukas@zauberstuhl.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
working_dir=$1;
activate_card=$2;
currmap="${working_dir}/currentmap.dat";
ttgo="${working_dir}/ttgo.bif";
mapinfo="mapinfo.dat";

function activate() {
  card_dir=$1;
  echo "Activating $card_dir";
  echo -n "1C0000002F6D6E742F7364636172642F"$(echo -n "$card_dir" |xxd -p)"2F00" | xxd -r -p > $currmap;
  echo ".. updated $currmap";
  sed -i 's/CurrentMap=.*$/CurrentMap='$(echo -n $card_dir |cut -d'/' -f1)'/' $ttgo
  sed -i 's/CurrentMapVersion=.*$/CurrentMapVersion=1/' /tmp/usb/ttgo.bif
  echo ".. updated $ttgo";
}

if [[ "$working_dir" == "" ]]; then
  echo "Please provide the path to your tomtom device (e.g. $0 /mnt/tomtom [card-number])!";
  exit 1;
fi

if ! [ -f "${currmap}.bak" ]; then
  # backup files
  cp -v $currmap ${currmap}.bak || exit 1;
  cp -v $ttgo ${ttgo}.bak || exit 1;
fi

card_num=0;
find $working_dir -name $mapinfo |while read mapinfo_file; do
  card_dir=$(echo -n $mapinfo_file |sed "s/\/$mapinfo$//" |sed "s#^${working_dir}/*##");

  if [ $activate_card -gt -1 ]; then
    if [ $activate_card == $card_num ]; then
      activate "$card_dir";
    fi
  else
    echo "$card_num) $card_dir";
  fi
  ((card_num+=1));
done

echo -e "\n\nDone!";
