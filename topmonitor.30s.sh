#!/bin/bash
# <bitbar.title>topmonitor</bitbar.title>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author.github>Etheryte</bitbar.author.github>
# <bitbar.author>Etheryte</bitbar.author>
# <bitbar.desc>System utility for monitoring rogue processes</bitbar.desc>

if [ "$1" = 'kill' ]; then
	kill -9 $2
	# Refresh the menubar if we killed something
	NAME=$(basename "$0")
	open "bitbar://refreshPlugin?name=$NAME"
	exit
fi

# Get some items from top
ITEMS=$(ps -x -r -o %cpu -o pid -o comm | sed '2,11!d' | sed -E 's/\/.*\///g ; s/\ +/\ /g; s/^\ //')

# Loop through them, see if we have an issue
RESULT=""
CPU_LIMIT="90.0"
SOMETHING_FUCKY=false

while read -r ITEM; do
	FIELDS=($ITEM)
	CPU=${FIELDS[0]}
	PID=${FIELDS[1]}
	NAME=$(echo $ITEM | sed -E 's/.*\ [0-9]*\ //')

	if (( $(echo "$CPU > $CPU_LIMIT" |bc -l) )); then
		SOMETHING_FUCKY=true
		RESULT+=$CPU%\ $NAME
		RESULT+=" | bash='$0' param1=kill param2=$PID terminal=false"
		RESULT+=$'\n\r'
	fi
done <<< "$ITEMS"

# If something is fucky, let us know
if [ "$SOMETHING_FUCKY" = true ]; then
	echo "● | $FONT color=red"
else
	echo "○"
fi
echo '---'
echo $RESULT
