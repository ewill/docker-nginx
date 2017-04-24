#!/bin/bash

nginx_home=/home/nginx
log_dir=${nginx_home}/logs
yesterday=$(date -d "yesterday" +%Y%m%d)

for logfile in `ls -l $log_dir |  grep -v "^d" | awk '{print $9}' | grep ".log$" | grep -v "[_-]\{1\}[0-9]\{8\}.log"`
do
	mv $log_dir/$logfile $log_dir/${logfile%.*}_${yesterday}.log
done

kill -USR1 $(cat /var/run/nginx/nginx.pid)
