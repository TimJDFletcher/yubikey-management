#!/bin/sh
VPN_SLOT=9a
if [ -z $1 ] ; then
    echo "$0 <certificate to import>"
fi

if ! command -v yubico-piv-tool > /dev/null ; then
    echo "yubico-piv-tool not found. Install with: brew install yubico-piv-tool"
    exit 1
fi
yubico-piv-tool -s ${VPN_SLOT} -a import-certificate < $1
