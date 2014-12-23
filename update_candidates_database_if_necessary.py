#!/usr/bin/env python

# If any files in Candidates updates, this script will call update_candidates_database.sh

import os
import subprocess

candidatesFiles = os.listdir('./Candidates')

for candidatesFile in candidatesFiles:
  if os.path.getmtime('./Candidates/' + candidatesFile) > os.path.getmtime("./SPiKeyboard/candidates.sqlite"):
    subprocess.call(['./update_candidates_database.sh'])
