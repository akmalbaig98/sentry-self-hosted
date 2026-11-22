#!/usr/bin/env sh

if [ "$(ls -A /usr/local/share/ca-certificates/ 2>/dev/null)" ]; then
  if command -v update-ca-certificates >/dev/null 2>&1; then
    update-ca-certificates
  fi
fi

# POSIX equivalent of `declare -p` to dump environment variables safely
export -p | grep -Ev '^(export )?(BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID|PWD|OLDPWD)=' >/container.env

{
  for cron_job in "$@"; do
    printf 'SHELL=/bin/sh\n'
    # Extract schedule (first 5 fields) and command, sourcing /container.env before running
    sched=$(printf '%s' "$cron_job" | awk '{print $1, $2, $3, $4, $5}')
    cmd=$(printf '%s' "$cron_job" | cut -d' ' -f6-)
    printf '%s . /container.env; %s > /proc/1/fd/1 2>/proc/1/fd/2\n' "$sched" "$cmd"
  done
} | sed -E 's/\\(.)/\1/g' | crontab -

crontab -l
exec cron -f -l -L 15
