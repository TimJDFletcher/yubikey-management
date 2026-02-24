#!/bin/bash

if ! command -v yubico-piv-tool > /dev/null ; then
    echo "yubico-piv-tool not found. Install with: brew install yubico-piv-tool"
    exit 1
fi

if ! yubico-piv-tool -a status > /dev/null ; then
    echo Yubikey not found, try reinserting the Yubikey
    exit 1
fi

yubico-piv-tool -a change-pin
