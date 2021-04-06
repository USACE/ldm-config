#!/bin/bash
function usage(){
    printf "\n$(basename $0) [OPTIONS]\n"
    cat $0 | grep -E "[$1]\)  # --.*$"
    exit 0
}

# Check no arguments
[ $# -eq 0 ] \
    && printf "No arguments provided and exiting\n"


: ${DATALOAD_S3_ROOT:?"AWS S3 root path not defined; Exiting Script"}

while getopts "f:l:p:s:u" option; do
    case "$option" in
        f)  # -- Fully Qualified Path Name to file
            fqpn=${OPTARG}
            ;;
        l)  # -- location (CONUS, CARIB, HAWAII, etc)
            location=${OPTARG^^}
            ;;
        s)  # -- sublocation (directory level below location)
            sublocation=${OPTARG}
            ;;
        p)  # -- Project name (instrumentation, cumulus, etc)
            # make sure it is lower case
            project=${OPTARG,,}
            ;;
        u)  # -- Print usage message
            usage "a-z"
            ;;
    esac
done
shift $(($OPTIND - 1))

[ -z $fqpn ] \
    && printf "'Filename' not defined and exiting\n" \
    && usage "f"
[ -z $project ] \
    && printf "'Project' not defined and exiting\n" \
    && usage "p"
[ -z $location ] \
    && printf "'Location' not defined and exiting\n" \
    && usage "l"
[ -z $sublocation ] \
    && printf "'Subocation' not defined and exiting\n" \
    && usage "s"

filename=$(basename $fqpn)
s3_destination="$DATALOAD_S3_ROOT/$project/ldm/$location/$sublocation/$filename"

[ -z $AWS_ENDPOINT_URL ] \
    && aws s3 cp "$fqpn" "$s3_destination" \
    || aws s3 cp --endpoint-url "$AWS_ENDPOINT_URL" "$fqpn" "$s3_destination"

# make sure to exit
exit 0
