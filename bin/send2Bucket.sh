#!/bin/bash

# Arguments are:
#   $1 -- product source as FQPN
#   $2 -- destination built with S3ROOT environment variable

# product name comes from the product source FQPN

# send2Bucket.sh <source> <s3root>/<s3target>/<product>
# aws s3 cp <source> <target>

if [ $# -eq 2 ]; then
    # PRODUCT NAME FROM PQACT
    product_name=$(basename $1)

    if [ -f "$1" ]; then
        aws s3 cp $1 $S3ROOT/$2/$product_name
    else
        printf "File '%s' does not exist\n" $1
    fi
else
    printf "Script requires two arguments, <source> and <s3target>\n"
    exit 1
fi

# make sure to exit
exit 0
