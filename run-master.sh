#!/bin/bash

src_file=$1

if [ -z $src_file ] ; then
    echo "usage: run-master source.digo"
    exit 1
fi

make build digo="$src_file" out=executable

port="$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')";
echo "Picking a random available port: $port"

addr="127.0.0.1:$port"

echo "$addr" > /tmp/digo-master-addr.inf

echo "./executable --master $addr"
./executable --master $addr
