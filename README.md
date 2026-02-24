# YubiKey Management Tools

This repo has a collection of configuration files, utility scripts and documentation for users who have been issued with a YubiKey.

For detailed setup instructions (GPG key generation, SSH, git signing, U2F, TOTP, PIV), see [Unix.md](Unix.md).

## Repository Structure

* `gnupg/` - Configuration and scripts for GNU Privacy Guard (gpg)
  * `gpg-agent.conf` - Example configuration for gpg-agent, enables SSH support
  * `gpg.conf` - Example configuration for gpg, includes hardened key defaults and enables agent usage
  * `scd-event` - Script called on YubiKey state change (insert/removal), can lock your workstation on key removal
  * `scdaemon.conf` - Configuration for the smart card daemon
* `git/` - Configuration examples for git
  * `gitconfig` - Example of system-wide git config that signs all commits by default
* `piv/` - PIV (Personal Identity Verification) tools and documentation
  * `README.md` - PIV-specific setup instructions using OpenSC
  * `yubico-piv-tool/` - Bundled yubico-piv-tool binary (macOS)
* `scripts/` - Utility scripts
  * `Yubikey-setup.sh` - Full PIV provisioning: generates SSH key (slot 9e) and VPN key (slot 9a), sets random PIN/PUK
  * `Yubikey-piv-reset.sh` - Factory resets the PIV applet on a YubiKey (destructive)
  * `Yubikey-Cert-Import.sh` - Imports a signed certificate into the VPN slot (9a)
  * `Yubikey-change-pin.sh` - Changes the PIV PIN
  * `export-my-key.sh` - Exports your GPG and SSH public keys and commits them to the repo
  * `export-others-key.sh` - Exports another user's GPG and SSH public keys from their YubiKey
  * `print-key-id.sh` - Prints the GPG key ID from the connected YubiKey
  * `reload-gpg-agent.sh` - Reloads gpg-agent (fixes PIN prompt display issues)
  * `restart-gpg-agent.sh` - Hard restarts scdaemon and gpg-agent (fixes SSH hangs)
  * `reset-gpg-applet.sh` - Hard resets the OpenPGP applet on a YubiKey (**destructive** - destroys key material)

## Prerequisites

Install the required tools for your platform:

```bash
# macOS (Homebrew)
brew install gnupg pinentry-mac ykman yubico-piv-tool opensc

# Ubuntu/Debian
sudo apt-get install gnupg2 scdaemon pcscd yubikey-manager yubico-piv-tool opensc-pkcs11
```
