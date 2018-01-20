#!/bin/bash

# This is a wrapper script for daily run
# i.e. you can run it by cron as follows
## m h  dom mon dow   command
#  11 4 * * * /opt/es/es-backup-index.sh >> /var/log/elasticsearch/esindexbackup.log 

# Assuming you have the scripts inside '/opt/elasticsearch/' folder. Or adjust the path to your taste.
#
# Set your system realities here
S3URL="/opt/elasticsearch/elasticsearch-backups"
ESDATA="/opt/elasticsearch/elasticsearch-data"
DAYS=7

# Read through all the available ES indices and generate a list of unique index names
# then proceed on all the indices
for i in `ls -1 $ESDATA | sed -r -e 's/-+[0-9]{4}\.[0-9]{2}\.[0-9]{2}$//' | uniq` ; do

   echo -n " *** Daily index backup for index name '$i' begin:  "
   date
   /opt/elasticsearch/graylog2-scripts/elasticsearch-backup-index.sh -b $S3URL -i $ESDATA -g $i

   echo -n " *** Close indices for index name '$i' which are  > $DAYS days old :  " 
   date
   /opt/elasticsearch/graylog2-scripts/elasticsearch-close-old-indices.sh -i $DAYS -g $i

   echo -n " *** Delete indices for index name '$i' which are > $DAYS days old :  "
   date
   /opt/elasticsearch/graylog2-scripts/elasticsearch-remove-old-indices.sh -i $DAYS -g $i
   echo " ==== Done for index name '$i' ==== "
   echo " "
done

echo -n " ******* FINISHED :  "
date