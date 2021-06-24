#!/bin/ksh
#
# checking to see if LDM isrunning
# if not running, $?=0, then messages are sent to stderr and ldm started
#

# check to see if the LDM server is running
ldmadmin isrunning
case $? in
    0)  printf "\n$(date) ---- ldm is running\n"
        ;;
    1)  printf "$(date) ---- ldm is NOT running\n" >&2
        printf "$(date) ---- attempting restart\n" >&2
        ldmadmin start -v >&2
        if [ $? -gt 0 ] ; then
            printf "$(date) ---- ldmadmin start failed\n" >&2
            printf "$(date) ---- will attempt delqueue, mkqueue, and ldmadmin start\n" >&2
            ldmadmin delqueue >&2
            ldmadmin mkqueue >&2
            ldmadmin clean >&2
            ldmadmin start -v >&2
        fi
        ;;
esac
