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

COPY setup.sh /
RUN /setup.sh
USER ${SERVICE_USER}

WORKDIR ${SERVICE_HOME}

ENTRYPOINT [ "/usr/bin/dumb-init", "bash" ]

