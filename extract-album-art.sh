#! /bin/bash
START=$(date +%s)
EXTRACTED_IMAGES=0
function extract_coverart_recursively {
    FOLDER=$1
    SUBFOLDERS=$(find $FOLDER -mindepth 1 -type d)
    if [ -z "$SUBFOLDERS" ]; then
        echo " $FOLDER has no subfolders. Assuming album folder. "
        if [ ! -f $FOLDER/cover.jpg ]; then
            FIRST_MP_FILE=$(ls -1 "$FOLDER"/*.mp* | head -1)
            if [ ! -z "$FIRST_MP_FILE" ]; then
                printf "${CYAN} Extracting from $FIRST_MP_FILE....${NO_COLOR}\n"
                ffmpeg -hide_banner -loglevel error -i "$FIRST_MP_FILE" "$FOLDER/cover.jpg" && EXTRACTED_IMAGES=$(($EXTRACTED_IMAGES+1))
            else
                printf "${RED}Could not find a file mathing '*.mp*'. Nothing more I can do right now...${NO_COLOR}\n"
            fi
        else
            printf "${GREEN}$FOLDER already has a 'cover.jpg' file${NO_COLOR}\n"
        fi
        echo "#############################"

    else
        for i in $SUBFOLDERS; do
            extract_coverart_recursively $i
        done;
    fi
}

IFS='
'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NO_COLOR='\033[0m'
for folder in $(find . -mindepth 1 -type d); do
    extract_coverart_recursively $folder
done;

END=$(date +%s)
RUNTIME=$((END-START))
echo ""
echo "The runtime was;"
eval "echo $(date -ud "@$RUNTIME" +'$((%s/3600/24)) days %H hours %M minutes %S seconds')"
echo "Cover art files succesfully extracted;"
echo      $EXTRACTED_IMAGES