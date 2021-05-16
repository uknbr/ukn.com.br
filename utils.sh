#!/usr/bin/env bash

# latest photo number
echo -n "Latest photo number: "
find . -type f -iname 'photo_*' | grep 'assets' | awk -F '/' '{ print $NF }' | tr -d '[a-z]' | tr -d '.' | tr -d '_' | sort -n | tail -n 1
