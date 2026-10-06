#!/usr/bin/env ksh93
# Look for PRE_COMMAND

typeset PRE_COMMAND="${PRE_COMMAND:=oraclone_pre_command}"

if [ -f "${SCRIPTDIR}/${PRE_COMMAND}" ] && [ -x "${SCRIPTDIR}/${PRE_COMMAND}" ] ; then
    printf "\n" >&2
    printf "$PRGNAME: ${PRE_COMMAND} found, executing...\n" >&2
    printf "--------- --------- --------- ---------  " >&2
    printf "--------- --------- --------- ---------\n" >&2
    "${SCRIPTDIR}/${PRE_COMMAND}" ; RC=$?
    printf "--------- --------- --------- ---------  " >&2
    printf "--------- --------- --------- ---------\n" >&2
    printf "$PRGNAME: ${PRE_COMMAND} found, executed\n\n" >&2
    if [ $RC -ne 0 ] ; then
        printf "$PRGNAME: ${SCRIPTDIR}/${PRE_COMMAND} returned $RC, exiting...\n" >&2
        exit $RC
    fi
fi
