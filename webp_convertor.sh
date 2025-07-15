#!/bin/bash
find . -iname '*.webp' -exec 'ffmpeg -y -i "$1" "${1%.*}.jpg"' _ {} \;
if { $? != "0" ]; then
  echo "Did not complete successfully"
  exit 1
fi
# Uncomment line below to remove files after successful completion 
rm *.webp
