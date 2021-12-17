#!/bin/bash
# Based on https://gist.github.com/mvazquezc/a5d69f996b7ab43c1ea24a1194672597

DEVICE=/dev/${1}
NUM_LVS=${2}
SIZE_LVS=${3}

help()
{
  echo "Run the script as follows: ${0} <device> <num_lvs_to_create> <size_of_the_lvs>"
  echo "Example: ${0} sdb 10 30  | This will create 10 lvs of 30G each"
}

checks()
{
  if [[ $(id -u) != "0" ]]
  then
    echo "This script must be run as root"
    exit 1
  fi

  if [[ ${DEVICE} == "/dev/" ]]
  then
    echo "You must provide a device"
    help
    exit 1
  fi

  if [[ -z ${NUM_LVS} ]]
  then
    echo "You must provide the number of LVs"
    help
    exit 1
  fi

  if [[ -z ${SIZE_LVS} ]]
  then
    echo "You must provide the size for the LVs"
    help
    exit 1
  fi

  if [[ ! -b ${DEVICE} ]]
  then
    echo "${DEVICE} not found"
    exit 1
  fi
}

preparePV()
{
  if [[ $(pvdisplay ${DEVICE} 2>/dev/null| wc -l) == "0" ]]
  then
    echo "Initializing PV"
    pvcreate ${DEVICE}
  fi
}

prepareVG()
{
  if [[ $(vgdisplay autopart 2>/dev/null | wc -l) == "0" ]]
  then
    echo "Initializing VG"
    vgcreate autopart ${DEVICE}
  fi
}

createLV()
{
  SIZE=${1}
  VG=${2}
  LAST_LV=$(lvs autopart --no-headings --separator , 2>/dev/null | awk -F "," '{print $1}' | awk -F "lv_" '{print $2}' | sort -n | tail -1)
  NEW_LV=$((LAST_LV + 1))
  lvcreate -L ${SIZE}G --name lv_${NEW_LV} ${VG}
}

main()
{
  checks
  preparePV
  prepareVG

  for (( part=1; part<=${NUM_LVS}; part++ ))
  do
    createLV ${SIZE_LVS} autopart
  done  
}

main
