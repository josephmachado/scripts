#/bin/bash

BOOKMARK_FILE="$HOME/.local/bin/scripts/bookmarks/bookmarks.csv"
TEXT_TO_BOOKMARK=$(xsel -o)


echo "$TEXT_TO_BOOKMARK" >> $BOOKMARK_FILE
sort $BOOKMARK_FILE | uniq > "$BOOKMARK_FILE.tmp" && mv "$BOOKMARK_FILE.tmp" "$BOOKMARK_FILE"
notify-send "Saved $TEXT_TO_BOOKMARK"
