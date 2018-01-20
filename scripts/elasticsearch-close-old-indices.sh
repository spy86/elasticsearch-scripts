#!/bin/bash
# elasticsearch-close-old-indices.sh
#
# Close logstash format indices from elasticsearch maintaining only a
# Must have access to the specified elasticsearch node.

usage()
{
cat << EOF

USAGE: ./elasticsearch-close-old-indices.sh [OPTIONS]

OPTIONS:
  -h    Show this message
  -i    Indices to keep open (default: 14)
  -e    Elasticsearch URL (default: http://localhost:9200)
  -g    Consistent index name (default: logstash)
  -o    Output actions to a specified file


EOF
}

# Defaults
ELASTICSEARCH="http://localhost:9200"
KEEP=14
GREP="logstash"

# Validate numeric values
RE_D="^[0-9]+$"

while getopts ":i:e:g:o:h" flag
do
  case "$flag" in
    h)
      usage
      exit 0
      ;;
    i)
      if [[ $OPTARG =~ $RE_D ]]; then
        KEEP=$OPTARG
      else
        ERROR="${ERROR}Indexes to keep must be an integer.\n"
      fi
      ;;
    e)
      ELASTICSEARCH=$OPTARG
      ;;
    g)
      GREP=$OPTARG
      ;;
    o)
      LOGFILE=$OPTARG
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

# If we have errors, show the errors with usage data and exit.
if [ -n "$ERROR" ]; then
  echo -e $ERROR
  usage
  exit 1
fi

# Get the indices from elasticsearch
INDICES_TEXT=`curl -s "$ELASTICSEARCH/_status?pretty=true" | grep $GREP | grep -v \"index\" | sort -r | awk -F\" {'print $2'}`

if [ -z "$INDICES_TEXT" ]; then
  echo "No indices returned containing '$GREP' from $ELASTICSEARCH."
  exit 1
fi

# If we are logging, make sure we have a logfile TODO - handle errors here
if [ -n "$LOGFILE" ] && ! [ -e $LOGFILE ]; then
  touch $LOGFILE
fi

# Close indices
declare -a INDEX=($INDICES_TEXT)
if [ ${#INDEX[@]} -gt $KEEP ]; then
  for index in ${INDEX[@]:$KEEP};do
    # We don't want to accidentally close everything
    if [ -n "$index" ]; then
      if [ -z "$LOGFILE" ]; then
        curl -s -XPOST "$ELASTICSEARCH/$index/_close" > /dev/null
      else
        echo -n `date "+[%Y-%m-%d %H:%M] "`" Closing index: $index." >> $LOGFILE
        curl -s -XPOST "$ELASTICSEARCH/$index/_flush" >> $LOGFILE
        curl -s -XPOST "$ELASTICSEARCH/$index/_close" >> $LOGFILE
        echo "." >> $LOGFILE
      fi
    fi
  done
fi

exit 0