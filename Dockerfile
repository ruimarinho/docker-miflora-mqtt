ARG ARCH

FROM $ARCH/golang:1.11-stretch as confd

COPY --from=hypriot/qemu-register /qemu-arm /usr/bin/qemu-arm-static
COPY --from=hypriot/qemu-register /qemu-aarch64 /usr/bin/qemu-aarch64-static

RUN mkdir -p /go/src/github.com/kelseyhightower/confd
RUN wget -O - https://github.com/kelseyhightower/confd/archive/v0.16.0.tar.gz | tar -C /go/src/github.com/kelseyhightower/confd --strip-components=1 -zxvf -
RUN go install -v github.com/kelseyhightower/confd

FROM $ARCH/python:3-slim as build

COPY --from=hypriot/qemu-register /qemu-arm /usr/bin/qemu-arm-static
COPY --from=hypriot/qemu-register /qemu-aarch64 /usr/bin/qemu-aarch64-static
COPY --from=confd /go/bin/confd /usr/local/bin/confd

RUN apt-get update && apt-get install -y --no-install-recommends openssl tar bluez wget

ARG VERSION

RUN mkdir /miflora-mqtt-daemon \
  && wget -O - https://github.com/ThomDietrich/miflora-mqtt-daemon/archive/$VERSION.tar.gz | tar -C /miflora-mqtt-daemon --strip-components=1 -zxvf - \
  && pip install --no-cache-dir -r /miflora-mqtt-daemon/requirements.txt

COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /miflora-mqtt-daemon

ENTRYPOINT ["/entrypoint.sh"]

CMD ["python", "miflora-mqtt-daemon.py"]
