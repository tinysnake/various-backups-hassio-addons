#!/usr/bin/with-contenv bashio

set -e

next_tim=0
get_next_time ()
{
    time="$(date +%Y-%m-%d) ${exact_time}"
    next_time=$(date -d "${time}" +%s)
    next_time=$((${next_time}+${days_interval}*86400))
    # echo ${next_time}
}

TIME_FILE="/data/.next_time.txt"

days_interval=$(bashio::config daysInterval)
exact_time=$(bashio::config exactTime)
server=$(bashio::config server)
username=$(bashio::config username)
password=$(bashio::config password)
path=$(bashio::config path)
delete=$(bashio::config delete)
use_ssh=$(bashio::config ssh)
filters=$(bashio::config filters)

rsync_cmd="rsync -rti"

if [ "${delete}" == "true" ]; then
    rsync_cmd="${rsync_cmd} --del"
fi
if [ "${use_ssh}" == "true" ]; then
    rsync_cmd="${rsync_cmd} -e ssh"
else
    path=":"${path}
fi

for filter in ${filters}; do
    rsync_cmd="${rsync_cmd} --filter=\"${filter}\""
done

server_str=${server}

if [ -n ${username} ]; then
    server_str="${username}@${server}"
fi

rsync_cmd="${rsync_cmd} /backup/ ${server_str}:${path}"

# echo ${rsync_cmd}

rsync_cmd="${rsync_cmd}"

if [ ! -f ${TIME_FILE} ]; then
    get_next_time
    # echo "create "${next_time}
    echo ${next_time} > ${TIME_FILE}
else
    next_time=$(cat ${TIME_FILE})
    # echo "read "${next_time}
fi
echo "backup will occur at $(date -d @${next_time})"

while :
do
    time=$(date +%s)
    sleep_time=1s
    if (( ${time}-${next_time}>0 )); then
        if [ ! -d "/root/.ssh" ]; then
            mkdir -p /root/.ssh
            ssh-keyscan -t rsa ${server} >> /root/.ssh/known_hosts
        fi
        expect -f /rsync.exp "${rsync_cmd}" "${password}"
        if [ "$?" -ne "0" ]; then
            sleep_time=1h
            echo "rsync failed, will retry a hour later"
        else
            get_next_time
            #echo "set "${next_time}
            echo ${next_time} > ${TIME_FILE}
            echo "rsync complete, next backup will occur at $(date -d @${next_time})"
        fi
    # else
    #     echo "wait for next hour"
    fi
    sleep ${sleep_time}
done


