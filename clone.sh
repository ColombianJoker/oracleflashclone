#!/usr/bin/env ksh
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
  printf "  VOLUMEPREFIX=$VOLUMEPREFIX\n"
  printf "  HDISKPREFIX=$HDISKPREFIX\n"
  printf "  CLUSTERNODES=$CLUSTERNODES\n"
  printf "  CLUSTERPORTS=$CLUSTERPORTS\n"
}

[ -n "$DEBUG" ] && $DEBUG && set -x

if [ -n "$1" ] && [ "$1" == "do" ] ; then
    if [ -n "$2" ] ; then
        printf "$PRGNAME: Trying to use '$2' for configuration...\n" >&2
        if [ -f "$2" ] && [ -r "$2" ] && [ -x "$2" ] ; then
            . "$2"
        else
            printf "$PRGNAME: Could not use '$2', check existence, and rx mode...\n" >&2
            exit 1
        fi
    else
        printf "$PRGNAME: Too few arguments!\n" >&2
        ShowSyntax >&2
        exit 2
    fi

    # ------------ MAIN ------------
    printf "$PRGNAME: Scanning..." >&2
    DetectAIXDisks
    printf " done\n" >&2
    printf "$PRGNAME: Mapped disks -----------------------------------------------\n" >&2
    ListFilteredMappedVolumes "$STORAGEHOSTNAME" dbs_
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
