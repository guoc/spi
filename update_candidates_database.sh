#!/bin/sh

python ./Candidates/generate_database.py
mv ./Candidates/candidates.sqlite ./SPiKeyboard/
