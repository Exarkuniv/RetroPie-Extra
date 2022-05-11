#!/bin/bash
scriptdir="$(dirname "$0")"

cd "$scriptdir"
git pull origin
./install-extras.sh
