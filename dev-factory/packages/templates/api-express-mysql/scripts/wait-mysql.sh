#!/usr/bin/env bash
set -euo pipefail

HOST="${MYSQL_HOST:-mysql}"
PORT="${MYSQL_PORT:-3306}"
ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"

echo "Waiting for MySQL at ${HOST}:${PORT} ..."

for i in $(seq 1 60); do
  if mysqladmin ping -h "${HOST}" -P "${PORT}" -uroot -p"${ROOT_PASSWORD}" --silent >/dev/null 2>&1; then
    echo "MySQL is up"
    exit 0
  fi
  sleep 1
done

echo "MySQL did not become ready in time" >&2
exit 1
