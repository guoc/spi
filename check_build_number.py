#!/usr/bin/env python

# This script checks if build version number is same as commit serial number.

import subprocess
import sys

output, err = subprocess.Popen('git rev-list HEAD --count', universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
commitSerialNumber = int(output.strip()) + 1

output, err = subprocess.Popen('/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" SPi/Info.plist', universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
spiBuildNumber = int(output.strip())

output, err = subprocess.Popen('/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" SPiKeyboard/Info.plist', universal_newlines=True, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
spiKeyboardBuildNumber = int(output.strip())

if spiBuildNumber != commitSerialNumber or spiKeyboardBuildNumber != commitSerialNumber:
  print 'Build version number (Bundle version in Info.plist in both SPi and SPiKeyboard) should be ' + str(commitSerialNumber)
  sys.exit(1)
else:
  sys.exit(0)
