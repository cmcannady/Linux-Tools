#!/bin/bash
###########################################################################
#
#     COPYRIGHT (C) 2020 - HCL Software
#
###########################################################################
#
#     Owner:   Casey Cannady - casey.cannady@hcl.com
#     Service: BigFix Professional Services
#     Company: HCL Software
#
###########################################################################
#
#     Script:  migrate_besclient.sh
#     Version: 1.0
#     Created: 06/05/2020
#     Updated: 09/10/2020
#
###########################################################################

# Define generic variables for script
BACKUP_FILE_NAME="$(date +%Y%m%d)_$(hostname)_BESClient.tar.gz";
DEFAULT_PATH="/var/opt";
LOG_MSG_DEBUG="DEBUG";
LOG_MSG_ERROR="ERROR";
LOG_MSG_INFO="INFO";
LOG_MSG_WARNING="WARNING";
LOG_NAME="besclient.log";
LOG_PATH="/var/opt/logs";
NEW_PATH="$1";
SERVICE_NAME_LC="besclient";
SERVICE_NAME_UC="BESClient";

# Make sure that new paths exist
mkdir -p $LOG_PATH;
mkdir -p $NEW_PATH;

# Log start of storage location migration script
echo '**************************************************' >> $LOG_PATH/$LOG_NAME;
echo $(date)' - '$LOG_MSG_INFO' - The '$SERVICE_NAME_UC' storage location migration script is starting.' >> $LOG_PATH/$LOG_NAME;

# Stop BESClient service
echo $(date)' - '$LOG_MSG_INFO' - Stopping the '$SERVICE_NAME_UC' service.' >> $LOG_PATH/$LOG_NAME;
service $SERVICE_NAME_LC stop;
rc=$?; if [[ $rc != 0 ]]; then echo $(date)' - '$LOG_MSG_ERROR' - Stop of '$SERVICE_NAME_UC' service failed (RC='$rc').' >> $LOG_PATH/$LOG_NAME; exit $rc; else echo $(date)' - '$LOG_MSG_INFO' - Stop of '$SERVICE_NAME_UC' service completed (RC=0).' >> $LOG_PATH/$LOG_NAME; fi

# Make a backup of BESClient folder
echo $(date)' - '$LOG_MSG_INFO' - Creating backup of the '$SERVICE_NAME_UC' config file and KeyStore folder.' >> $LOG_PATH/$LOG_NAME;
tar -zcvf $NEW_PATH/$BACKUP_FILE_NAME $DEFAULT_PATH/$SERVICE_NAME_UC/besclient.config $DEFAULT_PATH/$SERVICE_NAME_UC/KeyStorage;
rc=$?; if [[ $rc != 0 ]]; then echo $(date)' - '$LOG_MSG_ERROR' - Creation of '$SERVICE_NAME_UC' artifacts backup failed (RC='$rc').' >> $LOG_PATH/$LOG_NAME; exit $rc; else echo $(date)' - '$LOG_MSG_INFO' - Creation of '$SERVICE_NAME_UC' artifacts backup completed (RC=0).' >> $LOG_PATH/$LOG_NAME; fi

# Move BESClient folder to new path
echo $(date)' - '$LOG_MSG_INFO' - Moving the '$SERVICE_NAME_UC' folder to the new path.' >> $LOG_PATH/$LOG_NAME;
mv $DEFAULT_PATH/$SERVICE_NAME_UC $NEW_PATH;
rc=$?; if [[ $rc != 0 ]]; then echo $(date)' - '$LOG_MSG_ERROR' - Moving of '$SERVICE_NAME_UC' folder to new path failed (RC='$rc').' >> $LOG_PATH/$LOG_NAME; exit $rc; else echo $(date)' - '$LOG_MSG_INFO' - Moving of '$SERVICE_NAME_UC' folder to new path completed (RC=0).' >> $LOG_PATH/$LOG_NAME; fi

# Create symlink to new path
echo $(date)' - '$LOG_MSG_INFO' - Creating symbolic link for '$SERVICE_NAME_UC'.' >> $LOG_PATH/$LOG_NAME;
ln -s $NEW_PATH/$SERVICE_NAME_UC $DEFAULT_PATH/$SERVICE_NAME_UC;
rc=$?; if [[ $rc != 0 ]]; then echo $(date)' - '$LOG_MSG_ERROR' - Creation of symbolic link for '$SERVICE_NAME_UC' failed (RC='$rc').' >> $LOG_PATH/$LOG_NAME; exit $rc; else echo $(date)' - '$LOG_MSG_INFO' - Creation of symbolic link for '$SERVICE_NAME_UC' completed (RC=0).' >> $LOG_PATH/$LOG_NAME; fi

# Start BESClient service
echo $(date)' - '$LOG_MSG_INFO' - Restarting the '$SERVICE_NAME_UC' service.' >> $LOG_PATH/$LOG_NAME;
service $SERVICE_NAME_LC restart;
rc=$?; if [[ $rc != 0 ]]; then echo $(date)' - '$LOG_MSG_ERROR' - Restart of '$SERVICE_NAME_UC' service failed (RC='$rc').' >> $LOG_PATH/$LOG_NAME; exit $rc; else echo $(date)' - '$LOG_MSG_INFO' - Restart of '$SERVICE_NAME_UC' service completed (RC=0).' >> $LOG_PATH/$LOG_NAME; fi

# Good housekeeping
echo $(date)' - '$LOG_MSG_INFO' - Removing the temporary '$SERVICE_NAME_UC' backup archive.' >> $LOG_PATH/$LOG_NAME;
rm -f $NEW_PATH/$BACKUP_FILE_NAME;
rc=$?; if [[ $rc != 0 ]]; then echo $(date)' - '$LOG_MSG_ERROR' - Removal of the '$SERVICE_NAME_UC' backup archive failed (RC='$rc').' >> $LOG_PATH/$LOG_NAME; exit $rc; else echo $(date)' - '$LOG_MSG_INFO' - Removal of the temporary '$SERVICE_NAME_UC' backup archive completed (RC=0).' >> $LOG_PATH/$LOG_NAME; fi