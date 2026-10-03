#!/usr/bin/env ksh93

if [ ! -n "$STORAGEHOSTNAME" ] ; then
    if [ ! -n "$HOST" ] ; then
        export HOST=$(hostname -s)
    fi
    export STORAGEHOSTNAME=$(ssh "$STORAGEDEF" lshost -delim : -nohdr |
        awk -F: '{print $2}' |
        fgrep -iw "$HOST")
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
        typeset UNUSED="$1" PREFIX="$2"
        ssh "$STORAGEDEF" lshostvdiskmap -nohdr -delim : "$STORAGEHOSTNAME" |
            awk -F: -v PREFIX="^$PREFIX" '$5 ~ PREFIX { print $5 }'
    fi
}

ListVolumePopulation () { [ -n "$DEBUG" ] && $DEBUG && set -x
# List volume names of a given snapshot volume group $1
    if [ $# -lt 1 ] ; then
        return 1
    else
        VGNAME="$1"
        ssh "$STORAGEDEF" lsvolumepopulation -delim : -nohdr |
            awk -F: -v VGNAME="$VGNAME" '
                $4 == VGNAME { print $2 }
            ' | sort -u
    fi
}

MapVolumes () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Map all volumes given, starting from $STARTLUN
    if [ $# -lt 1 ] ; then
        return 1
    else
        typeset -i LUN=$START_LUN
        for VOL in "$@" ; do
            ssh "$STORAGEDEF" mkvdiskhostmap -host "$STORAGEHOSTNAME" -scsi "$LUN" "$VOL" >/dev/null 2>&1 && let LUN=LUN+1
        done
    fi
}

GetVolumes () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Get the list of volumes for all given disks
    if [ $# -eq 0 ] ; then
        return 1
    else
        for DISK in "$@" ; do
            GetVolumeForDisk "$DISK"
        done
    fi
}

UnmapVolumes () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Unmap all volumes given
    for VOL in "$@" ; do
        ssh "$STORAGEDEF" rmvdiskhostmap -host "$STORAGEHOSTNAME" "$VOL" >/dev/null
    done
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: flashsystem volume functions loaded.\n" >&2
}
