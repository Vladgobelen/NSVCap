#!/bin/sh
cd "/home/diver/sources/apple/NSVCap/"
j=$(date)
git add .
git commit -m "$1 $j"
git push git@github.com:Vladgobelen/NSVCap.git
git add .
git commit -m "$1 $j"
git push

