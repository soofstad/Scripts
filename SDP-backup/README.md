# Backup SDP
Scripts used to backup SDP resources. Intended to be run as a cronjob. Requires minimal configuration of nodes.

The main backup script can be used in two ways.
1. Backup directories manually defined in a CSV-file
2. Backup directories from an auto-generated CSV-file based on which directories are mounted in Docker Containers.

Prerequisites
* The server running the script (the backup server) must be able to do a passwordless SSH login to all the target nodes(SSH Authorized_Keys).
* On servers not hosted in AWS, the backup server must be allowed in the files '/etc/security/access'
* The 'target.csv'-file must have an empty new-line at EOF...

## 1# Manual CSV
### How to
1. Update the input file to reflect the desired backup operation. Default is './targets.csv'.
 * Format: FQDN;[Alternative-DNS-name];[IP-Address];"DIR-to-backup" "Second-DIR-to-backup";[Sub-DIR-to-exclude]
2. The script 'backup_sdp.bash' must be run as root
3. Default input file is './targets.csv' and default destination is '/data/backup/'. Other values can be specified with '-f' and '-d'.

## 2# Auto-generated CSV-file
### How to
1. In 'docker-nodes.txt' define which nodes running docker containers should be included in the job
2. Run 'python make-csv-from-container.py'. This will create the file 'py_targets.csv'.
3. Run the main backup script with '--file=py_targets.csv'