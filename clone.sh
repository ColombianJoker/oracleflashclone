#!/usr/bin/env ksh93
#
export PRGNAME=$(basename "$0" .sh)

SCRIPTDIR=$(dirname "$0")
EXTERNAL="${SCRIPTDIR}/load_external_functions"
if [ -f "$EXTERNAL" ] && [ -r "$EXTERNAL" ] && [ -x "$EXTERNAL" ] ; then
    . "$EXTERNAL"
    [ -n "$DEBUG" ] && $DEBUG && Loaded
else
    printf "$PRGNAME: Could not load the default configuration, exiting...\n" >&2
    exit 3
fi

[ -n "$DEBUG" ] && $DEBUG && set -x

if [ -n "$1" ] && [ "$1" == "do" ] ; then
    if [ -n "$2" ] ; then
        printf "$PRGNAME: Trying to use '$2' for configuration..." >&2
        if [ -f "$2" ] && [ -r "$2" ] && [ -x "$2" ] ; then
            printf " done.\n" >&2
            . "$2"
        else
            printf "\n" >&2
            printf "$PRGNAME: Could not use '$2', check existence, and rx mode...\n" >&2
            exit 1
        fi
    else
        printf "$PRGNAME: Too few arguments!\n" >&2
        ShowSyntax >&2
        exit 2
    fi

    # ------------ MAIN ------------
    CLONED_DISKS=$(ListClonedDisks)

    if [ -n "$CLONED_DISKS" ] ; then
        printf "$PRGNAME: Getting volume names for old cloned disks..." >&2
        VOLUMES=$(ListSnapshotVolumes "$CLONED_DISKS")
        printf " done\n" >&2
        # printf "$PRGNAME: Volumes to unmap: ${VOLUMES}\n" >&2
    fi

    if [ -n "$CLONED_DISKS" ] ; then
        printf "$PRGNAME: Old cloned disks found mapped, removing..." >&2
        RemoveDisks $CLONED_DISKS
        printf " done\n" >&2
    fi

    if [ -n "$VOLUMES" ] ; then
        printf "$PRGNAME: Removing mappings of old cloned volumes..." >&2
        UnmapVolumes $VOLUMES
        printf " done.\n" >&2
        ProtectUnmap
    fi

    NEW_VG_SNAP_NAME="${VOLUMEPREFIX}${STORAGEHOSTNAME}_"$(date +'%Y%m%d%H%M')
    printf "$PRGNAME: Creating new volumegroup snapshot %s..." "$NEW_VG_SNAP_NAME" >&2
    AddVolumeGroupSnapshot "$VOLUMEGROUP" "$NEW_VG_SNAP_NAME"
    printf " done\n" >&2
    printf "$PRGNAME: Creating thin clone volumegroup %s..." "$NEW_VG_SNAP_NAME" >&2
    AddThinVolumeVolumeGroup "$VOLUMEGROUP" "$NEW_VG_SNAP_NAME"
    printf " done\n" >&2
    export START_LUN=$(( $(GetMaxLUN) + ${LUNDELTA:=10} ))
    LAST_VG_SNAP=$(GetLastSnapVolumeGroup)
    if [ -n "$LAST_VG_SNAP" ] ; then
        printf "$PRGNAME: Last snapshot volume group found: $LAST_VG_SNAP\n" >&2
        printf "$PRGNAME: Getting volume population..." >&2
        VOLUMES_TO_MAP=$(ListVolumePopulation "$LAST_VG_SNAP")
        printf " done\n" >&2
        printf "$PRGNAME: Mapping volumes..." >&2
        MapVolumes $VOLUMES_TO_MAP
        printf " done\n" >&2
        DetectAIXDisks
        CLONED_DISKS=$(ListClonedDisks)
        if [ -n "$CLONED_DISKS" ] ; then
            printf "$PRGNAME: Renaming cloned disk devices...\n" >&2
            RenameClonedDisks $CLONED_DISKS
        fi
        CLONED_DISKS=$(ListClonedDisks) # Names changed
        if [ -n "$CLONED_DISKS" ] ; then
            printf "$PRGNAME: Adjusting permissions of raw disk devices..." >&2
            AdjustClonedDisks $CLONED_DISKS
            printf " done\n" >&2
        fi
    else
        printf "$PRGNAME: Exiting because could not find a volumegroup from snapshots...\n" >&2
        exit 3
    fi
    CleanRulesToBlockOut
    AddRulesToBlockOut
elif [ -n "$1" ] ; then
    . "$2"
    PrintConfiguration
    exit 0
else
    ShowSyntax >&2
    . "$DEFAULTSCRIPT"
    printf "\n" >&2
    PrintConfiguration >&2
    exit 0
fi
