#!/usr/bin/env ksh93
# Sample: find the default gateway and ping it

typeset GWADDRESS=$(netstat -nr | awk '$1=="default" {print $2; exit}')
typeset -i COUNT=3

if [ -n "$GWADDRESS" ] ; then
    ping -c $COUNT "$GWADDRESS"
    false
else
    printf "$PRGNAME: gateway address not found!\n" >&2
    exit 1
fi
