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
    cfgmgr
}

ListSnapshotDisks () { [ -n "$DEBUG" ] && $DEBUG && set -x
# List disks coming from volumes matching a prefix
    if [ $# -eq 0 ] ; then
        return 1
    else
        typeset PREF="$1"
        lsmpio -q | awk -v PREF="^$PREF" '$NF~PREF{print $1, $NF}'
    fi
}

CalculateHdiskName () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Generate a name for an hdisk from a volume name in $1
    if [ $# -lt 1 ] ; then
        return 0
    else
        typeset BASENAME="${BASENAME:=hdisk}"
        typeset VOL="$1"
        typeset LASTPART="${VOL##*_}"
        typeset LETTER="${LASTPART:0:1}"
        typeset NUMBERS="${LASTPART##*[^0-9]}"
        typeset NEWNAME="${HDISKPREFIX}${LETTER}${BASENAME}${NUMBERS}"
        echo "$NEWNAME"
    fi
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: AIX physical volume functions loaded.\n" >&2
}
