#!/bin/sh

log=/tmp/daemon_output.txt
daemonplist=com.mlforall.testdaemon.plist

rm -f "$log"
touch "$log"

echo 'Building...'
clang daemon.m -o testDaemon -framework Foundation || exit
echo

echo 'Running...'
launchctl load "$daemonplist" && (eval "tail -f '$log'")
echo
echo

echo 'Stopping...'
launchctl unload "$daemonplist"
echo

echo "Cleaning $log"
rm -f "$log"
