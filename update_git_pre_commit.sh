#!/bin/bash

if [ ! -x .git/hooks/pre-commit ]; then
  cp -f ./pre-commit .git/hooks/
  chmod +x .git/hooks/pre-commit
fi

