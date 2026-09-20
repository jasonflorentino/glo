#!/usr/bin/env bash

throw() {
	echo "Failed"; 
	exit 1;
}

echo Running dev
echo
echo Building client
echo
./apps/client/build.sh || throw
echo
echo Starting server
echo
(cd apps/server && gleam run) || throw
echo
echo Bye bye

