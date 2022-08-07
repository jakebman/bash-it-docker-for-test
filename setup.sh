#! /bin/sh

# this script runs as root, during docker setup

# fail on first error (set -e)
set -o errexit

set -x


chown -R ${SERVICE_USER}:${SERVICE_USER} ${SERVICE_HOME}
sudo --user ${SERVICE_USER} ${SERVICE_HOME}/.bash_it/install.sh --silent
echo -e "\n# Load bash-completion\n[ -f /usr/share/bash-completion/bash_completion  ] && source /usr/share/bash-completion/bash_completion" >> ${SERVICE_HOME}/.bashrc

# run this command in a subprocess as SERVICE_USER
sudo --user "$SERVICE_USER" bash -i -c "bash-it profile load jake-home 2>&1| tee /tmp/foo2"
sed -i -e 's/.*BASH_IT_THEME.*/export BASH_IT_THEME=nwinkler/' ${SERVICE_HOME}/.bashrc
