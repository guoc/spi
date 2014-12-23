#!/bin/sh

# If build for release, this script makes sure no changes after last commit.

releaseConfig="Release"
if [ "$releaseConfig" = "${CONFIGURATION}" ] && [[ -n $(git status -s) ]]; then
  echo "Commit is required before archive!"
  exit 1
fi
