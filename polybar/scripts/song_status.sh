#!/bin/bash

# Function to get current song info
get_current_song_info() {
    playerctl metadata --format "{{ artist }} § {{ title }}"
}

# Function to truncate title if it's too long
truncate_title() {
    local title="$1"
    local max_length=35  # Maximum length of the title
    if [ ${#title} -gt $max_length ]; then
        title="${title:0:$((max_length - 3))}..."  # Truncate title and add dots
    fi
    echo "$title"
}

# Function to format time in seconds to MM:SS
format_time() {
    local seconds=$1
    printf "%02d:%02d" $((seconds / 60)) $((seconds % 60))
}

# Function to display current time, artist, and title of the song
display_current_time() {
    local current_song_info=$(get_current_song_info)
    local artist=$(echo "$current_song_info" | awk -F ' § ' '{print $1}')
    local title=$(echo "$current_song_info" | awk -F ' § ' '{print $2}')
    local truncated_title=$(truncate_title "$title")
    local current_time=$(playerctl position)
    local source=$(playerctl metadata --format "{{ playerName }}")
    
    if [[ "$source" == "spotify" ]]; then
        if [[ -n "$current_time" ]]; then
            # Format time in MM:SS
            current_time_formatted=$(format_time ${current_time%.*})
            
            # Output the current time, artist, and truncated title for Spotify
            echo "$artist - $truncated_title [$current_time_formatted]"
        else
            # Output the artist and truncated title for Spotify if current time is not available
            echo "$artist - $truncated_title"
        fi
    elif [[ "$source" == "firefox" ]]; then
        # For YouTube (Firefox), print artist
        echo "$truncated_title"
    else
        # Output the artist and truncated title for other sources
        echo "$artist - $truncated_title"
    fi
}

# Main loop
while true; do
    if playerctl status 2>/dev/null | grep -q "Playing"; then
        display_current_time
    else
        echo " "
    fi
    sleep 1
done
