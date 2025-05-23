#!/bin/bash

# Create a timestamp for the filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Get the current working directory
VIDEOS_DIR="$HOME/.local/bin/scripts/recording/videos"

# Path to save the current recording to
OUTPUT_FILE="$VIDEOS_DIR/screen_webcam_recording_$TIMESTAMP.mp4"

# File which container save path for this recording
FILE_INFO="$VIDEOS_DIR/.ffmpeg_recording_file.txt"

# Create a PID file to store the process ID
# This process ID will be used to send a kill signal at stop time
PID_FILE="$VIDEOS_DIR/.ffmpeg_recording.pid"

echo "Recording to $OUTPUT_FILE"

# Start the recording
# TODO: Only works when connected to webcam and Mic, change to make this a priority based choice
# use lsusb to identify connected interface

ffmpeg \
  -f x11grab -video_size 1920x1080 -framerate 30 -i $DISPLAY \
  -thread_queue_size 4096 -f v4l2 -input_format mjpeg -framerate 50 -video_size 640x480 -i /dev/video0 \
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

# Also store the output file path for the stop script to reference for notification
echo "$OUTPUT_FILE" > "$HOME/.ffmpeg_recording_file.txt"
echo "STARTED RECORDING"
