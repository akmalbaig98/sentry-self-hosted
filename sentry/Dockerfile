ARG SENTRY_IMAGE

# Stage 1: Temporary builder with pip to download and resolve dependencies
FROM python:3.13-slim AS builder

# Install sentry-nodestore-s3 and its dependencies (e.g., boto3) into /install
RUN pip install --no-cache-dir --target=/install \
    https://github.com/getsentry/sentry-nodestore-s3/archive/main.zip

# Stage 2: Final hardened Sentry image
FROM ${SENTRY_IMAGE}

# Customizations below need root. Newer sentry images default to the non-root
# `sentry` user, so switch explicitly and switch back at the end.
USER 0

# Copy the pre-installed package and its dependencies directly into Python's site-packages
# COPY --from=builder /install /usr/lib/python3.13/site-packages/
COPY --from=builder /install /.venv/lib/python3.13/site-packages/

COPY . /usr/src/sentry

RUN if [ -s /usr/src/sentry/enhance-image.sh ]; then \
    /usr/src/sentry/enhance-image.sh; \
    fi

# Note: Removed the deprecated requirements.txt `pip install` block since pip is not available in this image

# Let the non-root sentry user run update-ca-certificates (sentry/entrypoint.sh)
# for custom CAs mounted from ./certificates. It only needs to create symlinks
# and replace the bundle in this directory.
RUN chown sentry:sentry /etc/ssl/certs

USER sentry
