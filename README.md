# MinIO Dev Image

A development-friendly MinIO image that auto-initializes required buckets at startup using `mc`.

## Features

- Starts MinIO server (ports 9000 API, 9001 Console)
- Create buckets defined in MINIO_DEV_BUCKETS=bucket1,bucket2,bucket3....
