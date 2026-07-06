<div align="center" width="100%">

[![GitHub stars](https://img.shields.io/github/stars/deinfreu/hytale-server-container?style=for-the-badge&color=daaa3f)](https://github.com/deinfreu/hytale-server-container)
[![GitHub last commit](https://img.shields.io/github/last-commit/deinfreu/hytale-server-container?style=for-the-badge)](https://github.com/deinfreu/hytale-server-container)
[![Discord](https://img.shields.io/discord/1458149014808821965?style=for-the-badge&label=Discord&labelColor=5865F2)](https://discord.gg/M8yrdnHb32)
[![Docker Pulls](https://img.shields.io/docker/pulls/deinfreu/hytale-server?style=for-the-badge)](https://hub.docker.com/r/deinfreu/hytale-server)
[![Size (tag)](https://img.shields.io/docker/image-size/deinfreu/hytale-server/latest-alpine-liberica?sort=date&style=for-the-badge&label=ALPINE%20LIBERICA%20SIZE)](https://hub.docker.com/layers/deinfreu/hytale-server/latest-alpine-liberica/images/)
[![GitHub license](https://img.shields.io/github/license/deinfreu/hytale-server-container?style=for-the-badge)](https://github.com/deinfreu/hytale-server-container/blob/main/LICENSE)

Simply use the docker run command or docker compose, follow the authentication steps in the terminal, and your server will be ready in seconds. Designed by a community of 10+ contributors, this image prioritizes stability, security, and performance, allowing you to focus on managing your world rather than debugging your environment.

</div>

## Quick start

Install docker [CLI](https://docs.docker.com/engine/install/) on linux or the [GUI](https://docs.docker.com/desktop) on windows, macos and linux

You can run the container by running this in your CLI

```bash
docker run \
  --name hytale-server \
  -e SERVER_IP="0.0.0.0" \
  -e SERVER_PORT="5520" \
  -e PROD="FALSE" \
  -e DEBUG="FALSE" \
  -e TZ="Europe/Amsterdam" \
  -p 5520:5520/udp \
  -v "hytale-server:/home/container" \
  -v "/etc/machine-id:/etc/machine-id:ro" \
  --restart unless-stopped \
  deinfreu/hytale-server:latest
```

Alternatively, you can deploy using Docker Compose. Use the configuration below or explore the [examples](https://github.com/deinfreu/hytale-server-container/tree/main/examples) folder for more advanced templates.

```bash
services:
  hytale:
    image: deinfreu/hytale-server:latest
    container_name: hytale-server
    environment:
      SERVER_IP: "0.0.0.0"
      SERVER_PORT: "5520"
      PROD: "FALSE"
      DEBUG: "FALSE"
      TZ: "Europe/Amsterdam"
    restart: unless-stopped
    ports:
      - "5520:5520/udp"
    volumes:
      - ./data:/home/container
      - /etc/machine-id:/etc/machine-id:ro
    tty: true
    stdin_open: true
```

## Support & Resources

**Support:** 
- OS Specific installation guid at [Guide](https://hytale-server-container.com/guide/)
- Full installation guide available at [Installation Guide](https://hytale-server-container.com/installation/?utm_source=github&utm_medium=social&utm_campaign=github_readme).
- Enviroment variables and more: [Technical Docs](https://hytale-server-container.com/technical/?utm_source=github&utm_medium=social&utm_campaign=github_readme).

**Troubleshooting:**
- For frequently asked questions: [FAQ](https://hytale-server-container.com/faq/?utm_source=github&utm_medium=social&utm_campaign=github_readme)
- Join our community and ask your question! [Community Discord](https://discord.com/invite/M8yrdnHb32?utm_source=github&utm_medium=social&utm_campaign=github_readme)
- To check what is actively happening to this github repo and what is planned [GitHub Issues](https://github.com/deinfreu/hytale-server-container/issues?utm_source=github&utm_medium=social&utm_campaign=github_readme)