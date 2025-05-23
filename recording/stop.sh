#!/bin/bash

# TODO: Modularize a bit better

# Enhanced stop recording script with automatic subtitle generation
PROJECT_DIR="$HOME/.local/bin/scripts"
# PID file location
VIDEOS_DIR="$HOME/.local/bin/scripts/recording/videos/"
# File which contains save path for the recording to be stopped
FILE_INFO="$VIDEOS_DIR/.ffmpeg_recording_file.txt"
# File with the running FFMPEG process ID
PID_FILE="$VIDEOS_DIR/.ffmpeg_recording.pid"

# Path to subtitle generation script
SUBTITLE_SCRIPT="$HOME/.local/bin/scripts/recording/generate_subtitles.py"

# Log file location
LOG_FILE="$VIDEOS_DIR/recording.log"

# Function to log messages
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

# Check if the PID file exists
if [ -f "$PID_FILE" ]; then
    # Get the PID
    PID=$(cat "$PID_FILE")
    
    # Get the output file path (if available)
    OUTPUT_FILE="Unknown location"
    if [ -f "$FILE_INFO" ]; then
        OUTPUT_FILE=$(cat "$FILE_INFO")
    fi
    
    log "Stopping recording (PID: $PID)..."
    
    # Send a quit signal to FFmpeg
    kill -TERM $PID
    
    # Wait a moment for the process to finish
    sleep 2
    
    # Remove the PID file and file info
    rm "$PID_FILE"
    [ -f "$FILE_INFO" ] && rm "$FILE_INFO"
    
    # Notify the user that recording stopped and processing is starting
    notify-send "Recording Stopped" "Processing video and generating subtitles..."
    
    log "Recording stopped. Starting subtitle generation..."

    log "Output file at $OUTPUT_FILE"
    
    # Check if the output file exists and subtitle script is available
    if [ -f "$OUTPUT_FILE" ] && [ -f "$SUBTITLE_SCRIPT" ]; then
        
        # Generate subtitles
        log "Generating subtitles for: $OUTPUT_FILE"
        cd "$PROJECT_DIR" && uv run "$SUBTITLE_SCRIPT" "$OUTPUT_FILE" --verbose
        
        # Check if subtitle generation was successful
        SUBTITLE_FILE="${OUTPUT_FILE%.*}.srt"
        if [ -f "$SUBTITLE_FILE" ]; then
            log "Subtitles generated successfully: $SUBTITLE_FILE"
            
            # Create output filename for video with subtitles
            VIDEO_WITH_SUBS="${OUTPUT_FILE%.*}_with_subtitles.${OUTPUT_FILE##*.}"
            
            log "Merging subtitles with video..."
            
            # Merge subtitles with video using ffmpeg
            if ffmpeg -i "$OUTPUT_FILE" \
                     -vf "subtitles='$SUBTITLE_FILE':force_style='FontName=Arial,FontSize=28,PrimaryColour=&Hffffff,OutlineColour=&H000000,Outline=2,Shadow=1'" \
                     -c:a copy \
                     -y "$VIDEO_WITH_SUBS" \
                     -loglevel error; then
                
                log "Video with subtitles created: $VIDEO_WITH_SUBS"
                
                # Notify completion with both files
                notify-send "Processing Complete!" \
                    "Original: $OUTPUT_FILE
Subtitles: $SUBTITLE_FILE
With Subtitles: $VIDEO_WITH_SUBS"
                
                log "All processing completed successfully!"
                
            else
                log "Error: Failed to merge subtitles with video"
                notify-send "Processing Error" "Failed to merge subtitles with video. Original recording saved to: $OUTPUT_FILE"
            fi
            
        else
            log "Error: Subtitle generation failed"
            notify-send "Subtitle Error" "Failed to generate subtitles. Recording saved to: $OUTPUT_FILE"
        fi
        
    else
        if [ ! -f "$OUTPUT_FILE" ]; then
            log "Error: Output video file not found: $OUTPUT_FILE"
        fi
        if [ ! -f "$SUBTITLE_SCRIPT" ]; then
            log "Error: Subtitle generation script not found: $SUBTITLE_SCRIPT"
        fi
        
        notify-send "Processing Error" "Cannot process subtitles. Recording saved to: $OUTPUT_FILE"
    fi
    
else
    # Notify if no recording is in progress
    log "No active recording found"
    notify-send "No Recording" "No active recording found"
fi
