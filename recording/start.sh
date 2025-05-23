#!/bin/bash

# TODO: Rewrite to save to a central location 

# Create a timestamp for the filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Get the current working directory
CURRENT_DIR=$(pwd)
OUTPUT_FILE="$CURRENT_DIR/recording_$TIMESTAMP.mp4"

# Create a PID file to store the process ID
PID_FILE="$HOME/.ffmpeg_recording.pid"

# Start the recording
ffmpeg \
  -f x11grab -video_size 1920x1080 -framerate 30 -i $DISPLAY \
  -thread_queue_size 4096 -f v4l2 -input_format mjpeg -framerate 30 -video_size 640x480 -i /dev/video0 \
  -thread_queue_size 4096 -f alsa -i default \
  -filter_complex " \
    [0:v]setpts=PTS-STARTPTS[screen]; \
    [1:v]setpts=PTS-STARTPTS,scale=240x180,pad=250:190:5:5:yellow[cam]; \
    [screen][cam]overlay=main_w-overlay_w-30:main_h-overlay_h-30[outv] \
  " \
  -map "[outv]" -map 2:a \
  -c:v libx264 -preset ultrafast -tune zerolatency -crf 23 -pix_fmt yuv420p \
  -c:a aac -b:a 192k \
  -vsync 1 -max_delay 0 -bufsize 3000k \
  "$OUTPUT_FILE" > /dev/null 2>&1 &

# Store the process ID
echo $! > $PID_FILE

# Also store the output file path for the stop script to reference
echo "$OUTPUT_FILE" > "$HOME/.ffmpeg_recording_file.txt"

zenity --notification --text="⚫ REC" &
echo $! > "$HOME/.zenity_pid"

# Notify the user
# notify-send "Recording Started" "Saving to $OUTPUT_FILE"
