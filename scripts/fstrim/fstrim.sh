#!/bin/sh
LSBLK=$(command -v lsblk)
FSTRIM=$(command -v fstrim)

if [ -z "${LSBLK}" ]
then
    echo "Unable to find 'lsblk'!"
    exit 1
fi

if [ -z "${FSTRIM}" ]
then
    echo "Unable to find 'fstrim'!"
    exit 1
fi

for FS in $("${LSBLK}" -o MOUNTPOINT,DISC-MAX,FSTYPE | grep -E '^/.* [1-9]+.* ' \
    | awk '{print $1}' | sort | uniq)
do
    "${FSTRIM}" "${FS}"
done
