#!/bin/sh
gpg --batch --card-status | grep "^General key info" | cut -d " " -f 6 | cut -d "/" -f 2
