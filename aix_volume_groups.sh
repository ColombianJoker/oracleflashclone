#!/usr/bin/env ksh93

CheckAIXVGExistence () { [ -n "$DEBUG" && $DEBUG && set -x
# Check if there is a volumegroup with the chosen name $1
    if [ $# -eq 0 ] ; then
        false
    else
        VGNAME="$1"
        lsvg | fgrep -qw "$VGNAME"
    fi
}

ImportAIXVG () {
# Imports a volumegroup with name $1 from disk $2
    if [ $# -lt 2 ] ; then
        false
    else
        VGNAME="$1" DISKNAME="$2"
        importvg -y "$VGNAME" "$DISKNAME"
        if CheckAIXVGExistence "$SNAPNAME" ; then
            true
        else
            false
        fi
    fi
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: AIX volume group functions loaded.\n" >&2
}
