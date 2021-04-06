#!/bin/bash
function usage(){
    printf "\n$(basename $0) [OPTIONS]\n"
    cat $0 | grep -E "[a-z]\)  # --.*$"
    exit 0
}

# Check no arguments
[ $# -eq 0 ] \
    && printf "No arguments provided and exiting\n"


: ${DATALOAD_S3_ROOT:?"AWS S3 root path not defined; Exiting Script"}

while getopts "f:l:p:u" option; do
    case "$option" in
        f)  # -- Fully Qualified Path Name to file
            fqpn=${OPTARG}
            ;;
        l)  # -- location (CONUS, CARIB, HAWAII, etc)
            location=${OPTARG}
            ;;
        p)  # -- Project name (instrumentation, cumulus, etc)
            project=${OPTARG}
            ;;
        u)  # -- Print usage message
            usage
            ;;
    esac
done
shift $(($OPTIND - 1))

[ -z $fqpn ] \
    && printf "Filename not defined and exiting\n" \
    && usage
[ -z $project ] \
    && printf "Project not defined and exiting\n" \
    && usage
[ -z $location ] \
    && printf "Location not defined and exiting\n" \
    && usage

filename=$(basename $fqpn)
s3_destination="$DATALOAD_S3_ROOT/$project/ldm/$location/$filename"

[ -z $AWS_ENDPOINT_URL ] \
    && aws s3 cp "$fqpn" "$s3_destination" \
    || aws s3 cp --endpoint-url "$AWS_ENDPOINT_URL" "$fqpn" "$s3_destination"

# make sure to exit
exit 0
