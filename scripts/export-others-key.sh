#!/bin/sh
#set -x #debuging option
echo -n "Enter the user's name and press [ENTER]: "
read username
mkdir -p $username

# Grab serial number of connected Yubikey
yk_serial=$(gpg --batch --card-status| grep "^Serial number" | awk '{print $NF}')

#gen serials file if not existing
touch $username/yubikeyserialnumber.txt

#check if yubikey serial already on file and if not record it
if ! grep -q $yk_serial $username/yubikeyserialnumber.txt ; then
    echo $yk_serial >> $username/yubikeyserialnumber.txt
fi

#Export public key for connected yubikey ASCI
gpg --batch --export --armor --output $username/pubkey-${yk_serial}.asc $(gpg --batch --card-status | grep "^General key info" | cut -d " " -f 6 | cut -d "/" -f 2)
#Export public key as binary blob
gpg --batch --export $(gpg --batch --card-status | grep "^General key info" | cut -d " " -f 6 | cut -d "/" -f 2) > $username/pubkey-${yk_serial}.pgp.bin
#Export pubkey as base64 encoded binary
#gpg --batch --export $(gpg --batch --card-status | grep "^General key info" | cut -d " " -f 6 | cut -d "/" -f 2) | base64 -w 0 >
$username/pubkey-${yk_serial}.pgp.bin.base64

# Export the public ssh key, assumes working gpg-agent
ssh-add -L | grep "${yk_serial}"$ > $username/ssh-key-${yk_serial}.pub

# Push files to git
git add $username
git commit -m "Import public keys from $username" $username
git push
