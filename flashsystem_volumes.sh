#!/usr/bin/env ksh93

if [ ! -n "$STORAGEHOSTNAME" ] ; then
    if [ ! -n "$HOST" ] ; then
        export HOST=$(hostname -s)
    fi
    export STORAGEHOSTNAME=$(ssh "$STORAGEDEF" lshost -delim : -nohdr |
        awk -F: '{print $2}' | fgrep -iw "$HOST")
fi

CheckVolumeExistence () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Checks if there is a snapshot with the chosen name given as argument $1
    if [ $# -eq 0 ] ; then
        false
    else
        LVNAME="$1"
        ssh "$STORAGEDEF" lsvdisk -delim : -filtervalue name="$LVNAME" |
            awk -v N=$LVNAME '
                $2==N {found=1; exit 0}
                END {if(!found) exit 1} '
    fi
}

ListFilteredMappedVolumes () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Gets the list of mapped volumes to host in $1 that match the prefix $2
    if [ $# -lt 2 ] ; then
        false
    else
        STORAGEHOST="$1" PREFIX="$2"
        ssh "$STORAGEDEF" lshostvdiskmap -nohdr -delim : "$STORAGEHOST" |
            awk -F: -v PREFIX="^$PREFIX" '$5~PREFIX{print $5}'
    fi
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: flashsystem volume functions loaded.\n" >&2
}
