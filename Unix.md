The instructions have been tested on macOS 10.13 (High Sierra) with a YubiKey 4, but they should work on any Unix like system.

To perform these instructions, the YubiKey should be plugged into a USB port.

## Generate a set of GPG keys

1. Install [GPG2](https://www.gnupg.org/) if you haven't already, nearly all Linux distributions have GPG in the base package set. Note brew have recently renamed gpg2 -> gpg which has broken some configs.

   ```bash
   # For macOS
   brew install gnupg pinentry-mac
   # For Ubuntu
   sudo apt-get install gnupg2
   ```

1. Configure GPG, there are a number of moving parts to GPG with a yubikey. The parts that need to be configured are are gpg, gpg-agent and scdaemon. The config for these are stored in `$HOME/.gnupg/`, there are examples of the config in this repo.
   - Suggested config files: 
   - [gpg.conf]()
   - [gpg-agent.conf]() - Note this will need a minor change to reflect macos vs Linux
   - It is possible to call a script ([scd-event]()) on insert or removal of a yubikey, an example is included that clears gpg-agent's password cache and activates a Mac's screensaver on removal.

1. Generate Keys

   _Note:_ You need to use GnuPG version 2 for this, for Linux distros this could be called as gpg2

   ```
   > gpg --card-edit

   [truncated...]

   gpg/card> admin
   Admin commands are allowed

   gpg/card> generate
   Make off-card backup of encryption key? (Y/n) n

   [PIN Entry pops up, enter 123456, which is the default pin]

   What keysize do you want for the Signature key? (2048) 4096
   [PIN Entry pops up, enter 12345678, which is the default admin pin]
   The card will now be re-configured to generate a key of 4096 bits

   What keysize do you want for the Encryption key? (2048) 4096
   [PIN Entry pops up, enter 12345678, which is the default admin pin]
   The card will now be re-configured to generate a key of 4096 bits

   What keysize do you want for the Authentication key? (2048) 4096
   [PIN Entry pops up, enter 12345678, which is the default admin pin]
   The card will now be re-configured to generate a key of 4096 bits

   Please specify how long the key should be valid.
            0 = key does not expire
         <n>  = key expires in n days
         <n>w = key expires in n weeks
         <n>m = key expires in n months
         <n>y = key expires in n years
   Key is valid for? (0)
   Key does not expire at all
   Is this correct? (y/N) Y

   GnuPG needs to construct a user ID to identify your key.

   Real name: <YOUR_NAME_HERE>
   Email address: <YOUR_EMAIL_HERE@example.com>
   Comment:
   You selected this USER-ID:
       "YOUR_NAME_HERE <YOUR_EMAIL_HERE>"

   Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
   ```

   The YubiKey will flash as it's creating the key. Mine took about 5 minutes. When complete, it will say something like

   ```
   gpg: key 00000000 marked as ultimately trusted
   public and secret key created and signed.

   [truncated...]
   ```

   In case you were not asked to choose keysize during the setup, make sure you to change it manually:
   ```
   > gpg --card-edit
   
   ...truncated..

   gpg/card> admin
   Admin commands are allowed

   gpg/card> key-attr

   Changing card key attribute for: Signature key
   Please select what kind of key you want:
      (1) RSA
      (2) ECC
   Your selection? 1
   What keysize do you want? (2048) 4096

   Changing card key attribute for: Encryption key
   Please select what kind of key you want:
      (1) RSA
      (2) ECC
   Your selection? 1
   What keysize do you want? (2048) 4096

   Changing card key attribute for: Authentication key
   Please select what kind of key you want:
      (1) RSA
      (2) ECC
   Your selection? 1
   What keysize do you want? (2048) 4096

   ```

   You should change your PIN and Admin PIN. You can do that here with `passwd` at the `gpg/card>` prompt:

   ```
   > gpg --card-edit

   ...truncated...

   gpg/card> admin
   Admin commands are allowed

   gpg/card> passwd

   1 - change PIN
   2 - unblock PIN
   3 - change Admin PIN
   4 - set the Reset Code
   Q - quit

   Your selection? 1
   [Enter 123456]
   [Enter your new PIN]
   [Enter your new PIN again]

   PIN changed.

   1 - change PIN
   2 - unblock PIN
   3 - change Admin PIN
   4 - set the Reset Code
   Q - quit

   Your selection? 3
   [Enter 12345678]
   [Enter your new Admin PIN]
   [Enter your new Admin PIN again]

   PIN changed.

   1 - change PIN
   2 - unblock PIN
   3 - change Admin PIN
   4 - set the Reset Code
   Q - quit

   Your selection? Q
   ```

1. (Optional) Other GPG Setup

   While you're here:
   ```
cc
   Cardholder's surname: [Your last name]
   Cardholder's given name: [Your first name]
   [Enter your admin PIN]

   gpg/card> sex
   Sex ((M)ale, (F)emale or space): [Your gender]

   gpg/card> lang
   Language preferences: [Your two letter language code, example: en)
   ```

   You can see the configuration by typing `list` on the `gpg/card>` prompt.

   https://www.yubico.com/support/knowledge-base/categories/articles/use-yubikey-openpgp/

1. Export public keys, there is a script called export-my-key.sh in the scripts directory that will export and git commit the public keys from your keyrings that match the pattern `*@example.com`. Please run this once you have generated your key and configured gpg-agent.

## Configure YubiKey for SSH logins

1. GnuPG agent can act as an ssh agent, allowing you to login to Unix systems with the gpg key stored on your Yubikey. GnuPG agent can also import normal ssh keys in to GPG storage using the command: ```ssh-add <file name>```

  To get setup for gpg-agent you will need to add the following to your shell config, eg ```$HOME/.bash_profile``` or ```$HOME/.zshrc```


```bash
# Keep access to the system ssh-agent
export SSH_AUTH_SOCK_ORIG=$SSH_AUTH_SOCK

# Set the path to the GPG agent socket, work for systemd and plain gpg-agent
[ -S $XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh ] \
    && export GPG_AGENT_SOCK=$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh \
    || export GPG_AGENT_SOCK=$HOME/.gnupg/S.gpg-agent.ssh

# Setup GPG agent to act as an SSH agent
unset SSH_AUTH_SOCK
export SSH_AUTH_SOCK=$GPG_AGENT_SOCK

[ ! -S $SSH_AUTH_SOCK ] && echo GPG ssh socket not found, make sure you have setup ssh support in $HOME/.gnupg/gpg-agent.conf
```

  **You will need to restart your shell and `gpg-agent` after this change**

1. To list your gpg key in ssh format, and to ensure that that agent is working correctly run the following: `ssh-add -L | grep cardno`

    You should get output similar to this:

    `ssh-rsa AAAAB3NzaC1yc2EAAAADA......z+qf6QHOZMa6DAAHw== cardno:<yubikey serial number>`

1. You can add additional ssh keys to gpg-agent using `ssh-add <key file>`, this will prompt you for a password to encrypt the key file with in GPG storage. I use my Mac's keychain or Lastpass to store these passwords, `pwgen -1 16` is a useful tool to generate passwords for this.

1. Disable openssh-agent from loading if needed:

   - **macOS users** You might need to disable sshigent `sudo launchctl unload -w /System/Library/LaunchAgents/com.openssh.ssh-agent.plist`
   - **Linux users** You may need to disable the password / ssh management agent on your desktop, for gnome follow [these instructions](https://wiki.archlinux.org/index.php/GNOME/Keyring#Disable_keyring_daemon_components)  

1. Import your SSH key into GitLab/Hub/Tea

## Yubikey for git commit signing

Git supports GPG signing of commits to automatically sign with your this run the following commands:

```bash
# Enable signing of all commits
git config --global commit.gpgsign true
# Set the default key id to connected Yubikey
git config --global user.signingkey $(gpg --batch --card-status | grep "^General key info" | cut -d " " -f 6 | cut -d "/" -f 2)
```

To manually sign a single commit without changing your gitconfig, call git with the -S flag eg: `git -S -m "This is a signed commit"`

## Use for Two Factor Authentication / U2F Setup

U2F is the recommended two factor method. It is phishing resistant unlike TOTP/Google Authenticator. It is much harder to compromise than SMS/Voice call methods.

The instructions below are specific to provider, but they are all similar enough.

The main accounts that you should protect are:

* Google: https://myaccount.google.com/signinoptions/two-step-verification
* Lastpass: https://lastpass.com/yubico/

### Google

1. Go to your [Google Sign-in & Security page](https://myaccount.google.com/security)
2. Click `Two-step verification` and you may be prompted for your password.
3. Click `Add Security Key` and follow the on-screen instructions. You may
   need to tap or touch your YubiKey.

### Other accounts

Yubico has [instructions](https://www.yubico.com/about/background/fido/) or a [video](https://www.yubico.com/why-yubico/for-individuals/gmail-for-individuals/)

## Optional extras

### Install Yubikey management software

```bash
# For OSX
brew install python3 swig ykpers libu2f-host libusb yubico-piv-tool
pip install yubikey-manager
# For Ubuntu
sudo apt-get install python python-pip yubikey-personalization yubico-piv-tool
pip install yubikey-manager
```

### Set up your YubiKey for TOTP - a Google Authenticator replacement

You can have your YubiKey generate TOTP codes, just like Google Authenticator or Authy.

If you use it as a replacement for Google Authenticator, remember that you'll be unable to get the code if you don't have your YubiKey with you and a computer with `ykman` or `Yubico Authenticator` installed or an Android phone with `Yubico Authenticator` installed.

You can also use both a phone based app and a YubiKey, knowing that either device will generate the same codes and will be able to access your account.

1. Click `enter your secret key manually` to display a 26 digit long base32 key.
   Note: The link text will differ by provider. The length of the base32 key may
   also differ.
1. (Optional) If you also want to use your phone, you can scan the barcode or
   type in the code to `Google Authenticator`.
1. Copy the key below - don't forget to remove the spaces

    ```bash
    % The `-t` will require a touch in order for codes to be generated.
    % This prevent malware from generating codes without your knowledge.
    % The YubiKey Neo does not support this feature. Just remove the `-t` flag.
    > ykman oath add -t <SERVICE_NAME> <32 DIGIT BASE32 KEY NO SPACES>
    > ykman oath code <SERVICE_NAME>
    Touch your YubiKey...
    SERVICE_NAME 693720
    ```

### YubiKey and Personal Identity Verification (PIV)

Yubico has a tool called yubikey-piv-manager that can help set up your YubiKey for PIV. While I have a preference for command-line tools, the GUI sets everything up in one click and saves significant hassle.

1. Install YubiKey PIV Manager

    ```bash
    > brew cask install yubikey-piv-manager
    ```

2. Navigate to `Setup for macOS` and click `yes`.

    Choose a 6-8 digit number. Don't use non-numeric characters. Yubikey will be fine, but macOS will not.

    The default settings are fine.

3. Remove and re-insert your YubiKey.

4. Pair with macOS

    When you insert your Yubikey, a prompt should appear asking if you would like to pair your smartcard. Click `Pair`. It will ask for your username and password as well as the pin you just created. It may also ask you for your keychain password - it is the same as your account password.

5. Login with your YubiKey and PIN

    The next time you login with your YubiKey inserted, macOS should prompt you for your PIN and not a password.


## YubiKey for OSX login

Once you have PIV credentials on your YubiKey, macOS should prompt you if you want to use it for login.

Note this will change the password for your keychain to match the PIN on your yubikey.

To remove your yubikey for login follow [these instrutions](https://www.yubico.com/support/knowledge-base/categories/articles/unpair-yubikey-piv-login-macos-sierra/)

### Resetting your YubiKey

If case you want to hard reset your YubiKey use following script: `./gnupg/reset-gpg-applet.sh`

