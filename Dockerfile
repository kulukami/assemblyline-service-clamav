FROM cccs/assemblyline-v4-service-base:stable
ENV SERVICE_PATH service.main.ClamAVService

USER root
RUN apt-get update && \
    apt-get install -y clamav-daemon gcc && \
    mkdir /opt/clamav_db/ && \
    chown assemblyline:assemblyline /opt/clamav_db/

USER assemblyline
COPY requirements.txt requirements.txt

RUN pip install --no-cache-dir --user --requirement requirements.txt && rm -rf ~/.cache/pip

WORKDIR /opt/al_service
COPY . .

USER root

RUN sed -i "s|\(image: \).*\(/assemblyline.*\)|\1kulukami\2|g" service_manifest.yml && \
    sed -i "s/\$SERVICE_TAG/$(cat VERSION_BASE)$(cat VERSION)/g" service_manifest.yml

# UPGRADE CLAMAV-DAEMON
RUN apt-get update && apt-get install -y clamav-daemon

USER assemblyline
