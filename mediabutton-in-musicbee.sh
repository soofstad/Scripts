#! /bin/bash

# MBEE_ID_HEX=$(wmctrl -l | grep MusicBee | cut -f 1 -d ' ')
# MBEE_ID=$(printf '%d\n' $MBEE_ID_HEX)
# CURRENT_WIN=$(xdotool getactivewindow)

# xdotool windowactivate $"MBEE_ID" key --clearmodifiers ctrl+p
# xdotool  windowactivate $"CURRENT_WIN"s

ACTIVEWINDOW=$(xdotool getactivewindow)
MBEE_ID=$(xdotool search --name " - MusicBee")
xdotool windowfocus $MBEE_ID
xdotool windowactivate $MBEE_ID
xdotool search --name " - MusicBee" key --clearmodifiers ctrl+p
xdotool windowactivate $ACTIVEWINDOW
