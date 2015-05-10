#!/bin/bash

set -e

git checkout -q ef7daf1
xcrun -sdk macosx swiftc *.swift -o spambootstrap
git checkout -q -
./spambootstrap install
./spambootstrap compile
mv main spam
rm spambootstrap
