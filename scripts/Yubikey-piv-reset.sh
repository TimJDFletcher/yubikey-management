#!/bin/sh
PIN=000000
PIN_COUNT=0
PUK_COUNT=0
LOCK_COUNT=3

if ! command -v yubico-piv-tool > /dev/null ; then
    echo "yubico-piv-tool not found. Install with: brew install yubico-piv-tool"
    exit 1
fi

if ! yubico-piv-tool -a status > /dev/null ; then
    echo Yubikey not found, try reinserting the Yubikey
    exit 1
else
    echo hard resetting Yubikey in 5 seconds
    sleep 5
fi

while [ $PIN_COUNT -le $LOCK_COUNT ] ; do 
    yubico-piv-tool -a verify-pin -P $PIN
    PIN_COUNT=$((PIN_COUNT+1))
done

while [ $PUK_COUNT -le $LOCK_COUNT ] ; do 
    yubico-piv-tool -a unblock-pin -P $PIN -N $PIN
    PUK_COUNT=$((PUK_COUNT+1))
done

if yubico-piv-tool -a reset ; then
    echo PIV application reset, please remove and reinsert Yubikey
else
    echo Reset failed please contact the support team
    exit 1
fi
