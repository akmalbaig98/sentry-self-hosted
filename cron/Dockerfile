ARG BASE_IMAGE

# Stage 1: Install cron & gosu and gather all required .so dependencies via ldd
FROM debian:trixie-slim AS builder

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG http_proxy
ARG https_proxy

RUN apt-get update && \
    apt-get install -y --no-install-recommends cron gosu && \
    mkdir -p /rootfs/binaries /rootfs/libs /rootfs/security && \
    cp /usr/sbin/cron /usr/bin/crontab /usr/sbin/gosu /rootfs/binaries/ && \
    # Copy every shared library required by cron, crontab, and PAM modules (excluding libc/ld-linux)
    ldd /usr/sbin/cron /usr/bin/crontab /usr/lib/*-linux-gnu/security/*.so 2>/dev/null | \
      awk '/=> \// && $3 !~ /(libc\.so|ld-linux)/ {print $3}' | sort -u | xargs -I {} cp -L {} /rootfs/libs/ && \
    cp -a /usr/lib/*-linux-gnu/security /rootfs/security/

# Stage 2: Your hardened base image
FROM ${BASE_IMAGE}
USER 0

COPY --from=builder /rootfs/binaries/ /usr/local/bin/
COPY --from=builder /rootfs/libs/ /usr/local/lib/
COPY --from=builder /rootfs/security/ /usr/local/lib/security/
COPY --from=builder /etc/pam.d/ /etc/pam.d/
COPY --from=builder /etc/pam.conf /etc/pam.conf

RUN ldconfig && \
    mkdir -p /var/spool/cron/crontabs /var/run && \
    chmod 1730 /var/spool/cron/crontabs && \
    chmod 755 /usr/local/bin/cron /usr/local/bin/gosu && \
    chmod 2755 /usr/local/bin/crontab

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
