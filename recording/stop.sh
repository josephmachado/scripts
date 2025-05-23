#!/bin/bash

# PID file location
PID_FILE="$HOME/.ffmpeg_recording.pid"
FILE_INFO="$HOME/.ffmpeg_recording_file.txt"

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
    # Modify the stop script to add this after the 'rm "$PID_FILE"' line:
    if [ -f "$HOME/.zenity_pid" ]; then
        kill $(cat "$HOME/.zenity_pid")
        rm "$HOME/.zenity_pid"
    fi
    [ -f "$FILE_INFO" ] && rm "$FILE_INFO"
    
    # Notify the user
    notify-send "Recording Stopped" "Your recording has been saved to: $OUTPUT_FILE"
else
    # Notify if no recording is in progress
    notify-send "No Recording" "No active recording found"
fi
