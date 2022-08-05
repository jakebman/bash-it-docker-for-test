#! /bin/sh

# this script runs as root, during docker setup

# fail on first error (set -e)
set -o errexit

set -x


apk add screen
chown -R ${SERVICE_USER}:${SERVICE_USER} ${SERVICE_HOME}
sudo --user ${SERVICE_USER} ${SERVICE_HOME}/.bash_it/install.sh --silent
echo -e "\n# Load bash-completion\n[ -f /usr/share/bash-completion/bash_completion  ] && source /usr/share/bash-completion/bash_completion" >> ${SERVICE_HOME}/.bashrc
# profile load uses tput and needs a terminal, which breaks if you run:
# vim setup.sh ; docker build -t foo --progress plain .; docker run --rm --env BASH_IT_THEME=nwinkler -it foo
# but not if you run
# vim setup.sh ; docker build -t foo --progress tty .; docker run --rm --env BASH_IT_THEME=nwinkler -it foo
TERM=xterm-256color sudo --user ${SERVICE_USER} bash -x -i -c bash-it profile load jake-home 2>&1| tee /tmp/foo
sudo --user ${SERVICE_USER} sed -i -e 's/.*BASH_IT_THEME.*/export BASH_IT_THEME=nwinkler/' ${SERVICE_HOME}/.bashrc
