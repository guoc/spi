#!/bin/bash

./update_git_pre_commit.sh
python update_candidates_database_if_necessary.py
./check_no_changes_after_last_commit.sh
