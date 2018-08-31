#!/bin/bash
#
# Quick and dirty script to send a message to anyone who has downloaded files from you.

LOVE_MESSAGE="Thank's for downloading from me! Join my room (DOWN_UNDER) for access to my entire collection!"

# message users downloading or uploading can be: `download|upload`
FILTER="upload"

#
################################################################################

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# If we've somehow disconnected from soulseek force a reconnect...
museekcontrol --password museek --connect

# We need to do this because MT is an interactive stats tool that does not write to stdout...
script -c "timeout 2s museekcontrol --password museek --mt" /tmp/museek.transfers

USERS=`cat /tmp/museek.transfers | grep -i $FILTER`

# Find anyone downloading from me and push their username into array...
ACTIVE_UPLOADS=()
while read -r line; do
    USERNAME=`echo $line | cut -d '/' -f3`
    ACTIVE_UPLOADS+=($USERNAME)
done <<< "$USERS"

# Make sure we only message users once (remove duplicate usernames)
eval MESSAGE_USERS=($(printf "%q\n" "${ACTIVE_UPLOADS[@]}" | sort -u))

MESSAGED_ON=`date '+%Y-%m-%d'`
MY_PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

PREVIOUSLY_MESSAGED=()
while read USER DATE; do
    PREVIOUSLY_MESSAGED+=($USER)
    #echo "USER=$USER DATE=$DATE"
done <$MY_PWD/messaged.dat

for i in "${MESSAGE_USERS[@]}"
do
    containsElement "$i" "${PREVIOUSLY_MESSAGED[@]}"
    EXISTS=`echo $?`

    if [[ $EXISTS -eq 1 ]]; then
        if [[ ! "$i" == "" ]]; then

            museekcontrol --password museek --private "$i" --message "$LOVE_MESSAGE"

            echo "Sent love message to: $i"
            echo -e "$i\t$MESSAGED_ON" >> $MY_PWD/messaged.dat

        fi
    else
        echo "Already messaged user: $i recently."
    fi

done

export LANG=C.UTF-8
export LC_ALL=C

# Clear any completed or aborted or failed uploads...
sed -ri "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" "/tmp/museek.transfers"

COMPLETED_FILES=`cat /tmp/museek.transfers | egrep -i -B 1 'State: Finished|State: Closed|State: Not Shared Cancelled'`
while read -r line; do
    echo $line

    REMOVE=`echo $line | grep -i 'upload' | cut -c 9- | head -c-2`
    if [ ! -z "$REMOVE" ] ; then
        museekcontrol --password museek --removeup ''"$REMOVE"''
        echo "Removed: [$UNICODE_REMOVE]"
    fi
done <<< "$COMPLETED_FILES"

