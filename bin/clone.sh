#!/bin/bash

echo # On computer that has git access to GitHub;
echo # e.g., work laptop used to pull/push from GitHub at home.
echo git clone --bare https://github.com/devnull5475/SI_ORAWSV_POC.git owsx.git

echo # On computer(s) that do not have git access to GitHub;
echo # e.g., work desktop behind firewall.
echo git clone /cygdrive/l/projects/bare/owsx.git owsx
