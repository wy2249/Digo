#!/bin/bash

master_addr="$(cat /tmp/digo-master-addr.inf)"

if [ -z "$master_addr" ] ; then
    echo "master not found"
    exit 1
fi

port="$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')";
echo "Picking a random available port: $port"

worker_addr="127.0.0.1:$port"

echo "./executable --worker $master_addr $worker_addr"
./executable --worker $master_addr $worker_addr
