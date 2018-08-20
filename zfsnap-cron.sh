#!/bin/bash
# A script meant to be run as a cron job to manage snapshots of a system running ZFS
# Prerequisites
#       - A ZFS resource (pool or filesystem)
#       - The zfsnap utility (https://github.com/zfsnap/zfsnap)
# Path to zfsnap.sh
ZFSNAP_INSTALL_PATH="/zfs/filesystem/zfsnap/sbin"
# Include zfsnap in PATH
PATH="$PATH:$ZFSNAP_INSTALL_PATH"
# The zfs resource to perform recursive snapshots of
ZFS_RESOURCE=(tank)
# Set the Time To Live for the different snapshot-categories.
# y = years, m = months, w = weeks, d = days, h = hours, M = minutes, s = seconds
TTL_DAILY="7d"
TTL_WEEKLY="5w"
TTL_MONTHLY="6m"

# Call the same script from cron with 3 different arguments. To minimize "config" in crontab.
if [ "$1" = "daily" ]; then
    for i in ${ZFS_RESOURCE[@]}; do
        # Create a snapshot with the 'daily' TTL with a prefix. Recursively on the ZFS resource.
        zfsnap.sh snapshot -v -z -a $TTL_DAILY -p 'DAILY-' -r $i
        # Also destroy all expired snapshots daily
        zfsnap.sh destroy -v -p 'DAILY-' -p 'WEEKLY-' -p 'MONTHLY-' -r $i
    done
elif [ "$1" = "weekly" ]; then
    for i in ${ZFS_RESOURCE[@]}; do
        zfsnap.sh snapshot -v -z -a $TTL_WEEKLY -p 'WEEKLY-' -r $i
    done
elif [ "$1" = "monthly" ]; then
    for i in ${ZFS_RESOURCE[@]}; do
        zfsnap.sh snapshot -v -z -a $TTL_MONTHLY -p 'MONTHLY-' -r $i
    done
else
    echo "Error: Requires atleast one argument."
    exit 1
fi
exit 0
