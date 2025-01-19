#!/bin/bash

# takes log file of standard Nginx's "combined" logging format and extracts user-agents

# for reference, combined format ( http://nginx.org/en/docs/http/ngx_http_log_module.html#log_format ) :
#log_format combined '$remote_addr - $remote_user [$time_local] '
#                    '"$request" $status $body_bytes_sent '
#                    '"$http_referer" "$http_user_agent"';

REPORT_MODE="plain"
#REPORT_MODE="uniqsum"
#REPORT_MODE="uniqsumbots"

if [[ "$1" == "-u" ]];then REPORT_MODE="uniqsum";fi
if [[ "$1" == "-b" ]];then REPORT_MODE="uniqsumbots";fi
if [[ "$1" == "-h" ]];then
  echo 'processes standard access log format of Nginx and prints out User-Agents only'
  echo 'expects to be called as part of pipeline, i.e.'
  echo 'cat access.log|./getuseragents.sh'
  echo ''
  echo 'supports command line options:'
  echo '-u - report with uniqsum, not plain listing'
  echo '-b - report with uniqsumbots - uniqsum grepped by "good" crawlers signatures - either with "bot", "crawl" or "+http" in their user agent string'
  exit 0
fi

if [ -t 0 ]; then
  echo "no data at STDIN, please use piped input like 'cat access.log|./getuseragents.sh'"
  exit 2
fi


#output=$(head|rev|cut -f 2 -d '"'|rev)
output=$(rev|cut -f 2 -d '"'|rev)
if [[ "$REPORT_MODE" == 'uniqsum' ]];then
  output_uniqsum=$(echo "$output"|sort|uniq -c|sort -rn)
  echo "$output_uniqsum"
elif [[ "$REPORT_MODE" == 'uniqsumbots' ]];then
  output_uniqsumbots=$(echo "$output"|sort|uniq -c|sort -rn|grep -E -i 'bot|crawl|\+http')
  echo "$output_uniqsumbots"
else
  echo "$output"
fi

