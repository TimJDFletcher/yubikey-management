#!/bin/sh
PIN=000000
PIN_COUNT=0
PUK_COUNT=0
LOCK_COUNT=3
_TOOL_PATH=yubico-piv-tool/current

############################
#### Assemble variables ####
############################
if ! which yubico-piv-tool > /dev/null ; then
    TOOL_PATH=${_TOOL_PATH}/bin/
    DYLD_FALLBACK_LIBRARY_PATH=${_TOOL_PATH}/lib/
fi

#################################################
#### Make sure there is a yubikey plugged in ####
#################################################
if ! ${TOOL_PATH}yubico-piv-tool -a status > /dev/null ; then
    echo Yubikey not found, try reinserting the Yubikey
    exit 1
else
    echo hard resting Yubikey in 5 seconds
    sleep 8
fi

while [ $PIN_COUNT -le $LOCK_COUNT ] ; do 
    ${TOOL_PATH}yubico-piv-tool -a verify-pin -P $PIN
    PIN_COUNT=$((PIN_COUNT+1))
done

while [ $PUK_COUNT -le $LOCK_COUNT ] ; do 
    ${TOOL_PATH}yubico-piv-tool -a unblock-pin -P $PIN -N $PIN
    PUK_COUNT=$((PUK_COUNT+1))
done

if ${TOOL_PATH}yubico-piv-tool -a reset ; then
    echo PIV application reset, please remove and reinsert Yubikey
else
    echo Reset failed please contact the support team
    exit 1
fi
