FROM cosmwasm/go-ext-builder:latest AS rust-builder

WORKDIR /go/src/github.com/terra-project/

RUN apk update && apk add --no-cache git

RUN git clone --recursive https://www.github.com/terra-project/core tmp
RUN mkdir -p /go/src/github.com/terra-project/core/
RUN cp /go/src/github.com/terra-project/tmp/go.* /go/src/github.com/terra-project/core/ -R
RUN rm -r /go/src/github.com/terra-project/tmp
WORKDIR /go/src/github.com/terra-project/core


RUN go mod download github.com/CosmWasm/go-cosmwasm \
    && export GO_WASM_DIR=$(go list -f "{{ .Dir }}" -m github.com/CosmWasm/go-cosmwasm) \
    && cd ${GO_WASM_DIR} \
    && cargo build --release --features backtraces --example muslc \
    && mv ${GO_WASM_DIR}/target/release/examples/libmuslc.a /lib/libgo_cosmwasm_muslc.a


FROM cosmwasm/go-ext-builder:0.8.2-alpine AS go-builder

WORKDIR /go/src/github.com/terra-project

RUN apk add --no-cache git libusb-dev linux-headers

RUN git clone --recursive https://www.github.com/terra-project/core
WORKDIR /go/src/github.com/terra-project/core

COPY --from=rust-builder /lib/libgo_cosmwasm_muslc.a /lib/libgo_cosmwasm_muslc.a

# force it to use static lib (from above) not standard libgo_cosmwasm.so file
RUN BUILD_TAGS=muslc make update-swagger-docs build

# Final image
FROM alpine:edge


# Install ca-certificates
RUN apk add --no-cache --update ca-certificates supervisor wget lz4

# Temp directory for copying binaries
RUN mkdir -p /tmp/bin
WORKDIR /tmp/bin

# Copy over binaries from the build-env
COPY --from=go-builder /go/src/github.com/terra-project/core/build/terrad /tmp/bin/terrad
COPY --from=go-builder /go/src/github.com/terra-project/core/build/terracli /tmp/bin/terracli
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

COPY ./scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# STOPSIGNAL SIGINT