#!/usr/bin/env ksh

[ -n "$DEBUG" ] && $DEBUG && printf "$PRGNAME: Loading external functions...\n" >&2

DEFAULTSCRIPT="${SCRIPTDIR}/default_configuration"
if [ -f "$DEFAULTSCRIPT" ] && [ -r "$DEFAULTSCRIPT" ] && [ -x "$DEFAULTSCRIPT" ] ; then
    . "$DEFAULTSCRIPT"
    [ -n "$DEBUG" ] && $DEBUG && Loaded
else
    printf "$PRGNAME: Could not load the default configuration, exiting...\n" >&2
    exit 3
fi

SNAPSHOTSCRIPT="${SCRIPTDIR}/flashsystem_snapshots"
if [ -f "$SNAPSHOTSCRIPT" ] && [ -r "$SNAPSHOTSCRIPT" ] && [ -x "$SNAPSHOTSCRIPT" ] ; then
    . "$SNAPSHOTSCRIPT"
    [ -n "$DEBUG" ] && $DEBUG && Loaded
else
    printf "$PRGNAME: Could not load the snapshot script, exiting...\n" >&2
    exit 3
fi

VOLUMESCRIPT="${SCRIPTDIR}/flashsystem_volumes"
if [ -f "$VOLUMESCRIPT" ] && [ -r "$VOLUMESCRIPT" ] && [ -x "$VOLUMESCRIPT" ] ; then
    . "$VOLUMESCRIPT"
    [ -n "$DEBUG" ] && $DEBUG && Loaded
else
    printf "$PRGNAME: Could not load the flashsystem volume script, exiting...\n" >&2
    exit 3
fi

AIXPVSCRIPT="${SCRIPTDIR}/aix_physical_volumes"
if [ -f "$AIXPVSCRIPT" ] && [ -r "$AIXPVSCRIPT" ] && [ -x "$AIXPVSCRIPT" ] ; then
    . "$AIXPVSCRIPT"
    [ -n "$DEBUG" ] && $DEBUG && Loaded
else
    printf "$PRGNAME: Could not load the AIX pv script, exiting...\n" >&2
    exit 3
fi

AIXVGSCRIPT="${SCRIPTDIR}/aix_volume_groups"
if [ -f "$AIXVGSCRIPT" ] && [ -r "$AIXVGSCRIPT" ] && [ -x "$AIXVGSCRIPT" ] ; then
    . "$AIXVGSCRIPT"
    [ -n "$DEBUG" ] && $DEBUG && Loaded
else
    printf "$PRGNAME: Could not load the AIX vg script, exiting...\n" >&2
    exit 3
fi
