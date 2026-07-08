---
layout: default
title: "Raspberry Pi"
parent: "Guides"
nav_order: 4
---

# Raspberry Pi (ARM64)

The container image supports ARM64 architecture via QEMU emulation for the x86_64 Hytale server binary. Performance will be reduced compared to native x86_64, but the server is functional on Raspberry Pi 4 and newer models with 4GB+ RAM.

## Prerequisites

- Raspberry Pi 4 or newer with minimum 4GB RAM required
- Raspberry Pi OS (64-bit) installed
- Docker installed (`curl -fsSL https://get.docker.com | sudo sh`)

## Setup

1. **Create a project directory** and `docker-compose.yml`:

   ```yaml
   services:
     hytale:
       image: deinfreu/hytale-server:latest
       container_name: hytale-server
       restart: unless-stopped
       ports:
         - "5520:5520/udp"
       volumes:
         - ./data:/home/container
         - /etc/machine-id:/etc/machine-id:ro
       tty: true
       stdin_open: true
   ```

2. **Generate a persistent machine-id** (required for authentication):

   Raspberry Pi OS may regenerate `/etc/machine-id` across reboots, breaking server authorization. Create a local file instead:

   Modify the volumes section to use a local `machine-id` file:

   ```yaml
   volumes:
     - ./data:/home/container
     - ./machine-id:/etc/machine-id:ro
   ```

   Then generate the file from your project directory:

   ```bash
   cat /etc/machine-id > ./machine-id
   ```

3. **Start the server**:

   ```bash
   docker compose up
   ```

   The first run will download the Hytale server binary and display an authentication URL. Open it in a browser to authorize the server.

## Performance Notes

- QEMU emulation adds overhead; expect slower download and install times.
- Use `latest-alpine-liberica` tag for the smallest image size.
- Monitor RAM usage — allocate at least 4GB on your Pi.
- Running a headless Pi (no desktop environment) is recommended.

{: .note }
> ARM64 support uses QEMU static binary emulation. The server runs but may not handle large player counts efficiently.
