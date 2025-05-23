#!/bin/bash

# TODO: Write to a central location

# PID file location

VIDEOS_DIR="$HOME/.local/bin/scripts/recording/videos/"
# File which container save path for the recording to 
# be stopped
FILE_INFO="$VIDEOS_DIR/.ffmpeg_recording_file.txt"

# File with the running FFMPEG process ID
# We will send a kill signal to this process id
PID_FILE="$VIDEOS_DIR/.ffmpeg_recording.pid"

# Check if the PID file exists
if [ -f "$PID_FILE" ]; then
    # Get the PID
    PID=$(cat "$PID_FILE")
    
    # Get the output file path (if available)
    OUTPUT_FILE="Unknown location"
    if [ -f "$FILE_INFO" ]; then
        OUTPUT_FILE=$(cat "$FILE_INFO")
    fi
    
    # Send a quit signal to FFmpeg
    kill -TERM $PID
    
    # Remove the PID file and file info
    rm "$PID_FILE"
    [ -f "$FILE_INFO" ] && rm "$FILE_INFO"
    
    # Notify the user
    notify-send "Recording Stopped" "Your recording has been saved to: $OUTPUT_FILE"
else
    # Notify if no recording is in progress
    notify-send "No Recording" "No active recording found"
fi
