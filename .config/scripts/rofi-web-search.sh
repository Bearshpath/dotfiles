#!/bin/bash

# Define your preferred search engines and their base URLs
declare -A ENGINES
ENGINES["Google"]="https://www.google.com/search?q="
ENGINES["DuckDuckGo"]="https://duckduckgo.com/?q="
ENGINES["Wikipedia"]="https://en.wikipedia.org/wiki/"
ENGINES["YouTube"]="https://www.youtube.com/results?search_query="

# Get user input for the search engine (optional, default to Google)
# And the search query
CHOICE=$(echo -e "Google\nDuckDuckGo\nWikipedia\nYouTube" | rofi -dmenu -i -p "Search with:" -mesg "Web Search" \
    -theme-str 'window {width: 25%;} listview {lines: 4;}')

if [ -z "$CHOICE" ]; then exit 0; fi # User pressed escape

QUERY=$(rofi -dmenu -i -p "Search for: " -mesg "$CHOICE Search" \
    -theme-str 'window {width: 40%;} listview {lines: 0;}')

if [ -n "$QUERY" ]; then
    URL="${ENGINES[$CHOICE]}$(echo "$QUERY" | sed 's/ /%20/g')" # Replace spaces for URL encoding
    xdg-open "$URL" &
fi
