#!/bin/bash

#prepare
apt-get update
apt-get install -y curl openssh-server ca-certificates

#install gitlab CE
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo EXTERNAL_URL="http://gitlab.test.com" apt-get install gitlab-ce

#initial config
gitlab-ctl reconfigure



