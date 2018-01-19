#!/usr/bin/env bash
PUPPETMASTER_FQDN="puppet.???.no"
PUPPETMASTER_API_PORT="8080"
TARGETS_LOC="/home/backup/SDP-backup/targets.csv"
export NO_PROXY=$PUPPETMASTER_FQDN

# Query the Puppet masters API for a json-list of all managed nodes.
# Format the json output to an whitespace separated array containing only the alternative hostnames.
HOST_ARRAY=($(curl --silent "http://$PUPPETMASTER_FQDN:$PUPPETMASTER_API_PORT/pdb/query/v4/nodes" |
 python -m json.tool |
 grep certname |
 cut --delimiter ":" --fields 2 |
 tr --delete [:blank:]\", ))

# Nested for-loop. Checks if any hostname matches any script parameters on wildcard.
# Loop through the scripts parameter list and remove any occurrences in the array.
for i in ${HOST_ARRAY[@]}; do
    for c in "$@"; do
        if [[ "$i" == *"$c"* ]]; then
            HOST_ARRAY=($(echo ${HOST_ARRAY[@]} | sed "s/$i//g"))
        fi
    done
done


# Loop through the array and grep for the hostname in the 'targets.csv' file used in the backup-job.
for i in ${HOST_ARRAY[@]}; do
    # If grep returns 1, the hostname is added to the 'NO_BACKUP'-string.
    if ! grep --quiet "$i" "$TARGETS_LOC"; then
        NO_BACKUP="$i, $NO_BACKUP"
    fi
done

if [ -z "$NO_BACKUP" ]; then
      echo "All hostnames found in targets.csv. Something is likely to be backedup..."
      exit 0
else
    echo -e "BACKUP WARNING - These hosts are not mentioned in the 'targets.csv'-file:\n
    $NO_BACKUP\n
    You can add them at 'https://git.???/targets.csv'. You can exclude the host from this sensu-check by adding the
    hostname to the check command as parameters. The command is found at 'PUPPET/environment/data/nodes/backup01'."
    exit 1
fi
