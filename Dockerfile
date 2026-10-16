FROM quay.io/minio/mc:latest AS mc

FROM quay.io/minio/minio:latest

COPY --from=mc /usr/bin/mc /usr/local/bin/mc
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY LICENSE /usr/share/licenses/devio/LICENSE
COPY licenses/MINIO-SERVER-NOTICE /usr/share/licenses/devio/MINIO-SERVER-NOTICE
COPY licenses/MINIO-CLIENT-NOTICE /usr/share/licenses/devio/MINIO-CLIENT-NOTICE
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000 9001
VOLUME ["/data"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
