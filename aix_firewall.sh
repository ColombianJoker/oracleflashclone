#!/usr/bin/env ksh

CheckAIXFirewall () { [ -n "$DEBUG" ] && $DEBUG && set -x
    STATUS=$(lsdev -Cc ipsec -F name:status | grep _v4)
    if [ "$STATUS" != "ipsec_v4:Available" ] ; then
        mkdev -c ipsec -t4
    fi
    STATUS=$(lsdev -Cc ipsec -F name:status | grep _v4)
    if [ "$STATUS" != "ipsec_v4:Available" ] ; then
        printf "$PRGNAME: Could not activate IPSECv4, exiting ...\n" >&2
        exit 254
    fi
}

export RULE_TAG="ORACLE_DISCOVERY_BLOCK"

CleanRulesToBlockOut () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Cleans the blocking OUTbound rules following the RULE_TAG
    RULE_IDS=$(lsfilt -v 4 | awk -v RS= '/ORACLE_DISCOVERY_BLOCK/ {
        if (match($0, /Rule [0-9]+/)) {
            print substr($0, RSTART + 5, RLENGTH - 5)
        }
    }' | sort -rn)
    if [[ -z "$RULE_IDS" ]]; then
        printf "$PRGNAME: No rules found with description: '$RULE_TAG'\n" >&2
    else
        # Loop through and remove each rule by its Filter ID (FID)
        for FID in $RULE_IDS; do
            printf "$PRGNAME: Removing filter rule $FID...\n" >&2
            rmfilt -v 4 -n "$FID" >/dev/null
        done

        # Apply changes to the active kernel rules
        printf "$PRGNAME: Deactivating removed rules from kernel...\n" >&2
        mkfilt -v 4 -u
    fi
}

AddRulesToBlockOut () { [ -n "$DEBUG" ] && $DEBUG && set -x
# Blocks OUTbound connections to ports in $CLUSTERPORS on servers in $CLUSTERNODES
    for NODE in $CLUSTERNODES ; do
        for PORT in $CLUSTERPORTS; do
            printf "$PRGNAME: Blocking outbound connections to $NODE:$PORT/tcp...\n" >&2
            # -v 4                  : Version TCPv4
            # -a D                  : Action Deny
            # -s 0.0.0.0 -m 0.0.0.0 : Any local source IP
            # -c tcp                : Block TCP
            # -O eq -P $PORT        : port == $PORT
            # -w O                  : Outbound
            # -D DESCRIPTION        : Description
            genfilt -v 4 -a D -s 0.0.0.0 -m 0.0.0.0 -d "$NODE" -M 255.255.255.255 -c tcp -O eq -P "$PORT" -w O -D "$RULE_TAG" >/dev/null
        done
    done
    # Activate
    printf "$PRGNAME: Activating in-kernel firewall with new rules...\n" >&2
    mkfilt -v 4 -u
}

### --------- --------- --------- ---------
Loaded () {
    printf "$PRGNAME: AIX firewall functions loaded.\n" >&2
}
