FROM python:3-alpine

RUN apk add --no-cache --virtual .build-dependencies openssl tar \
  && wget -O /usr/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
  && chmod a+x /usr/bin/confd

ENV VERSION=52e4658b40bacbe0809754ed58effc7759c3de48

RUN mkdir /miflora-mqtt-daemon \
  && apk add --no-cache bluez \
  && wget -O - https://github.com/ThomDietrich/miflora-mqtt-daemon/archive/${VERSION}.tar.gz | tar -C /miflora-mqtt-daemon --strip-components=1 -zxvf - \
  && pip install --no-cache-dir -r /miflora-mqtt-daemon/requirements.txt

RUN apk del --no-cache .build-dependencies

COPY confd /etc/confd
COPY entrypoint.sh /

WORKDIR /miflora-mqtt-daemon

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]

CMD ["python3", "miflora-mqtt-daemon"]
