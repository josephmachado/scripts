#!/bin/bash

# Command to list bookmarks for selection
cat ~/.local/bin/scripts/bookmarks/bookmarks.csv | dmenu -l 20 | xsel --clipboard --input
