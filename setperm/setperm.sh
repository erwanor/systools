#!/bin/bash

########################
#      By adnorth      #
#         2014         #
#     MIT LICENSE      #
########################

# The purpose of this script is to automatically set security friendly permissions to a public web directory.
# The directory is given by the user

LOG_FILE="/var/log/setperm.log"
DIRECTORY=$1;

#now() { return date}
#LogAttempt() { echo $1 >> $LOG_DIR }

if [ ! -f $LOG_FILE ]
then
    touch $LOG_FILE
fi

if [ ! -d $DIRECTORY ]
    then
    echo $DIRECTORY "does not exist"
    exit 0;
fi

if [  -z $DIRECTORY ]
    then
    echo "usage: set_perm path_to_directory"
    exit 0;
fi

chown -R $USER:www-public $DIRECTORY
chmod 2775 $DIRECTORY

find $DIRECTORY -type d -exec chmod 2775 {} +
find $DIRECTORY -type f -exec chmod 0664 {} +

echo 'Operation called by $USER on $1 at date'>>"$LOG_FILE"
echo "I've done my job now get me money $USER"
