#!/usr/bin/env bash
# This script makes sure the latest target.csv file is used in the backup job
# It does this by pulling from git, so any changes that is pushed in 
# the target.csv file will be reflected in the next backup job.
cd $(dirname $0)/SDP-backup
git pull https://oauth2:
chmod u+x backup_sdp.sh
./backup_sdp.sh