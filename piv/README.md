# README #

### What is this repository for? ###

* Yubikey hardware auth token setup

### Support Libraries ###

* Homebrew users
* `brew install opensc`
* Normal macOS users
    * Install OpenSC package from repo
+ Debian Linux users (note Linux clients are untested)
    * `sudo apt-get install opensc-pkcs11 pcscd`
+ Ubuntu Linux users (note Linux clients are untested)
    * `sudo apt-get install software-properties-common`
    * `sudo add-apt-repository ppa:yubico/stable`
    * `sudo apt-get update && sudo apt-get install yubico-piv-tool opensc-pkcs11 pcscd`

### How do I get set up? ###

    + Summary of set up
    * Pull repo
    * Insert Yubikey
    * Call reset script if needed (`Yubikey-piv-reset.sh`), note you will need to reinsert the yubikey after a reset.
    * Call Yubikey setup script (`Yubikey-setup.sh`), this script will generate a new SSH key in slot 9e on the card as well as a VPN key in slot 9a and CSR for later signing
    * Write down the PUK in secure password storage and memorise the PIN
    * Once your CSR is signed import the signed certificate with `Yubikey-Cert-Import.sh`

### SSH Configuration (macOS) ###

    To use your Yubikey PIV token for SSH access you need to choose either to use the SSH agent or to put the details in your ssh config file (`$HOME/.ssh/config`), neither of these methods are perfect. 

    Please choose one method and stick with it as using both methods together will cause your ssh client to stop working correctly.

    Using the ssh agent method means that you will not need to type your PIN when you connect to an SSH server but you will still need to press the button to confirm your presence. The downside to this method is that you will need to remove and readd your yubikey to the ssh agent when you remove the key or restart your laptop.

    * OpenSC users: `ssh-add -s /Library/OpenSC/lib/opensc-pkcs11.so`
    * Homebrew users: `ssh-add -s $(brew --prefix opensc)/lib/opensc-pkcs11.so`

    To remove change the -s flag to -e 

    Adding the PKCS11 provider to your ssh config (`$HOME/.ssh/config`) will cause ssh to automatically load the keys as needed however it will prompt for a PIN on every connection.

    * OpenSC users: `PKCS11Provider /Library/OpenSC/lib/opensc-pkcs11.so` to `$HOME/.ssh/config`
    * Homebrew users: `PKCS11Provider /usr/local/opt/opensc/lib/opensc-pkcs11.so` to `$HOME/.ssh/config`

### Changing your PIN ###

    From the root of this repo: `./Yubikey-change-pin.sh`

### Disable characters being typed by the yubikey when you touch it ( = disable OTP mode) ###

    1. Get the ykpersonalization toolkit from here: https://developers.yubico.com/yubikey-personalization/Releases/
    2. execute 'ykpersonalize -m 5'
    confirm 2x that you want to proceed
    3. remove yubikey from usb slot, and insert it again
    4. done, you can now touch it without it posting random characters on slack!

### When you have issues ###

    * Homebrew users can install the Yubico PIV tool with `brew install yubico-piv-tool`
    * Then run `yubico-piv-tool -a verify-pin` to verify the pin and possibly reset it with `yubico-piv-tool -a unblock-pin` using the PUK code

### Futher Reading ###

    * Very useful Gitbook about the Yubikey covering much more than just PIV: https://ruimarinho.gitbooks.io/yubikey-handbook/

### Who do I talk to? ###

    * Repo owner or admin
    * Other community or team contact
