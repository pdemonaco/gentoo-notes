#!/bin/bash

BASENAME=$(basename "$0")

# Usage --------------------------------------------
USAGE="Trivial CHROOT script
Usage: ${BASENAME} [-m MOUNT_POINT] -p POOL -a ACTION
   or: ${BASENAME} [-h]

Provides a simple mechanism to chroot into a new gentoo install environment
which has a ZFS root.

Mandatory Arguments:
  -p POOL           Name of the ZPOOL which should be mounted at the root of the
                    gentoo install

  -a ACTION         One of two options, START which mounts all the shit and
                    STOP which unmounts everything.

Optional Arguments:
  -m MOUNT_POINT      If specified, the script uses this as the mount target
                      instead of '/mnt/gentoo'.

  -h, --help          display this help and exit
"

#-------- Print Error Message -------------------------------------------------
function echoerr()
{
    printf "%s\n" "$*" >&2;
    exit 1
}

#-------- Parse Arguments -----------------------------------------------------
# Shamelessly stolen from
# https://medium.com/@Drew_Stokes/bash-argument-parsing-54f3b81a6a8f
# Note that the variables in this function are intentionally globals
function parse_arguments()
{
    # Collect parameters
    PARAMS=""
    while (( "$#" ));
    do
        case "$1" in
            -h|--help)
                # Print usage and quit
                echo "${USAGE}"
                exit 0
                ;;
            -a)
                ACTION=$2
                shift 2
                ;;
            -m)
                MOUNT_POINT=$2
                shift 2
                ;;
            -p)
                POOL_NAME=$2
                shift 2
                ;;
            --) # end argument parsing
                shift
                break
                ;;
            -*) # unsupported flags
                echoerr "${BASENAME}: Unsupported flag ${1}"
                ;;
            *) # preserve positional arguments
                PARAMS="$PARAMS $1"
                shift
                ;;
        esac
    done

    # Check mandatory parameters
    if [ -z "${ACTION}" ]; then
        echoerr "${BASENAME}: ACTION is mandatory!"
    fi

    if [ -z "${POOL_NAME}" ]; then
        echoerr "${BASENAME}: POOL_NAME is mandatory!"
    fi

    # Default optional param
    if [ -z "${MOUNT_POINT}" ]; then
        MOUNT_POINT="/mnt/gentoo"
    fi
}

#======== Main control block ==================================================

# Record the parameters - intentionally multiple words
# shellcheck disable=SC2068
parse_arguments $@

if ! [ -d "${MOUNT_POINT}" ]; then
    mkdir -p "${MOUNT_POINT}"
fi

case "${ACTION}" in
    START)
        zpool import -f -o cachefile= -R "${MOUNT_POINT}" "${POOL_NAME}"
        mount -t proc proc "${MOUNT_POINT}/proc/"
        mount --rbind /dev "${MOUNT_POINT}/dev/"
        mount --rbind /sys "${MOUNT_POINT}/sys"
        ;;
    STOP)
        umount -l /mnt/gentoo/proc /mnt/gentoo/dev /mnt/gentoo/sys
        zpool export "${POOL_NAME}"
        ;;
esac

# shellcheck disable=SC2016
printf "To switch to the new environment:\n\t%s\n\t%s" \
    "chroot ${MOUNT_POINT} /bin/bash" \
    'source /etc/profile; env-update; export PS1="(chroot) $PS1"; cd'
