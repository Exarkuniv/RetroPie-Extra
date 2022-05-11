#!/bin/bash
scriptdir="$(dirname "$0")"

pushd "$scriptdir"
git pull origin
./install-extras.sh
popd
