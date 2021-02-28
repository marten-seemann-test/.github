#!/bin/bash

FILE=$1
status=0

while read -r line; do
  # GitHub Actions are included using `uses`.
  src=`echo $line | sed -E "s/(.*)uses://g" | xargs`
  author=`echo $src | awk -F/ '{print $1}'`
  # Actions authored by GitHub use "actions" as author. We trust them.
  if [ $author == "actions" ]; then continue; fi
  version=`echo $src | awk -F@ '{print $2}' | awk '{print $1}'`
  # All other actions should be included by their commit hash.
  # Git uses SHA1 hashes, which have a fixed length of 40 characters.
  if [ ${#version} != 40 ]; then
    status=1
    echo "$FILE includes $src and doesn't use commit hash"
  fi
done < <(grep "uses:" $FILE)

exit $status
