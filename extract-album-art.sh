#! /bin/bash
START=$(date +%s)
EXTRACTED_IMAGES=0

while getopts "h?v:" opt; do
    case "$opt" in
    h|\?)
        echo "Will run in standing directory"
        echo "-v: Verbose mode"
        exit 0
        ;;
    v)  verbose=1
        ;;
    esac
done

function log () {
    if [[ $verbose -eq 1 ]]; then
        printf "$@"
    fi
}

# Cheking for dependencies
hash ffmpeg || { echo "Error: ffmpeg not found in PATH. Exiting...";  exit 1; }
hash metaflac || { echo "Error: metaflac not found in PATH. Exiting...";  exit 1; }

function extract_coverart_recursively {
    FOLDER=$1
    SUBFOLDERS=$(find $FOLDER -mindepth 1 -type d)
    if [ -z "$SUBFOLDERS" ]; then
        log " $FOLDER has no subfolders. Assuming album folder. "
        if [ ! -f $FOLDER/cover.jpg ]; then
            FIRST_MP3_FILE=$(ls -1 "$FOLDER"/*.mp* 2>/dev/null | head -1)
            FIRST_FLAC_FILE=$(ls -1 "$FOLDER"/*.flac* 2>/dev/null | head -1)
            if [ ! -z "$FIRST_MP3_FILE" ]; then
                printf "${CYAN} Extracting from $FIRST_MP3_FILE....${NO_COLOR}\n"
                ffmpeg -hide_banner -loglevel error -i "$FIRST_MP3_FILE" "$FOLDER/cover.jpg" && EXTRACTED_IMAGES=$(($EXTRACTED_IMAGES+1))
            elif [ ! -z "$FIRST_FLAC_FILE" ]; then
                printf "${CYAN} Extracting from $FIRST_FLAC_FILE....${NO_COLOR}\n"
                metaflac --export-picture-to="$FOLDER/cover.jpg" "$FIRST_FLAC_FILE" && EXTRACTED_IMAGES=$(($EXTRACTED_IMAGES+1))
            else
                log "${RED}Could not find a file mathing '*.mp*' or *.flac*.${NO_COLOR}\n"
            fi
        else
            log "${GREEN}$FOLDER already has a 'cover.jpg' file${NO_COLOR}\n"
        fi
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
