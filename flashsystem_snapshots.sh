#!/usr/bin/env ksh93

CheckFlashSystem () { [ -n "$DEBUG" ] && $DEBUG && set -x
    if ssh -o ConnectTimeout=5 "$STORAGEDEF" lssystem >/dev/null 2>&1 ; then
        UnprotectUnmap
        return 0
    else
        set +x
        printf "$PRGNAME: *****************************************************\n" >&2
        printf "$PRGNAME: * %-50s*\n" "Can't connect to '$STORAGEDEF', exiting ..." >&2
        printf "$PRGNAME: *****************************************************\n" >&2
        exit 255
    fi
}

UnprotectUnmap () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Change vdiskprotectionenabled to no
    export UNMAP_UNPROTECT="${UNMAP_UNPROTECT:=false}"
    if $UNMAP_UNPROTECT ; then
        export UNMAP_PROTECTION=$(ssh "$STORAGEDEF" lssystem |
                awk '$1=="vdisk_protection_enabled" {print $2}'
            )
        if [ "$UNMAP_PROTECTION" = "yes" ] ; then
            ssh "$STORAGEDEF" chsystem -vdiskprotectionenabled no >/dev/null
        fi
    fi
}

ProtectUnmap () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Change vdiskprotectionenabled to yes
    if [ "$UNMAP_PROTECTION" = "yes" ] && $UNMAP_UNPROTECT ; then
        ssh "$STORAGEDEF" chsystem -vdiskprotectionenabled yes >/dev/null
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

AddVolumeGroupSnapshot () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Create a snapshot of volumegroup $1 with name $2
    if [ $# -lt 2 ] ; then
        return 1
    else
        typeset VGNAME="$1" SNAPNAME="$2"
        typeset RETENTION="-retentionminutes 10"
        ssh "$STORAGEDEF" addsnapshot -volumegroup "$VGNAME" -name "$SNAPNAME" $RETENTION >/dev/null
        if CheckSnapshotExistence "$SNAPNAME" ; then
            return 0
        else
            return 1
        fi
    fi
}

AddThinVolumeVolumeGroup () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Create a thin clone of a volumegroup snapshot
    if [ $# -lt 2 ] ; then
        exit 1
    else
        typeset VGNAME="$1" SNAPNAME="$2"
        ssh "$STORAGEDEF" mkvolumegroup -name "$SNAPNAME" -type thinclone -fromsourcegroup "$VGNAME" -snapshot "$SNAPNAME" >/dev/null
    fi
}

GetLastSnapVolumeGroup () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Get name of last volume group matching prefix and host
    ssh "$STORAGEDEF" lsvolumegroup -delim : -nohdr |
        awk -F: -v PREF="^$VOLUMEPREFIX" -v HOST="$STORAGEHOSTNAME" '
            BEGIN { PRE= PREF HOST "_[0-9][0-9]*$" }
            $2 ~ PRE { print $2 }
        ' | tail -n 1
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: flashsystem snapshot functions loaded.\n" >&2
}

CheckFlashSystem
