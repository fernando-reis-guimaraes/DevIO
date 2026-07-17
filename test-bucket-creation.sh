#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

image_name="minio4dev-bucket-test:local"
container_name="minio4dev-bucket-test-$$"

minio_root_user="testadmin"
minio_root_password="testpassword123"

expected_buckets=(
        "test-bucket-one"
        "test-bucket-two"
        "test-bucket-three"
)

cleanup() {
        echo "Cleaning up test container..."
        docker rm --force --volumes "${container_name}" >/dev/null 2>&1 || true
}

show_diagnostics() {
        echo
        echo "Container logs:"
        docker logs "${container_name}" 2>&1 || true

        echo
        echo "Buckets found:"
        docker exec "${container_name}" \
                mc ls test \
                2>&1 || true
}

trap cleanup EXIT

command -v docker >/dev/null 2>&1 || {
        echo "Error: docker is not available." >&2
        exit 1
}

bucket_list="$(
        IFS=','
        printf '%s' "${expected_buckets[*]}"
)"

echo "Building test image..."
docker build \
        --tag "${image_name}" \
        "${script_directory}"

echo "Starting MinIO with buckets: ${bucket_list}"
docker run \
        --detach \
        --name "${container_name}" \
        --env "MINIO_ROOT_USER=${minio_root_user}" \
        --env "MINIO_ROOT_PASSWORD=${minio_root_password}" \
        --env "MINIO_DEV_BUCKETS=${bucket_list}" \
        "${image_name}" \
        >/dev/null

echo "Waiting for MinIO..."
minio_ready=false

for attempt in $(seq 1 60); do
        if docker exec "${container_name}" \
                mc alias set \
                test \
                http://127.0.0.1:9000 \
                "${minio_root_user}" \
                "${minio_root_password}" \
                >/dev/null 2>&1; then
                minio_ready=true
                break
        fi

        if [ "$(docker inspect --format '{{.State.Running}}' "${container_name}")" != "true" ]; then
                echo "Error: MinIO container stopped unexpectedly." >&2
                show_diagnostics
                exit 1
        fi

        sleep 1
done

if [ "${minio_ready}" != "true" ]; then
        echo "Error: MinIO did not become ready." >&2
        show_diagnostics
        exit 1
fi

echo "Verifying buckets..."

for bucket in "${expected_buckets[@]}"; do
        if ! docker exec "${container_name}" \
                mc stat "test/${bucket}" \
                >/dev/null 2>&1; then
                echo "Error: bucket was not created: ${bucket}" >&2
                show_diagnostics
                exit 1
        fi

        echo "Verified bucket: ${bucket}"
done

echo "Success: all expected buckets were created."
