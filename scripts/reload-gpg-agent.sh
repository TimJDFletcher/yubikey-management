#!/bin/sh
pkill -9 scdaemon
echo UPDATESTARTUPTTY | gpg-connect-agent
