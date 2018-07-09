#!/bin/sh
VPN_SLOT=9a
if [ -z $1 ] ; then
    echo "$0 <certificate to import>"
fi

if ! which yubico-piv-tool > /dev/null ; then
    TOOL_PATH=${_TOOL_PATH}/bin/
    DYLD_FALLBACK_LIBRARY_PATH=${DYLD_FALLBACK_LIBRARY_PATH},${_TOOL_PATH}/lib/
fi
${TOOL_PATH}yubico-piv-tool -s ${VPN_SLOT} -a import-certificate < $1
