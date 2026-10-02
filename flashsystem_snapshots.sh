#!/usr/bin/env ksh

CheckFlashSystem () { [ -n "$DEBUG" ] && $DEBUG && set -x
    if ssh -o ConnectTimeout=5 "$STORAGEDEF" lsnodecanister 2>/dev/null ; then
        true
    else
        set +x
        printf "$PRGNAME: *****************************************************\n" >&2
        printf "$PRGNAME: * %-50s*\n" "Can't connect to '$STORAGEDEF', exiting ..." >&2
        printf "$PRGNAME: *****************************************************\n" >&2
        exit 255
    fi
}

CheckSnapshotExistence () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Checks if there is a snapshot with the chosen name given as argument $1
    if [ $# -eq 0 ] ; then
        false
    else
        VGNAME="$1"
        ssh "$STORAGEDEF" lsvolumegroupsnapshot -delim : |
            awk -v N=$VGNAME '
                $2==N {found=1; exit 0}
                END {if(!found) exit 1} '
    fi
}

AddSnapshot () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Create a snapshot of volumegroup $1 with name $2
    if [ $# -lt 2 ] ; then
        false
    else
        VGNAME="$1" SNAPNAME="$2"
        ssh "$STORAGEDEF" addsnapshot -volumegroup "$VGNAME" -name "$SNAPNAME"
        if CheckSnapshotExistence "$SNAPNAME" ; then
            true
        else
            false
        fi
    fi
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: flashsystem snapshot functions loaded.\n" >&2
}

CheckFlashSystem
