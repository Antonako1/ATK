#!/bin/bash

echo Chances that this will work are 0

output=./build/atk
files="ATK/*.cpp"

# Check if build folder exists
if [ ! -d "./build" ]; then
    echo "Creating folder 'build'"
    mkdir build
fi

# DEBUG
#g++ -O3 -o "$output" $files -ggdb -g3


g++ -o "$output" $files -ggdb -g3
