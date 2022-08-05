#! /bin/sh

# this script runs as root, during docker setup

# fail on first error (set -e)
set -o errexit

sudo --user ${SERVICE_USER} ${SERVICE_HOME}/.bash_it/install.sh --silent
echo -e "\n# Load bash-completion\n[ -f /usr/share/bash-completion/bash_completion  ] && source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
git clone --depth 1 https://github.com/sstephenson/bats.git /tmp/bats
  /tmp/bats/install.sh /usr/local
chown -R ${SERVICE_USER}:${SERVICE_USER} ${SERVICE_HOME}
sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
apk del git tzdata
rm -rf /tmp/{.}* /tmp/*
