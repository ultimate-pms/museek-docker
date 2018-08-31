#!/bin/bash
#
# A quick and dirty Museek script to authorise users who have joined a room to share my files...
#

# Auto-join any other rooms we want to be members of (if not already joined first)
museekcontrol --password museek --join "TECHNO, Mixes and Tunes"
museekcontrol --password museek --join "Rare Music"
museekcontrol --password museek --join "minimal music"
museekcontrol --password museek --join "Underground Hiphop"
museekcontrol --password museek --join "HOUSE MUSIC LOVERS (AG)"


# Leave any rooms we don't want to be part of
museekcontrol --password museek --leave "museek"

# THIS IS OUR LITTLE ROOM
# Let's add anyone that's in this room to our allow-list
AUTH_USERS_IN_ROOM="DOWN_UNDER"

museekcontrol --password museek --join "$AUTH_USERS_IN_ROOM"

########################################

# Refresh roomlist...
MY_PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
museekcontrol --password museek --roomlist > /dev/null
USERS_LIST=`museekcontrol --password museek --roominfo "$AUTH_USERS_IN_ROOM" | awk '{print $1}' | tail -n +5 | head -n -1`

touch $MY_PWD/authed_users.dat

containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

CURRENT_USERS_IN_ROOM=()
AUTHED_USERS_DB=()
DEAUTH_USERS=()
PREVIOUSLY_AUTHED=()

# Load everyone in the room we auth off into array...
while read -r user; do
    CURRENT_USERS_IN_ROOM+=($user)
    AUTHED_USERS_DB+=($user)
done <<< "$USERS_LIST"

# Load only current users in the room "authed" into array (anyone else will be removed)...
while read USER; do

    containsElement "$USER" "${CURRENT_USERS_IN_ROOM[@]}"
    USER_PRESENT=`echo $?`

    if [[ $USER_PRESENT -eq 0 ]]; then
        #echo "pervious authed user still in room: [$USER]"
        AUTHED_USERS_DB+=($USER)
        PREVIOUSLY_AUTHED+=($USER)
    else
        # User left room...
        echo "deauth user: [$USER]"
        DEAUTH_USERS+=($USER)
    fi

done <$MY_PWD/authed_users.dat

eval SORTED_USERLIST=($(printf "%q\n" "${AUTHED_USERS_DB[@]}" | sort -u))

# Reset authed users db...
rm -rf $MY_PWD/authed_users.dat
for i in "${SORTED_USERLIST[@]}"
do
    if [[ ! "$i" == "" ]]; then

        containsElement "$i" "${PREVIOUSLY_AUTHED[@]}"
        PREV_USER=`echo $?`

        # Only give  anyone in the room access to my files
        museekcontrol --password museek --buddy "$i"
        echo "$i" >> $MY_PWD/authed_users.dat

        if [[ ! $PREV_USER -eq 0 ]]; then
            # User joined room...
            echo "New User: [$i]"
            museekcontrol --password museek --chat "$AUTH_USERS_IN_ROOM" --message "Hi there $i, you've now got access to my private shares :)"
        fi

    fi
done
