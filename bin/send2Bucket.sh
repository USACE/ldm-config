#!/bin/bash

# Need to know the s3 bucket root path
# Need to know the s3 level 1 directory "cumulus"
# Need to know the s3 level 2 directory "product name with some modification"
# Need to know the s3 level 3 directory "ldm"
# Need to know the s3 level 4 directory "CONUS, CARIB, GUAM, etc"

# product name
# MRMS_MultiSensor_QPE_01H_Pass1_00.00_yyyymmdd-hhmmss.grib2.gz

# product location
# s3://corpsmap-data-incoming/cumulus/ncep_mrms_v12_MultiSensor_QPE_01H_Pass1

function usage(){
    echo "Argument 1 is the path to the s3 bucket"
    echo "Argument 2 is the product FQPN"
}

