# DevIO

Development-oriented MinIO image for local and development environments.

DevIO is based on the official MinIO images published on Quay and adds a small startup layer that prepares buckets automatically.

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

> DevIO intentionally enables anonymous downloads for configured buckets. It is intended for development environments, not as a production security baseline.

## Environment variables

| Variable              | Purpose                                        |
| --------------------- | ---------------------------------------------- |
| `MINIO_ROOT_USER`     | MinIO root user.                               |
| `MINIO_ROOT_PASSWORD` | MinIO root password.                           |
| `MINIO_DEV_BUCKETS`   | Comma-separated list of buckets to initialize. |

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

## Licensing and third-party attribution

DevIO's wrapper files (Dockerfile, Compose configuration, and entrypoint script) are provided under the [GNU Affero General Public License version 3](LICENSE) (AGPL-3.0-only). DevIO's image redistributes the **unmodified** MinIO Server binary from `quay.io/minio/minio` and the MinIO Client (`mc`) binary from `quay.io/minio/mc`; both upstream projects are also licensed under AGPLv3. Their original copyright notices are preserved separately:

- [MinIO Server NOTICE](licenses/MINIO-SERVER-NOTICE) — [upstream source](https://github.com/minio/minio) and [upstream license](https://github.com/minio/minio/blob/master/LICENSE).
- [MinIO Client NOTICE](licenses/MINIO-CLIENT-NOTICE) — [upstream source](https://github.com/minio/mc) and [upstream license](https://github.com/minio/mc/blob/master/LICENSE).

The Dockerfile installs the license text and both copyright notices under `/usr/share/licenses/devio/` in the final image. The source of DevIO's own wrapper and build scripts is in this Git repository.

### Corresponding source for distributed images

The `Dockerfile` currently references `:latest` upstream image tags. These tags are mutable, so **the upstream source associated with a particular built image must be identified from the exact binaries/images used for that build**. Record the resolved upstream image digests and the output of `minio --version` and `mc --version` in your release records, and provide the corresponding versioned upstream source when distributing images; links to upstream default branches alone do not establish exact source correspondence.

For reproducible releases, replace `:latest` with immutable upstream image digests and record those digests alongside the release. The license/notice additions in this repository do not by themselves satisfy every obligation associated with distributing a built image; review the actual image and its dependencies before publishing.
