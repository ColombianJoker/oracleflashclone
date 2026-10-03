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

ShowSyntax () {
    printf "$PRGNAME creates clones of databases on FlashSystems\n"
    printf "Syntax:\n"
    printf "  $PRGNAME [ do ] config_file\n"
    printf "  $PRGNAME\n"
    printf "\n"
    printf "Without arguments shows this help\n"
    printf "With a config_file, shows the configuration parameters (variables)\n"
    printf "With 'do' and a configuration file, runs with the parameters\n"
}

PrintConfiguration () {
  # Show configuration
  printf "$PRGNAME configuration:\n"
  printf "  DEBUG=$DEBUG\n"
  printf "  STORAGEDEF=$STORAGEDEF\n"
  printf "  VOLUMEGROUP=$VOLUMEGROUP\n"
  printf "  SOURCECLUSTER=$SOURCECLUSTER\n"
  printf "  VOLUMEPREFIX=$VOLUMEPREFIX\n"
  printf "  HDISKPREFIX=$HDISKPREFIX\n"
  printf "  CLUSTERNODES=$CLUSTERNODES\n"
  printf "  CLUSTERPORTS=$CLUSTERPORTS\n"
  printf "  OWNERSHIP=$OWNERSHIP\n"
}

[ -n "$DEBUG" ] && $DEBUG && set -x

if [ -n "$1" ] && [ "$1" == "do" ] ; then
    if [ -n "$2" ] ; then
        printf "$PRGNAME: Trying to use '$2' for configuration..." >&2
        if [ -f "$2" ] && [ -r "$2" ] && [ -x "$2" ] ; then
            printf " found.\n" >&2
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
    DetectAIXDisks
    printf " done\n" >&2
    # printf "$PRGNAME: Mapped disks -----------------------------------------------\n" >&2
    # ListSnapshotDisks "$VOLUMEPREFIX" | while read hdiskname volname ; do
    #     printf "$volname\t%s\n" $(CalculateHdiskName $volname) >&2
    # done
    CLONED_DISKS=$(ListClonedDisks)
    if [ -n "$CLONED_DISKS" ] ; then
        printf "$PRGNAME: Old cloned disks found mapped, removing...\n" >&2
        RemoveDisks $CLONED_DISKS
    fi
    export START_LUN=$(( $(GetMaxLUN) + ${LUNDELTA:=10} ))
    # printf "%s: New LUN start: %d\n" "$PRGNAME" "$START_LUN" >&2
    LAST_VG_SNAP=$(GetLastSnapVolumeGroup)
    if [ -n "$LAST_VG_SNAP" ] ; then
        printf "$PRGNAME: Last snapshot volume group found: $LAST_VG_SNAP\n" >&2
        VOLUMES_TO_MAP=$(ListVolumePopulation "$LAST_VG_SNAP")
        MapVolumes $VOLUMES_TO_MAP
        DetectAIXDisks
        CLONED_DISKS=$(ListClonedDisks)
        if [ -n "$CLONED_DISKS" ] ; then
            RenameClonedDisks $CLONED_DISKS
        fi
        CLONED_DISKS=$(ListClonedDisks) # Names changed
        if [ -n "$CLONED_DISKS" ] ; then
            AdjustClonedDisks $CLONED_DISKS
        fi
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
