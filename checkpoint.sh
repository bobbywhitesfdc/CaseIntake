#!/bin/bash
# Exit on error!
set -euxo pipefail

#--ignore-conflicts
sf project retrieve start --ignore-conflicts
git add -A .
CURRENTDATE=`date +"%Y-%m-%d %T"`
echo "checkpoint $CURRENTDATE"
git commit -m "checkpoint $CURRENTDATE"