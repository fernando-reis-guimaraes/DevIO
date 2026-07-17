#!/bin/sh
set -eu

minio server /data --console-address :9001 &
MINIO_PID=$!

until mc alias set local http://localhost:9000 "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}" >/dev/null 2>&1; do
	sleep 1
done

# MINIO_DEV_BUCKETS is a comma-separated list of buckets to create on startup. For example: "bucket1,bucket2,bucket3"
# Loop through the list and create each bucket using mc mb command
printf '%s\n' "${MINIO_DEV_BUCKETS:-}" |
	tr ',' '\n' |
	while IFS= read -r bucket; do
		[ -n "${bucket}" ] || continue
		mc mb --ignore-existing "local/${bucket}"
		mc anonymous set download "local/${bucket}" || true
		mc version enable "local/${bucket}" || true
	done

wait "${MINIO_PID}"
