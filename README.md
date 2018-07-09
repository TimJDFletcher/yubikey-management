# Yubikey Management Tools


This repo has a collection of configuration files, utility scripts and documentation for users who have been issued with a Yubikey.

Top level directories in the repo:

* `gnupg`  - configuration and scripts for GNU Privacy Guard (gpg)
  * `gpg-agent.conf` - example configuration for gpg-agent enables ssh support
  * `gpg.conf` - example configuration for gpg, includes hardened key defaults and enables agent usage
  * `scd-event` - script that is called on change of yubikey (insert / removal etc), can be used to lock your workstation on key removal for example.
  * `scdaemon.conf` - configuration for security card (SC) management daemon, releases the yubikey after 15 seconds of inactivity to improve sharing.
  * `reload-gpg-agent.sh` - Forces a reload of gpg-agent, this fixes problems with gpg-agent being unable to find your screen for PIN prompts.
  * `reset-gpg-applet.sh` - This locks out and then resets the openpgp applet on a yubikey, use with care it *will* destroy your key material.
  * `restart-gpg-agent.sh` - This does a hard restart on scdaemon and gpg-agent, fixes odd ssh hangs for example.
* `git` - configuration examples for git
  * `gitconfig` - Example of system wide git config that signs all commits by default.
* `users` - gpg and ssh public keys for users
