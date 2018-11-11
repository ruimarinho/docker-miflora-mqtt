# ruimarinho/miflora-mqtt

Run the [miflora-mqtt-daemon](https://github.com/ThomDietrich/miflora-mqtt-daemon) in Docker with support for multi-architecture (AMD64, ARMv7 and ARMv8).

[![build status][travis-image]][travis-url]
[![ruimarinho/miflora-mqtt][docker-stars-image]][docker-hub-url]  [![ruimarinho/miflora-mqtt][docker-pulls-image]][docker-hub-url]  

## miflora-mqtt-daemon

The `miflora-mqtt-daemon` is a bluetooth low energy to mqtt gateway enabling you to receive sensor information from Xiaomi Mi Plant sensors if they are away from your home automation server.

With this container, it becomes amazingly simply to setup a Raspberry or similar device running a container-optimized operating system such as HypriotOS and transform it into a low cost sensor gateway.

## Usage

All settings of the `miflora-mqtt-daemon` can be dynamically configured via environment variables (thanks to _confd_) without having to create a new image or bind-mounting the configuration file.

The environment variable are organized into four groups, as per the original configuration file:

- `MIFLORA_GENERAL_<PROPERTY>`: populates the `[General]` section.
- `MIFLORA_DAEMON_<PROPERTY>`: populates the `[Daemon]` section.
- `MIFLORA_MQTT_<PROPERTY>`: populates the `[MQTT]` section.
- `MIFLORA_SENSORS_<INDEX>_<PROPERTY>`: populates each sensor inside the `[Sensors]` section.

Using the scheme above, the configuration can be as simple as setting the following environment variables:

```sh
docker run \
  --name miflora-mqtt \
  --net=host \
  -e 'MIFLORA_MQTT_HOSTNAME=127.0.0.1' \
  -e 'MIFLORA_SENSORS_0_Schefflera=C4:7C:8D:11:22:33' \
  -d ruimarinho/miflora-mqtt
```

Defining a sensor's location for metadata purposes via an environment variable is more complicated as `miflora-mqtt-daemon` uses the at-sign (@) as a separator, which is not valid on most shells. However, it is still possible to do it by replacing the entrypoint as shown below:

```sh
docker run --net=host \
  --name miflora-mqtt \
  --entrypoint sh \
  ruimarinho/miflora-mqtt -c \
  'env MIFLORA_SENSORS_0_Schefflera@Kitchen=C4:7C:8D:11:22:33 confd -onetime -backend env --log-level panic && python miflora-mqtt-daemon.py'
```

If you need to further customize the daemon's settings, check the next chapter for a detailed reference guide.

## Configuration Reference

| Environment Variable Name        | Description   |
| -------------------------------- | ------------- |
| `MIFLORA_GENERAL_REPORTING_METHOD` | The operation mode of the program. Determines wether retrieved sensor data is published via MQTT or stdout/file. |
| `MIFLORA_GENERAL_ADAPTER`          | The bluetooth adapter that should be used to connect to Mi Flora devices (Default: hci0) |
| `MIFLORA_DAEMON_ENABLE`            | Enable or Disable an endless execution loop (Default: true) |
| `MIFLORA_DAEMON_PERIOD`            | The period between two measurements in seconds (Default: 300) |
| `MIFLORA_MQTT_HOSTNAME`            | The hostname or IP address of the MQTT broker to connect to (Default: localhost) |
| `MIFLORA_MQTT_PORT`                | The TCP port the MQTT broker is listening on (Default: 1883) |
| `MIFLORA_MQTT_KEEPALIVE`           | Maximum period in seconds between ping messages to the broker. (Default: 60) |
| `MIFLORA_MQTT_TOPIC`               | The MQTT base topic to publish all Mi Flora sensor data topics under. Default depends on the configured reporting_mode (mqtt-json, mqtt-smarthome: miflora, mqtt-homie: homie) |
| `MIFLORA_MQTT_HOMIE_DEVICE_ID`     | Homie specific: The device ID for this daemon instance (Default: miflora-mqtt-daemon) |
| `MIFLORA_MQTT_USERNAME`            | The MQTT broker authentification username (Default: no authentication) |
| `MIFLORA_MQTT_PASSWORD`            | The MQTT broker authentification password (Default: no authentication) |
| `MIFLORA_MQTT_TLS_ENABLED`         | Enable TLS/SSL on the connection |
| `MIFLORA_MQTT_TLS_CA_CERT`         | Path to CA Certificate file to verify host |
| `MIFLORA_MQTT_TLS_CLIENT_KEY`      | Path to TLS client auth key file |
| `MIFLORA_MQTT_TLS_CLIENT_CERT`     | Path to TLS client auth certificate file |
| `MIFLORA_SENSORS_<N>_<NAME>[@LOCATION]` | Sensor configuration consisting of name, optional location and ethernet MAC address |

## Debugging

If you would like to take a look at the generated config file for debugging purposes, you can do so by running the following command:

```sh
docker run \
  --rm \
  --entrypoint sh \
  -ti ruimarinho/miflora-mqtt \
  -c 'confd -onetime -backend env -log-level debug && cat /miflora-mqtt-daemon/config.ini'
```

## Multi-Architecture Support

This container has built-in multi-architecture support for AMD64, ARMv7 (Raspberry Pi Zero W, Raspberry Pi 3B) and ARMv8 (Raspberry Pi 3B+), which means pulling `ruimarinho/miflora-mqtt` will automatically select the right image for the host's architecture.

## License

MIT

[docker-hub-url]: https://hub.docker.com/r/ruimarinho/miflora-mqtt
[docker-pulls-image]: https://img.shields.io/docker/pulls/ruimarinho/miflora-mqtt.svg?style=flat-square
[docker-stars-image]: https://img.shields.io/docker/stars/ruimarinho/miflora-mqtt.svg?style=flat-square
[travis-image]: https://img.shields.io/travis/ruimarinho/docker-miflora-mqtt.svg?style=flat-square
[travis-url]: https://travis-ci.org/ruimarinho/docker-miflora-mqtt
