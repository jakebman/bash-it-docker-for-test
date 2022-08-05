#! /bin/sh

# this script runs as root, during docker setup

# fail on first error (set -e)
set -o errexit

adduser -h ${SERVICE_HOME} -s /bin/bash -u 1002 -D ${SERVICE_USER}
apk add --no-cache \
  bash-completion \
  dumb-init \
  git \
  tzdata
cp /usr/share/zoneinfo/${SYSTEM_TZ} /etc/localtime
echo "${SYSTEM_TZ}" > /etc/TZ
git clone --depth 1 https://github.com/Bash-it/bash-it.git /tmp/bash_it
cp -R /tmp/bash_it /root/.bash_it
cp -R /tmp/bash_it ${SERVICE_HOME}/.bash_it
/root/.bash_it/install.sh --silent
echo -e "\n# Load bash-completion\n[ -f /usr/share/bash-completion/bash_completion  ] && source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
git clone --depth 1 https://github.com/sstephenson/bats.git /tmp/bats
  /tmp/bats/install.sh /usr/local
cp -R ${SERVICE_HOME}/.bash_it /root
chown -R ${SERVICE_USER}:${SERVICE_USER} ${SERVICE_HOME}
sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
apk del git tzdata
rm -rf /tmp/{.}* /tmp/*
