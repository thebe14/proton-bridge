# ProtonMail IMAP/SMTP Bridge Container with TLS Certificate
![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg?label=License)
![version badge](https://img.shields.io/docker/v/yssro/proton-bridge?label=Version)
![image size badge](https://img.shields.io/docker/image-size/yssro/proton-bridge?arch=amd64&label=Size)
![docker pulls badge](https://img.shields.io/docker/pulls/yssro/proton-bridge?label=Pulls)
![build badge](https://github.com/thebe14/proton-bridge/workflows/Build/badge.svg)
![GitHub issues](https://img.shields.io/github/issues/thebe14/proton-bridge?label=Issues)
![GitHub issue custom search in repo](https://img.shields.io/github/issues-search/thebe14/proton-bridge?color=red&query=is%3Aopen%20label%3Abug&label=Bugs)

This is an unofficial Docker container of the [ProtonMail Bridge](https://protonmail.com/bridge/).
It is based on work by [Xiaonan Shen](https://github.com/shenxn/protonmail-bridge-docker)
and [Hendrik Meyer](https://gitlab.com/T4cC0re/protonmail-bridge-docker). It runs ProtonMail Bridge
in a container, which allows accessing your Proton mail with any email client that supports IMAP.
Point your email client on any computer or phone to this container instead the ProtonMail Bridge GUI
app on your computer, and instead using the ProtonMail Android or iOS app on your phone.

If you spin up a container using the image from Xionan's or Hendrik's work, however,
each time a mail client connects to it you will be asked if you trust the self-signed
certificate the bridge generates and uses. To address that, this image allows supplying
a volume with a certificate for the hostname on which the bridge container
will be exposed to the internet (see environment variable `BRIDGE_HOSTNAME`). This is a
JSON file that a Traefik reverse proxy produces when configured to use Let's Encrypt
for automatic certificate generation (see the sample file [acme.json](acme.json)).

Images are available on Docker Hub at
[https://hub.docker.com/repository/docker/yssro/proton-bridge](https://hub.docker.com/repository/docker/yssro/proton-bridge)
and support Intel (`amd64`), ARM (`arm64` and `arm/v7`), and RISC devices (`riscv64`).

## Initialization

To initialize and add account(s) to the bridge, supply a volume to store the settings
and one that contains a certificate, then run the following command:

```
docker run --rm -it -v certificates:/etc/traefik/acme:ro -v proton-bridge:/root \
-e BRIDGE_HOSTNAME=my.bridge.domain yssro/proton-bridge init
```

If you want to use Docker Compose instead, you can create a copy of the provided example
[docker-compose.yaml](docker-compose.yaml) file, make a copy of the sample file
[.env.template](.env.template) and name it `.env`, modify these to suit your needs,
and then run the following command:

```
docker compose run bridge init
```

Wait for the bridge to start up, then you will see a prompt appear for the
[ProtonMail Bridge interactive shell](https://proton.me/support/bridge-cli-guide).
1. Use the `login` command and follow the instructions to add your account into
   the bridge. Repeat for each account you want to tunnel via this container.
2. Use the `cert import` command to add the certificate and its key, `/root/cert.pem`
   and `/root/key.pem`, respectively.
3. Use `info` to see the configuration information (username and password), for
   for the account(s) you added. You will need this to configure your email client.
4. Use `exit` to exit the bridge container.

> Note: The ProtonMail CLI will store the configuration in the volume `proton-bridge`
> that the above commands mount in the home of the `root` user. You can name the
> volume however you want, as long you remeber to use the same name in the commands
> to init and run the bridge (see below). Once the configuration is complete, you
> can delete the container.

## Run

To run the container, use the following command:

```
docker run -d --name=proton-bridge -v proton-bridge:/root -v certificates:/etc/traefik/acme:ro \
-e BRIDGE_HOSTNAME=my.bridge.domain -p 1025:25/tcp -p 1143:143/tcp --restart=unless-stopped yssro/proton-bridge
```

Or, if using Docker Compose, use the following command:

```
docker compose up -d
```

> Note: Make sure you mount the same `proton-bridge` volume in the home of the
> `root` user as the one you used in the command to initialize the bridge.

## Security

Please be aware that running this container will expose your bridge to the network.
Remember to use firewall if you are going to run this in an untrusted network or
on a machine that has a public IP address.

You can also use the following command to publish the port to only localhost,
which is the same behavior as the official bridge package:

```
docker run -d --name=proton-bridge -v proton-bridge:/root -v certificates:/etc/traefik/acme:ro \
-e BRIDGE_HOSTNAME=my.bridge.domain -p 127.0.0.1:1025:25/tcp -p 127.0.0.1:1143:143/tcp \
--restart=unless-stopped yssro/proton-bridge
```

You can also publish only port 25 (SMTP) if you do not need to receive any
email (e.g. as a service sending email notifications).

## Bridge CLI Guide

The initialization step exposes the bridge CLI so you can do things like switch
between combined and split mode, change proxy, etc.
The [official guide](https://protonmail.com/support/knowledge-base/bridge-cli-guide/)
gives more information on to use the CLI. You can also check out the
[ProtonMail Bridge wiki](https://deepwiki.com/ProtonMail/proton-bridge/4.4-cli-interface).
