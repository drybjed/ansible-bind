#!/bin/bash

# Increment serial in a BIND zone file
# Source: https://unix.stackexchange.com/a/257073


ZONE="${1}"
DATE=$(date +%Y%m%d)

# we're looking line containing this comment
NEEDLE="serial"

if [ -n "${ZONE}" -a -w "${ZONE}" ] ; then

    curr=$(grep -E "${NEEDLE}$" ${ZONE} | sed -n "s/^\s*\([0-9]*\)\s*;\s*${NEEDLE}\s*/\1/p")

    # replace if current date is shorter (possibly using different format)
    if [ ${#curr} -lt ${#DATE} ]; then
      serial="${DATE}00"
    else
      prefix=${curr::-2}

      if [ "$DATE" -eq "$prefix" ]; then         # same day
        num=${curr: -2}                          # last two digits from serial number
        num=$((10#$num + 1))                     # force decimal representation, increment
        serial="${DATE}$(printf '%02d' $num )"   # format for 2 digits
      else
        serial="${DATE}00"                       # just update date
      fi
    fi
    sed -i -e "s/^\(\s*\)[0-9]\{0,\}\(\s*;\s*${NEEDLE}\)$/\1${serial}\2/" ${ZONE}
    echo -n "${ZONE}"
    grep "; ${NEEDLE}$" ${ZONE} | tr -s " "

fi
