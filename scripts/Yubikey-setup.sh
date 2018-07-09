#!/bin/bash
# Basic Yubikey setup script
# https://developers.yubico.com/PIV/Introduction/Certificate_slots.html

PIN_SIZE=6
PUK_SIZE=$((PIN_SIZE+2))
KEY_TYPE=RSA2048
TMP_DIR=$(mktemp -d)

# Use the binaries in the git repo if the user doesn't have yubico-piv-tool installed
# Should allow this script to work on Linux assuming yubico-piv-tool is installed
_TOOL_PATH=yubico-piv-tool/current
_YKPERS_PATH=ykpers/current

SSH_SLOT=9e
SSH_CERT_NAME="/CN=ssh key/"
SSH_VALID_DAYS=3650 # 10 years but doesnt matter for ssh
SSH_TOUCH_POLICY=cached
SSH_PIN_POLICY=once
SSH_PUBKEY_PATH=${TMP_DIR}/ssh-pubkey-${LOGNAME}.pem
SSH_CERT_PATH=${TMP_DIR}/ssh-cert-${LOGNAME}.pem

VPN_SLOT=9a
VPN_CERT_NAME="/CN=${LOGNAME}-vpn/"
VPN_VALID_DAYS=730 # 2 years
VPN_TOUCH_POLICY=cached
VPN_PIN_POLICY=once
VPN_PUBKEY_PATH=${TMP_DIR}/vpn-pubkey-${LOGNAME}.pem
VPN_CSR_PATH=${TMP_DIR}/vpn-csr-${LOGNAME}.pem

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

#################################################
#### Make sure there is a yubikey plugged in ####
#################################################
if ! ${TOOL_PATH}yubico-piv-tool -a status > /dev/null ; then
    echo Yubikey not found, try reinserting the Yubikey
    exit 1
fi

# Generate a random PIN and PUK
PIN=$(dd if=/dev/random bs=1 count=32 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-${PIN_SIZE})
PUK=$(dd if=/dev/random bs=1 count=32 2>/dev/null | hexdump -v -e '/1 "%u"'|cut -c1-${PUK_SIZE})

# Set PIN and PUK, assumes default PIN and Mgmt key
${TOOL_PATH}yubico-piv-tool -a change-pin -P 123456   -N ${PIN}
${TOOL_PATH}yubico-piv-tool -a change-puk -P 12345678 -N ${PUK}

############################
#### SSH Key Generation ####
############################

# Generates a new private key for SSH key
${TOOL_PATH}yubico-piv-tool -s ${SSH_SLOT} -a generate --touch-policy=${SSH_TOUCH_POLICY} --pin-policy=${SSH_PIN_POLICY} --algorithm=${KEY_TYPE} -o ${SSH_PUBKEY_PATH}

# Prompt user to press button if touch is enforced
if [ x${SSH_TOUCH_POLICY} != xnever ] ; then
    echo Touch is enforced, please press Yubikey button
fi

# Generate and import self signed cert for SSH slot
${TOOL_PATH}yubico-piv-tool -a verify-pin -a selfsign-certificate -P ${PIN} -s ${SSH_SLOT} -S "${SSH_CERT_NAME}" --valid-days=${SSH_VALID_DAYS} -i ${SSH_PUBKEY_PATH} -o ${SSH_CERT_PATH} 
${TOOL_PATH}yubico-piv-tool -a import-certificate -s ${SSH_SLOT} -i ${SSH_CERT_PATH}

# Convert PEM public key to ssh format
SSH_PUB_KEY=$(ssh-keygen -i -m PKCS8 -f ${SSH_PUBKEY_PATH})

############################
#### VPN Key Generation ####
############################

# Generates a new private key for VPN slot
${TOOL_PATH}yubico-piv-tool -s ${VPN_SLOT} -a generate --touch-policy=${VPN_TOUCH_POLICY} --pin-policy=${VPN_PIN_POLICY} --algorithm=${KEY_TYPE} -o ${VPN_PUBKEY_PATH}

# Prompt user to press button if touch is always enforced
if [ x${VPN_TOUCH_POLICY} = xalways ] ; then
    echo Touch is always enforced, please press Yubikey button
fi

# Generate CSR for the VPN slot
${TOOL_PATH}yubico-piv-tool -a verify-pin -a request -P ${PIN} -s ${VPN_SLOT} -S "${VPN_CERT_NAME}" --valid-days=$VPN_VALID_DAYS -i ${VPN_PUBKEY_PATH} -o ${VPN_CSR_PATH}

######################################
#### Output public halves of keys ####
######################################

# Upload CSR and SSH public key to slack with curl
curl -s \
    -F file=@${VPN_CSR_PATH} \
    -F channels="${SLACK_CHANNELS}" \
    -F filename=vpn-csr-${LOGNAME}.pem \
    -F title="OpenVPN CSR for ${LOGNAME}" \
    -F token=${SLACK_TOKEN} \
    https://slack.com/api/files.upload > /dev/null

curl -s \
    -F content="${SSH_PUB_KEY} ${LOGNAME}" \
    -F channels="${SLACK_CHANNELS}" \
    -F filename=ssh-pubkey-${LOGNAME}.pub \
    -F title="OpenSSH public key for ${LOGNAME}" \
    -F token=${SLACK_TOKEN} \
    https://slack.com/api/files.upload > /dev/null

# Outputs the public key in SSH format
echo "Your new SSH public key is printed below, please add it to your jumpcloud account here: https://console.jumpcloud.com/userconsole/"
echo "${SSH_PUB_KEY} ${LOGNAME}"
echo "Your VPN CSR is saved here: ${VPN_CSR_PATH}"
echo "Your VPN CSR and SSH public key have been sent to the Slack channel ${SLACK_CHANNELS}"

echo "PIN is ${PIN}"
echo "Your PIN Unlock Key (PUK) is: ${PUK}"
echo "Please keep this safe"
