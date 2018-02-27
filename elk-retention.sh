#!/usr/bin/env bash
ELK_ENDPOINT="localhost:9200/"
ELK_INDICES="filebeat-"
ELK_CLOSE_TIME_MONTHS="2"
ELK_DELETE_TIME_MONTHS="6"

# Close INDICES
CLOSE_DATE=$(date -d "-${ELK_CLOSE_TIME_MONTHS} month" +%Y.%m.)
echo -e "Closing indices using this filter:\n${ELK_ENDPOINT}${ELK_INDICES}${CLOSE_DATE}*"
curl -XPORT "${ELK_ENDPOINT}${ELK_INDICES}${CLOSE_DATE}*/_flush"
curl -XPORT "${ELK_ENDPOINT}${ELK_INDICES}${CLOSE_DATE}*/_close"

# Delete INDICES
DELETE_DATE=$(date -d "-${ELK_DELETE_TIME_MONTHS} month" +%Y.%m)
echo -e "Deleting indices using this filter:\n${ELK_ENDPOINT}${ELK_INDICES}${DELETE_DATE}*"
curl -XDELETE "${ELK_ENDPOINT}${ELK_INDICES}${CLOSE_DATE}*"