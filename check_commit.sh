#!/bin/sh

releaseConfig="Release"
if [ "$releaseConfig" = "${CONFIGURATION}" ] && [[ -n $(git status -s) ]]; then
  echo "Commit is required before archive!"
  exit 1
fi
