#!/bin/sh
GPGPATH=$(brew --prefix gnupg)
pkill -9 pinentry-mac
pkill -9 pinentry
pkill -9 gpg-agent
pkill -9 scdaemon
pkill -9 gnupg-pkcs11-scd
sleep 1
eval $($GPGPATH/bin/gpg-agent --daemon)
