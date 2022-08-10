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

# install-ish
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
  python3-dev

# install bats
run git clone --depth 1 https://github.com/sstephenson/bats.git /tmp/bats && \
    /tmp/bats/install.sh /usr/local

# install pre-commit
RUN pip install --ignore-installed distlib pre-commit

RUN cp /usr/share/zoneinfo/${SYSTEM_TZ} /etc/localtime
RUN echo "${SYSTEM_TZ}" > /etc/TZ
RUN git clone --depth 1 https://github.com/jakebman/bash-it.git /tmp/bash_it
RUN cd /tmp/bash_it && git submodule init && git submodule update # the first steps of running .bash_it/test/run; cacheable
RUN cp -R /tmp/bash_it /root/.bash_it && \
  cp -R /tmp/bash_it ${SERVICE_HOME}/.bash_it
RUN /root/.bash_it/install.sh --silent && \
  echo -e "\n# Load bash-completion\n[ -f /usr/share/bash-completion/bash_completion  ] && source /usr/share/bash-completion/bash_completion" >> /root/.bashrc
RUN chown -R ${SERVICE_USER}:${SERVICE_USER} ${SERVICE_HOME}
RUN sudo --user ${SERVICE_USER} ${SERVICE_HOME}/.bash_it/install.sh --silent && \
  echo -e "\n# Load bash-completion\n[ -f /usr/share/bash-completion/bash_completion  ] && source /usr/share/bash-completion/bash_completion" >> ${SERVICE_HOME}/.bashrc

# pre-commit first run setup
RUN cd ~/.bash_it && pre-commit install # this takes a little time. Save that for the impatient


run sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd
run apk del tzdata && \
  rm -rf /tmp/{.}* /tmp/*

# setup-ish
#RUN apk add ack perl # needed for ack-completion, which (TODO!) doesn't behave properly if ack isn't installed
#RUN apk add curl # needed to pass tests (myip)
#RUN apk add sed # prevent tests (bash-it help plugins and bash-it show aliases)

# run this command in a subprocess as SERVICE_USER
RUN sudo --user "$SERVICE_USER" bash -i -c "bash-it profile load jake-home 2>&1| tee /tmp/foo2"
RUN sed -i -e 's/.*BASH_IT_THEME.*/export BASH_IT_THEME=nwinkler/' ${SERVICE_HOME}/.bashrc ~/.bashrc

# install pre-commit
#RUN apk add py-pip
#RUN pip install --ignore-installed distlib pre-commit
#RUN apk add gcc libc-dev python3-dev # needed for pre-commit
#RUN cd ~/.bash* && pre-commit # pre-cache this first load
#RUN apk add shfmt shellcheck # Necessary to perform pre-commit actions

# Further layers for impatientce. Move these up as necessary:

RUN apk add shfmt shellcheck # Necessary to perform pre-commit actions
RUN apk add less # my comfort
RUN sudo --user  "$SERVICE_USER" bash -i -c "cd ~/.bash_it && pre-commit install --install-hooks" # this takes a little time. Save that for the impatient
RUN cd ~/.bash_it && pre-commit install --install-hooks # this takes a little time. Save that for the impatient

USER ${SERVICE_USER}

WORKDIR ${SERVICE_HOME}/.bash_it

ENTRYPOINT [ "/usr/bin/dumb-init", "bash" ]

