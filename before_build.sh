#!/bin/bash

python update_candidates_database_if_necessary.py
./check_no_changes_after_last_commit.sh
