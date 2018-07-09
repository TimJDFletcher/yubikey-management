#!/bin/bash -e
KEYDIR=users/${LOGNAME}

mkdir -p ${KEYDIR}

# Grab serial number of connected Yubikey
yk_serial=$(gpg --batch --card-status| grep "^Serial number" | awk '{print $NF}')

#gen serials file if not existing
touch ${KEYDIR}/yubikeyserialnumber.txt

#check if yubikey serial already on file and if not record it
if ! grep -q $yk_serial ${KEYDIR}/yubikeyserialnumber.txt ; then
    echo $yk_serial >> ${KEYDIR}/yubikeyserialnumber.txt
fi

#Export public key for connected yubikey ASCII
gpg --batch --export --armor --output ${KEYDIR}/pubkey-${yk_serial}.asc $(gpg --batch --card-status | grep "^General key info" | cut -d " " -f 6 | cut -d "/" -f 2)
#Export public key as binary blob
gpg --batch --export $(gpg --batch --card-status | grep "^General key info" | cut -d " " -f 6 | cut -d "/" -f 2) > ${KEYDIR}/pubkey-${yk_serial}.pgp.bin
# Export the public ssh key, assumes working gpg-agent
ssh-add -L | grep "${yk_serial}"$ > ${KEYDIR}/ssh-key-${yk_serial}.pub

# Push files to git
git add ${KEYDIR}
git commit -m "Import public keys from $LOGNAME" ${KEYDIR}
git push
