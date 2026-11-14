#!/usr/bin/env bash
# Convert 8000Hz WAV IVR prompt to native Asterisk / Issabel / FreePBX formats
# Usage: ./convert-to-pbx.sh ivr_audio_8khz.wav

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <input_wav_file>"
  exit 1
fi

INPUT_FILE="$1"
BASENAME="${INPUT_FILE%.*}"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "Error: ffmpeg is not installed. Install it via: yum install ffmpeg OR apt install ffmpeg"
  exit 1
fi

echo "Converting '$INPUT_FILE' to PBX telephony formats..."

# Standard Asterisk 8kHz 16-bit Mono PCM WAV
ffmpeg -y -i "$INPUT_FILE" -ar 8000 -ac 1 -c:a pcm_s16le "${BASENAME}_pbx.wav" -loglevel error

# G.711 u-law (.ulaw)
ffmpeg -y -i "$INPUT_FILE" -ar 8000 -ac 1 -f mulaw "${BASENAME}.ulaw" -loglevel error

# G.711 a-law (.alaw)
ffmpeg -y -i "$INPUT_FILE" -ar 8000 -ac 1 -f alaw "${BASENAME}.alaw" -loglevel error

# GSM 06.10 (.gsm)
ffmpeg -y -i "$INPUT_FILE" -ar 8000 -ac 1 -c:a libgsm "${BASENAME}.gsm" -loglevel error

echo "Done! Generated files:"
ls -lh "${BASENAME}_pbx.wav" "${BASENAME}.ulaw" "${BASENAME}.alaw" "${BASENAME}.gsm"
