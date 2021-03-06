#!/bin/bash

# limit max number of open files to force pqact to close open file descriptors.
ulimit -n 1024

set -e
set -x
export PATH=/home/ldm/bin:$PATH

# Create the .appkey files for stable and develop
$(python /home/ldm/local/bin/appkey.py stable)
$(python /home/ldm/local/bin/appkey.py develop)

# Get the environment variables and put them in .bashrc for crontab
echo > /home/ldm/.bashrc
for row in $(env)
do
    SAVEIFS=$IFS
    IFS="="
    read key val <<< "$row"
    IFS=$SAVEIFS
    if [[ "$key" == "AWS"* ]]
    then
        echo "export ${key}=${val}" >> /home/ldm/.bashrc
    fi
done


trap "echo TRAPed signal" HUP INT QUIT KILL TERM

/usr/sbin/crond

regutil -s docker.localhost.local /hostname

if [ ! -f /home/ldm/var/queues/ldm.pq ]
then
    echo "The product queue file home/ldm/var/queues/ldm.pq does not exist. Making new queue."
    ldmadmin mkqueue
else
    # queue exists, test queue "sanity"
    echo "Checking existing product queue with 'pqcat'"
    pqcat -l- -s && pqcheck -F
    if [ $? -eq 0 ]
    then
        echo "Using existing LDM product queue."
    else
        echo "Product queue appears corrupt. Deleting and rebuilding."
        ldmadmin delqueue
        ldmadmin mkqueue
    fi
fi

# In case of unclean shutdown, remove pid and lck files
echo "Running 'ldmadmin clean'."
ldmadmin clean
echo "Starting LDM..."
ldmadmin start
echo "LDM is running."

# never exit
while true; do sleep 10000; done

#ldmadmin watch

#sleep 10

#echo ""
#echo ""
#echo "Hit [RETURN] to exit"
#read
