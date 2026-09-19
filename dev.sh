#!/usr/bin/env bash

echo Running dev
echo
echo Building client
echo
./apps/client/build.sh
echo
echo Starting server
echo
(cd apps/server && gleam run) 
echo
echo Bye bye

