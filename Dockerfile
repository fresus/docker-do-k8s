FROM alpine:3.10 AS base


FROM base AS doctl-build

ENV DOCTL_VERSION=1.31.2

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
RUN mkdir /lib64 \
  && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2 \
  && apk add --no-cache --virtual .build-deps curl \
  && curl -L https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz | tar xz -C /usr/local/bin \
  && chmod +x /usr/local/bin/doctl \
  && apk del --no-cache --purge .build-deps


FROM base as kubectl-build

ENV KUBECTL_VERSION=1.16.0

RUN apk add --no-cache --virtual .build-deps curl \
  && curl -L https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl \
  && apk del --no-cache --purge .build-deps


FROM base

RUN apk add --no-cache ca-certificates

COPY --from=doctl-build /usr/local/bin/doctl /usr/local/bin/doctl
COPY --from=kubectl-build /usr/local/bin/kubectl /usr/local/bin/kubectl

ENTRYPOINT ["/usr/local/bin/doctl"]
CMD ["help"]
