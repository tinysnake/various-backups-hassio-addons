#!/usr/bin/with-contenv bashio

set -e

server=$(bashio::config server)
username=$(bashio::config username)
password=$(bashio::config password)
path=$(bashio::config path)
filters=$(bashio::config filters)
delete=$(bashio::config delete)
use_ssh=$(bashio::config ssh)
no_perm=$(bashio::config no_perm)

if [ "${no_perm}" == "true" ]; then
    rsync_cmd="rsync -ri"
else
    rsync_cmd="rsync -ai"
fi

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

echo "now is "$(date)

if [ ! -d "/root/.ssh" ]; then
    mkdir -p /root/.ssh
    ssh-keyscan -t rsa ${server} >> /root/.ssh/known_hosts
fi

expect -f /rsync.exp "${rsync_cmd}" "${password}"

if [ "$?" -ne "0" ]; then
    echo "rsync failed"
else
    echo "rsync complete"
fi


