#!/bin/bash

make clean
make generate-dependency

for filename in ./tests/*.digo; do
    echo "Running test: $filename"
    make build digo="$filename"
    ./executable > "$filename.out"
    diff "$filename.out" "$filename.expected"
done
