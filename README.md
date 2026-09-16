# Devio

Development-oriented MinIO image for local and development environments.

Devio is based on the official MinIO images published on Quay and adds a small startup layer that prepares buckets automatically.

## Image

```text
cr.umapps.net/umapps/devio
```

## What it adds

- Uses `quay.io/minio/minio` as the MinIO Server base image.
- Bundles the MinIO Client (`mc`) from `quay.io/minio/mc` in the final image.
- Starts MinIO on port `9000` with the Console on port `9001`.
- Reads `MINIO_DEV_BUCKETS` as a comma-separated list of buckets.
- For each configured bucket:
  - creates it if it does not already exist;
  - enables anonymous downloads;
  - enables versioning.

> Devio intentionally enables anonymous downloads for configured buckets. It is intended for development environments, not as a production security baseline.

## Environment variables

| Variable | Purpose |
| --- | --- |
| `MINIO_ROOT_USER` | MinIO root user. |
| `MINIO_ROOT_PASSWORD` | MinIO root password. |
| `MINIO_DEV_BUCKETS` | Comma-separated list of buckets to initialize. |

When using the included `compose.yaml`, the defaults are:

```text
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_DEV_BUCKETS=default
```

## Example

```bash
docker run --rm \
  -p 9000:9000 \
  -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  -e MINIO_DEV_BUCKETS=avatars,documents,attachments \
  cr.umapps.net/umapps/devio:beta
```

After startup, `avatars`, `documents`, and `attachments` exist with anonymous download access and versioning enabled.

## Build with Docker Compose

```bash
docker compose build
```

The Compose configuration builds both `linux/amd64` and `linux/arm64` and tags the image as:

```text
cr.umapps.net/umapps/devio:${IMAGE_TAG:-beta}
```
