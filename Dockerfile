# Developer:
# ---------
# Name:      Maik Ellerbrock
#
# GitHub:    https://github.com/ellerbrock
# Twitter:   https://twitter.com/frapsoft
# Docker:    https://hub.docker.com/u/ellerbrock
# Quay:      https://quay.io/user/ellerbrock
#
# Description:
# -----------
# Bash Shell v.5 with Bash-it, bats, bash-completion, and the appropriate linting tools

FROM bash:5

MAINTAINER Maik Ellerbrock

ENV VERSION 0.1.0

# Optional Configuration Parameter
ARG SYSTEM_TZ

# Default Settings (for optional Parameter)
ENV SYSTEM_TZ ${SYSTEM_TZ:-Europe/Berlin}

ENV SERVICE_USER bashit
ENV SERVICE_HOME /home/${SERVICE_USER}

# Protected network might need a cert:
COPY *.crt /usr/local/share/ca-certificates/
# bootstrap the cert into ca-certificates manually, so we can then download ca-certificates to update-ca-certificates properly
# see https://stackoverflow.com/questions/67231714/how-to-add-trusted-root-ca-to-docker-alpine
# we run this all on one line, suppressing errors, because this shouldn't break the build
# (the build should break lower, when something actually matters)
RUN cat /usr/local/share/ca-certificates/*.crt >> /etc/ssl/certs/ca-certificates.crt && \
    apk add --no-cache ca-certificates && \
    update-ca-certificates || echo "no problem if we don't have any certificates"

# install other items:
#RUN apk add ack perl # needed for ack-completion, which (TODO!) doesn't behave properly if ack isn't installed
#RUN apk add curl # needed to pass tests (myip)
#RUN apk add sed # prevent tests (bash-it help plugins and bash-it show aliases)


#RUN apk add gcc libc-dev python3-dev # needed for pre-commit
#RUN apk add shfmt shellcheck # Necessary to perform pre-commit actions
#RUN apk add less # my comfort
RUN adduser -h ${SERVICE_HOME} -s /bin/bash -u 1002 -D ${SERVICE_USER}
RUN apk add --no-cache \
  bash-completion \
  dumb-init \
  git \
  sudo \
  vim \
  ncurses \
  tzdata \
  ack \
  perl \
  curl \
  sed \
  py-pip \
  gcc \
  libc-dev \
  python3-dev \
  shfmt \
  shellcheck \
  less

# install bats
run git clone --depth 1 https://github.com/sstephenson/bats.git /tmp/bats && \
    /tmp/bats/install.sh /usr/local

# install the pre-commit tool
RUN pip install --ignore-installed distlib pre-commit

# Setup the Time Zones
RUN cp /usr/share/zoneinfo/${SYSTEM_TZ} /etc/localtime
RUN echo "${SYSTEM_TZ}" > /etc/TZ

# Install Bash-It for root
RUN git clone --depth 1 https://github.com/jakebman/bash-it.git /root/.bash_it
RUN cd /root/.bash_it && git submodule init && git submodule update # the first steps of running .bash_it/test/run; cacheable
RUN /root/.bash_it/install.sh --silent && \
  echo -e "\n# Load bash-completion\n[ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
# Pre-install the pre-commit hooks. This step takes some time, so it's better to
# run it once in the docker file than to run it every time we run ./lint_clean_files.sh
RUN cd /root/.bash_it && pre-commit install --install-hooks # saving time for the impatient

# Duplicate into SERVICE_USER
RUN cp -R /root/.bash_it ${SERVICE_HOME}/.bash_it
RUN chown -R ${SERVICE_USER}:${SERVICE_USER} ${SERVICE_HOME}
RUN sudo --user ${SERVICE_USER} ${SERVICE_HOME}/.bash_it/install.sh --silent && \
  echo -e "\n# Load bash-completion\n[ -f /usr/share/bash-completion/bash_completion ] && source /usr/share/bash-completion/bash_completion" >> ${SERVICE_HOME}/.bashrc
# setup actions for SERVICE_USER
RUN sudo --user "$SERVICE_USER" bash -i -c "bash-it profile load jake-home 2>&1| tee /tmp/foo2"
RUN sudo --user "$SERVICE_USER" bash -i -c "cd ~/.bash_it && pre-commit install --install-hooks" # saving time for the impatient

# EVERYONE gets this theme:
RUN sed -i -e 's/.*BASH_IT_THEME.*/export BASH_IT_THEME=nwinkler/' ${SERVICE_HOME}/.bashrc /root/.bashrc

run sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
run apk del tzdata && \
  rm -rf /tmp/{.}* /tmp/*

# allow $SERVICE_USER to sudo (requires sudo above)
RUN echo "${SERVICE_USER} ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/${SERVICE_USER}" && chmod 440 "/etc/sudoers.d/$SERVICE_USER"


USER ${SERVICE_USER}

WORKDIR ${SERVICE_HOME}/.bash_it

ENTRYPOINT [ "/usr/bin/dumb-init", "bash" ]

