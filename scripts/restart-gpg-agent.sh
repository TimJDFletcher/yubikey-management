#!/bin/sh
pkill -9 pinentry-mac
pkill -9 pinentry
pkill -9 gpg-agent
pkill -9 scdaemon
pkill -9 gnupg-pkcs11-scd
sleep 1
gpg-agent --daemon
