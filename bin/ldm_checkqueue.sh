#!/bin/ksh
#
# Test product queue for corruption and recreate as necessary
#

if [ pqcheck ] ; then
    echo "Success.  Product-queue was opened and the write-count is zero."
else
    case $? in
    1)  echo "Exit Status 1.  A system-error occurred. Aborting..." >&2
        ;;
    2)  echo "Exit Status 2.  No write-count.  Adding write-count capability" >&2
        if [ ! pqcheck -F ] ; then
            echo "pqcheck -F abort..." >&2
        fi
        ;;
    3)  echo "Product-queue opened but write-count is positive" >&2
        if [ pqcat -s -l /dev/null ] ; then
            echo "Product-queue appears OK.  Clearing write-count." >&2
            if [ ! pqcheck -F ] ; then
                echo "pqcheck -F abort..." >&2
            fi
        else
            echo "Product-queue appears corrupt.  Recreating..." >&2
            #/bin/mv -f /share/hldmcwms/ldm.pq /share/hldmcwms/ldm.pq.save
            ldmadmin delqueue >&2
            ldmadmin mkqueue >&2
            ldmadmin clean >&2
            ldmadmin start -v >&2
        fi
        ;;
    4)  echo "Product-queue could not be opened, internally inconsistent" >&2
        echo "It will be deleted and recreated" >&2
            #/bin/mv -f /share/hldmcwms/ldm.pq /share/hldmcwms/ldm.pq.save
            ldmadmin delqueue >&2
            ldmadmin mkqueue >&2
            ldmadmin clean >&2
            ldmadmin start -v >&2
        ;;
    esac
fi
