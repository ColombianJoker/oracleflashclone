#!/usr/bin/env ksh93

CheckAIXDiskExistence () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Check if there is a disk with the chosen name $1
    if [ $# -eq 0 ]; then
        return 1
    fi
    # lspv directly returns exit status 0 if disk exists, non-zero if not
    lspv "$1" >/dev/null 2>&1
}

DetectAIXDisks () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Detect all disks
    printf "$PRGNAME: Scanning..." >&2
    cfgmgr
    printf " done\n" >&2
}

ListSnapshotVolumes () { [ -n "$DEBUG" ] && $DEBUG && set -x
# List disks coming from volumes matching a prefix
    if [ $# -eq 0 ] ; then
        return 1
    else
        for DISK in $@ ; do
            lsmpio -ql "$DISK" | awk -v PREF="^$VOLUMEPREFIX" -v SRC="$SOURCECLUSTER" '
                BEGIN {PRE= PREF SRC}
                $NF ~ PRE {print $NF}
            '
        done | sed 's/\n/ /g'
    fi
}

CalculateHdiskName () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Generate a name for an hdisk from a volume name in $1
    if [ $# -lt 1 ] ; then
        return 0
    else
        typeset BASENAME="${BASENAME:=hdisk}"
        typeset VOL="$1"
        typeset VOL="${VOL%-[0-9]?([0-9])}" # Remove -XX part
        typeset LASTPART="${VOL##*_}"
        typeset LETTER="${LASTPART:0:1}"
        typeset NUMBERS="${LASTPART##*[^0-9]}"
        typeset NEWNAME="${HDISKPREFIX}${LETTER}${BASENAME}${NUMBERS}"
        echo "$NEWNAME"
    fi
}

GetMaxLUN () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Get the highest LUN of mapped disks
    for DISK in $(lsdev -c disk -S Available -F name) ; do
        LUN=$(lsattr -El "$DISK" -F value -a lun_id | sed 's/............$//')
        echo $(($LUN))
    done | sort -n | tail -1
}

ListClonedDisks () { [ -n "$DEBUG" ] && $DEBUG && set -x
# List hdisk names of cloned disks, filtering using $VOLUMEPREFIX and $SOURCECLUSTER
    for DISK in $(lsdev -c disk -F name) ; do
        VOLNAME=$(lsmpio -ql "$DISK" |
            awk -v PREF="^$VOLUMEPREFIX" -v SRC="$SOURCECLUSTER" '
                BEGIN { PRE=PREF SRC "_.*[0-9][0-9]*-[0-9][0-9]*$" }
                $1=="Volume" && $2=="Name:" && $NF ~ PRE { print $NF }
            ')
        [ -n "$VOLNAME" ] && printf "$DISK\n"
    done
}

RemoveDisks () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Remove disk devices given
    if [ $# -eq 0 ] ; then
        return 1
    else
        for DISK in "$@" ; do
            rmdev -dl "$DISK" >/dev/null
        done
    fi
}

GetVolumeForDisk () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Get volume name for disk device # NOTE: FAILS FOR VERY LONG
    if [ $# -eq 0 ] ; then
        return 1
    else
        typeset DISK="$1"
        lsmpio -ql "$DISK"  2>/dev/null | awk '
            $1=="Volume" && $2=="Name:" { print $3 }
        '
    fi
}

RenameClonedDisks () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Rename cloned disks to avoid conflicts with source disks
    typeset -i COUNT=0
    for DISK in "$@" ; do
        typeset VOLUME=$(GetVolumeForDisk "$DISK")
        if [ -n "$VOLUME" ] ; then
            typeset CALCULATED=$(CalculateHdiskName "$VOLUME")
            if [ -n "$CALCULATED" ] && [ "$CALCULATED" != "$DISK" ] ; then
                rendev -l "$DISK" -n "$CALCULATED" >/dev/null 2>&1 && let COUNT=COUNT+1
            fi
        fi
    done
    printf "$PRGNAME: $COUNT disks renamed\n" >&2
}

AdjustClonedDisks () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Set owner and permissiones
    typeset MODE="${RAWMODE:=ug=rw,o-rwx}"
    typeset OWNERSHIP="${RAWOWNER:=oracle:asm}"

    for DISK in "$@" ; do
        chown $OWNERSHIP "/dev/r$DISK"
        chmod $MODE "/dev/r$DISK"
    done
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: AIX physical volume functions loaded.\n" >&2
}
