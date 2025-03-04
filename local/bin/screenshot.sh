#!/bin/bash
# Author: ripwoozy

# Path to the Pictures folder
pictures_folder="$HOME/Pictures"

# Path to the Screenshots folder
screenshots_folder="$pictures_folder/Screenshots"

# Create the Screenshots folder if it doesn't exist
if [ ! -d "$screenshots_folder" ]; then
    mkdir -p "$screenshots_folder"
fi

# Get the current date in the format dd-mm-yyyy
current_date=$(date +"%d-%m-%Y")

# Define the filename with the current date
filename="screenshot-$current_date.png"

# Take a screenshot using scrot and save it in the Screenshots folder with the defined filename
scrot "$screenshots_folder/$filename"

# Send a notification after taking the screenshot
notify-send "Screenshot Taken" "Screenshot saved as $filename"
