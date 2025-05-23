#!/usr/bin/env python3
"""
Auto-generate subtitles from video files using faster-whisper
"""

import argparse
import os
import sys
from pathlib import Path
from faster_whisper import WhisperModel


def format_timestamp(seconds):
    """Convert seconds to SRT timestamp format (HH:MM:SS,mmm)"""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millisecs = int((seconds % 1) * 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millisecs:03d}"


def generate_srt(segments, output_file):
    """Generate SRT subtitle file from segments"""
    with open(output_file, "w", encoding="utf-8") as f:
        for i, segment in enumerate(segments, 1):
            start_time = format_timestamp(segment.start)
            end_time = format_timestamp(segment.end)
            text = segment.text.strip()

            f.write(f"{i}\n")
            f.write(f"{start_time} --> {end_time}\n")
            f.write(f"{text}\n\n")


def main():
    parser = argparse.ArgumentParser(
        description="Generate subtitles from video files using faster-whisper",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python subtitle_generator.py video.mp4
  python subtitle_generator.py video.mp4 --model large --language en
  python subtitle_generator.py video.mp4 --output subtitles.srt --device cuda
        """,
    )

    parser.add_argument("input_file", help="Input video file (MP4, AVI, MOV, etc.)")

    parser.add_argument(
        "--output",
        "-o",
        help="Output subtitle file (.srt). Default: same name as input with .srt extension",
    )

    parser.add_argument(
        "--model",
        "-m",
        choices=["tiny", "base", "small", "medium", "large"],
        default="base",
        help="Whisper model size (default: base)",
    )

    parser.add_argument(
        "--language",
        "-l",
        help="Source language (e.g., en, es, fr). Auto-detect if not specified",
    )

    parser.add_argument(
        "--device",
        choices=["cpu", "cuda", "auto"],
        default="auto",
        help="Device to use for inference (default: auto)",
    )

    parser.add_argument(
        "--verbose", "-v", action="store_true", help="Enable verbose output"
    )

    args = parser.parse_args()

    # Validate input file
    input_path = Path(args.input_file)
    if not input_path.exists():
        print(f"Error: Input file '{args.input_file}' not found")
        sys.exit(1)

    if not input_path.is_file():
        print(f"Error: '{args.input_file}' is not a file")
        sys.exit(1)

    # Determine output file
    if args.output:
        output_file = args.output
    else:
        output_file = input_path.with_suffix(".srt")

    # Initialize model
    if args.verbose:
        print(f"Loading Whisper model: {args.model}")
        print(f"Using device: {args.device}")

    try:
        model = WhisperModel(args.model, device=args.device)
    except Exception as e:
        print(f"Error loading model: {e}")
        sys.exit(1)

    # Transcribe
    if args.verbose:
        print(f"Transcribing: {input_path}")
        print("This may take a while depending on video length and model size...")

    try:
        segments, info = model.transcribe(
            str(input_path), language=args.language, word_timestamps=False
        )

        if args.verbose:
            print(f"Detected language: {info.language}")
            print(f"Language probability: {info.language_probability:.2f}")

        # Convert segments to list (since it's a generator)
        segment_list = list(segments)

        if not segment_list:
            print("Warning: No speech detected in the video")
            sys.exit(0)

        # Generate SRT file
        generate_srt(segment_list, output_file)

        print(f"Subtitles generated successfully: {output_file}")
        print(f"Total segments: {len(segment_list)}")

        if args.verbose:
            print("\nFirst few segments:")
            for i, segment in enumerate(segment_list[:3]):
                start_time = format_timestamp(segment.start)
                end_time = format_timestamp(segment.end)
                print(f"  {start_time} --> {end_time}")
                print(f"  {segment.text.strip()}")
                print()

    except Exception as e:
        print(f"Error during transcription: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()

