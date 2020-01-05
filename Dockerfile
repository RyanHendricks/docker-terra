FROM golang:1.13-alpine AS build-env

# Modified from original terra-project/core Dockerfile

ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev
ENV BRANCH=master

# Set up dependencies
RUN apk add --no-cache $PACKAGES

# Set working directory for the build
WORKDIR /go/src/github.com/terra-project/

# Add source files
RUN git clone --recursive https://www.github.com/terra-project/core
WORKDIR /go/src/github.com/terra-project/core
RUN git checkout $BRANCH

# Build
RUN make install

# Final image
FROM alpine:edge


# Install ca-certificates
RUN apk add --no-cache --update ca-certificates supervisor wget lz4

# Temp directory for copying binaries
RUN mkdir -p /tmp/bin
WORKDIR /tmp/bin

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/terrad /tmp/bin
COPY --from=build-env /go/bin/terracli /tmp/bin
RUN install -m 0755 -o root -g root -t /usr/local/bin terrad
RUN install -m 0755 -o root -g root -t /usr/local/bin terracli


# Remove temp files
RUN rm -r /tmp/bin

# Add supervisor configuration files
RUN mkdir -p /etc/supervisor/conf.d/
COPY /supervisor/supervisord.conf /etc/supervisor/supervisord.conf 
COPY /supervisor/conf.d/* /etc/supervisor/conf.d/

ENV TERRAD_HOME=/.terrad
WORKDIR $TERRAD_HOME

EXPOSE 26656 26657 26658
EXPOSE 1317

# VOLUME [ /.terrad ]

ADD ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# STOPSIGNAL SIGINT