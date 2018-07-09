#!/bin/bash

############################
#### Assemble variables ####
############################
if ! which yubico-piv-tool > /dev/null ; then
    TOOL_PATH=${_TOOL_PATH}/bin/
    DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH},${_TOOL_PATH}/lib/
fi
if ! which ykpersonalize > /dev/null ; then
    YKPERS_PATH=${_YKPERS_PATH}/bin/
    DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH},${_YKPERS_PATH}/lib/
fi

################################################
#### Make sure there is a yubico plugged in ####
################################################
if ! ${TOOL_PATH}yubico-piv-tool -a status > /dev/null ; then
    echo Yubikey not found, try reinserting the Yubikey
    exit 1
fi

${TOOL_PATH}yubico-piv-tool -a change-pin
