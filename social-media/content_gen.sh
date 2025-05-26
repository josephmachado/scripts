#!/bin/bash

"""
Usage 
./social-media/content_gen.sh -t 'SQL techniques' -u https://www.startdataengineering.com/post/n-sql-tips-de/\#sql-tips -s 'SQL tips'

Paste to LLM chat and get the output

TODO: Store t,s,u in a csv with date -> generate prompt -> Check quality -> post to social(s) 

TODO: Automate collection of t,s,u via conversations, voice mail to text, etc

TODO: Create an eval pipeline => Evaluate perf (at 12,24,30 h of posting) -> Identify levers -> Optimize algo

"""

# Initialize variables
INPUT_TOPIC=""
INPUT_WEBSITE_URL=""
INPUT_SUBSECTION=""

while getopts "t:u:s:" opt; do 
    case $opt in 
        t) INPUT_TOPIC=$OPTARG ;;
        u) INPUT_WEBSITE_URL=$OPTARG ;;
        s) INPUT_SUBSECTION=$OPTARG ;;
        *) echo "Invalid option"; exit 1 ;;
    esac
done

# Check if required arguments are provided
if [[ -z "$INPUT_TOPIC" || -z "$INPUT_WEBSITE_URL" || -z "$INPUT_SUBSECTION" ]]; then
    echo "Error: All options -t, -u, and -s are required"
    echo "Usage: $0 -t <topic> -u <url> -s <subsection>"
    exit 1
fi

echo "Creating prompt for $INPUT_TOPIC, from $INPUT_WEBSITE_URL, optionally for the subsection $INPUT_SUBSECTION"

echo "----------------------------------------------------------------------------------------------------------------------------------



"

PROMPT_FILE="$HOME/.local/bin/scripts/social-media/linkedin/topic_based_post_template.template"

sed "s|INPUT_TOPIC|$INPUT_TOPIC|g; s|INPUT_WEBSITE_URL|$INPUT_WEBSITE_URL|g; s|INPUT_SUBSECTION|$INPUT_SUBSECTION|g" $PROMPT_FILE
