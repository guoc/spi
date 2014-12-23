#!/usr/bin/env python

# This script updates build version number as next commit serial number.

import subprocess

output, err = subprocess.Popen('git rev-list HEAD --count', universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
commitSerialNumber = int(output.strip()) + 1

subprocess.Popen('/usr/libexec/PlistBuddy -c "Set :CFBundleVersion %d" SPi/Info.plist' % commitSerialNumber, universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()

subprocess.Popen('/usr/libexec/PlistBuddy -c "Set :CFBundleVersion %d" SPiKeyboard/Info.plist' % commitSerialNumber, universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
