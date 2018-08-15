#!/usr/bin/env bash
# Usage
# backup_sdp.bash -f targets.csv -d /data/backup
#
#INPUT
#This script is designed to use a .CSV-file as input. The file must use ";" as a separator, and
#have the following columns;
#<computername>;<alternative computername>;<IP>,
#<"/folder/to/copy" "/second/folder/to/copy">;</folder/to/exclude /second/folder/to/exclude>
#
#Prerequisites
#Backup server being able to SSH to the targeted servers(as password less root)
#
#Not implemented(21.11.2017):
#User named 'backuper' on all involved systems. Must be able to read Targeted files, and write to Destination
#Recommended to use ACL
#example: setfacl -R -m u:backuper:r <targetfolder>

PATH=$PATH:/bin/rsync
TIMESTAMP=$(date +\%y.\%m.\%d_\%H.\%M)
LOGPATH="/tmp/"
LOGFILE=$LOGPATH"backup_report_"$TIMESTAMP".log"
echo "Redirecting stdout and stderr to $LOGFILE"
exec 1<>$LOGFILE
exec 2>&1

cd $(dirname $0)

# Argument parsing structure
while getopts ":f:d:" opt; do
  case $opt in
    f)
      INPUT_CSV=$OPTARG
      ;;
    d)
      DESTINATION=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      echo "Usage: backup_sdp.bash [-f <input csv file>] [-d <destination path for backup>]"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

# Set default input file
[ -z  ${INPUT_CSV} ] && INPUT_CSV='targets.csv'
# Set default backup location
[ -z ${DESTINATION} ] && DESTINATION='/zfs/backup'

if [ ! -f ${INPUT_CSV} ]; then
    echo "Can't find $INPUT_CSV...exiting"
    exit 1
fi

echo "Input file is: $INPUT_CSV"
echo "Backup destination is: $DESTINATION"
echo "Started job @ $(date --rfc-3339=seconds)"

# Iterate through the input .csv file and perform rsync backup.
IFS=';'
while read COMPUTERNAME ALT_HOSTNAME IP DIR EXCLUDE
do
    # Check if line is commented and jump to next iteration
    [[ $COMPUTERNAME =~ ^\# ]] && continue
    #Create directory for computername in target dir
    CNAME_PATH=$DESTINATION/$ALT_HOSTNAME/
    [ ! -d $CNAME_PATH ] && mkdir -v $CNAME_PATH

    IFS=' ' read -r -a EXCLUDELIST <<< "$EXCLUDE"
    for i in "${EXCLUDELIST[@]}"; do
        ROPTION+=("--exclude=$i")
    done

    echo "Working on node: $ALT_HOSTNAME..."
    rsync -aiqe "ssh -o StrictHostKeyChecking=no" --delete-during --numeric-ids\
    ${ROPTION[@]} root@$COMPUTERNAME:$DIR \
    $CNAME_PATH

    ROPTION=()
    EXCLUDELIST=()

done < $INPUT_CSV

echo "Backup job finnished @ $(date --rfc-3339=seconds)"
echo " The job took $(date -u -d @${SECONDS} +"%T".)"
echo " "
exit 0