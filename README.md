# Deluge with Wireguard in Docker

Torrent privately without messing up network settings.

## Setup

- `cp config.example config` and fill in the downloads directory for torrent data
- `mkdir wg-configs` and copy in wireguard config files

## Usage

Build the image with `build`. To run the container, use `run` (`run -d` to daemonize). Access the web UI at `http://localhost:8112/`. Stop the container with `stop`, and get a shell in the container with `getshell` in case something goes wrong.

## Permissions

Make sure `run` is executed as the user that you want to have ownership over the downloads directory. The scripts create a user in the container corresponding to the user executing `run` and deluged is executed by that user.
