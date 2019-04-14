#! /bin/bash

# WIN_ID_HEX=$(wmctrl -l | grep MusicBee | cut -f 1 -d ' ')
# WIN_ID=$(printf '%d\n' $WIN_ID_HEX)
# CURRENT_WIN=$(xdotool getactivewindow)

# xdotool windowactivate $"WIN_ID" key --clearmodifiers ctrl+p
# xdotool  windowactivate $"CURRENT_WIN"s
WIN_ID=$(xdotool search --name " - MusicBee")
xdotool windowfocus $WIN_ID
xdotool windowactivate $WIN_ID
xdotool search --name " - MusicBee" key --clearmodifiers ctrl+p
