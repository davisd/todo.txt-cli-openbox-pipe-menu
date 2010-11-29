#!/bin/bash

#: Title       : todo.txt-cli-openbox-pipe-menu
#: Date Created: Thu Nov 25 12:00:00 CDT 2010
#: Last Edit   : Sun Nov 28 22:00:00 CDT 2010
#: Author      : "David Davis" http://www.davisd.com
#: Version     : 1.00
#: Description : Openbox toto.txt-cli pipe menu
#: Options     : Name of new script file [ filter terms ]


# Set the location to your todo.sh todo-cli.txt script
TODOCLI=~/bin/td

# very simple xml encoder to get rid of special characters
function xml_encode {
    local result=$(echo "$1" | sed 's/"/\&quot;/g')
    echo $result
}

# track whether or not we have incoming args for later
HAS_ARGS=0
if [ $# -ne 0 ]; then
    HAS_ARGS=1
fi

# get any args
ARGS=$*

# get the output of todo-txt.cli
TD_OUTPUT=''
if [ $HAS_ARGS -eq 1 ]; then
    TD_OUTPUT=$($TODOCLI -p ls $*)
else
    TD_OUTPUT=$($TODOCLI -p ls)
fi

echo "<openbox_pipe_menu>"

if [ $HAS_ARGS -eq 1 ]; then
    echo "<separator label=\"$*\" />"
else
    echo "<separator label=\"Tasks\" />"
fi

# create a glob of all task text to search for special words (beginning with @ and +)
ALLTASKTEXT=""
IFS=$'\n'
for TODO in $(echo -e "$TD_OUTPUT");
    do
    TODO=$(xml_encode $TODO)
    TASKID=$(echo "$TODO" | grep -o '^[0-9]*')
    if [ $TASKID ]; then
    echo "<item label=\""$TODO"\">"
        echo "<action name=\"Execute\"><prompt>DO $TODO</prompt><execute>$TODOCLI do $TASKID</execute></action>"
        ALLTASKTEXT="$ALLTASKTEXT $TODO"
    echo "</item>"
    fi
done
unset IFS

words=""
for word in $ALLTASKTEXT; do
    words="$words\n$word"
done

FIRSTFILTERPASS=1
if [ -n "${ARGS:+x}" ]; then
    NONGREP=$ARGS
else
    # TODO: If NONGREP is empty, it causes problems below
    NONGREP='NOM8TCH321'
fi

# sed might be more fitting to use here
for word in $(echo -e "$words" | tr '[A-Z]' '[a-z]' | sort | uniq | grep "@\|\+" | grep -v -F "$(echo -e "$NONGREP" | tr " " "\n")"); do
    if [ $HAS_ARGS -eq 1 ]; then
        word=$(echo "$word" | grep -v -F "$(echo $* | tr " " "\n")")
    fi

    if  [ $word ]; then
        if [ $FIRSTFILTERPASS -eq 1 ]; then
            echo "<separator label=\"Filter\" />"
            FIRSTFILTERPASS=0
        fi
        if [ $HAS_ARGS -eq 1 ]; then
            echo "<menu id=\"td_ls_$*_$word\" label=\"$* $word\" execute=\"$0 $* $word\">"
        else
            echo "<menu id=\"td_ls_$word\" label=\"$word\" execute=\"$0 $word\">"
        fi
        echo "</menu>"
    fi
done

echo "</openbox_pipe_menu>"

