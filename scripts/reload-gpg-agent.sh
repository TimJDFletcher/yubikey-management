#!/bin/sh
PATH=$PATH:/usr/local/MacGPG2/bin
pkill -9 scdaemon
echo UPDATESTARTUPTTY | gpg-connect-agent

