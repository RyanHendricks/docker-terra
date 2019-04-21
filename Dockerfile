FROM golang:alpine AS build-env

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
RUN make

# Final image
FROM alpine:edge

ENV TERRAD_HOME=/.terrad

# Install ca-certificates
RUN apk add --update ca-certificates rsync jq curl

# Copy over binaries from the build-env
COPY --from=build-env /go/bin/terrad /tmp
COPY --from=build-env /go/bin/terracli /tmp

WORKDIR /tmp

RUN install -m 0755 -o root -g root -t /usr/local/bin `find . -maxdepth 1 -executable -type f`

WORKDIR $TERRAD_HOME

EXPOSE 26656 26657 26658
EXPOSE 1317

ADD ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

STOPSIGNAL SIGINT