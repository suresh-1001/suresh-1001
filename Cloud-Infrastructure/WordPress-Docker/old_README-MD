Docker Infra Stack — Technitium DNS + Portainer + NGINX Proxy Manager

This guide deploys a small homelab/infra stack on Ubuntu 22.04 LTS using Docker Compose:

Technitium DNS – Local/LAN DNS & overrides

Portainer – Docker GUI

NGINX Proxy Manager (NPM) – Reverse proxy + Let’s Encrypt (Cloudflare DNS challenge)

All IPs, domains, and tokens below are placeholders. Replace with your values.

1) Prereqs

Ubuntu 22.04 LTS (or similar)

User in the sudo group

Static LAN IP (example used here: 192.168.50.10)

A domain in Cloudflare (example: example.com)

Optional: public exposure via port-forwarding or Cloudflare Tunnel

2) Install Docker & Compose
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release

# Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Docker repo
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install engine + compose plugin
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Use docker without sudo (re-login or `newgrp docker`)
sudo usermod -aG docker $USER
newgrp docker

docker run hello-world
docker compose version

3) Project Layout
infra-stack/
├─ .env
├─ stack.yml
└─ README.md  (optional)


Create the directory and enter it:

mkdir -p ~/infra-stack && cd ~/infra-stack

4) .env (edit and save)
# ---------- General ----------
LAN_IP=192.168.50.10

# ---------- Domain (Cloudflare) ----------
ROOT_DOMAIN=example.com
# Optional public records (if you expose services)
PUBLIC_IP=203.0.113.10

# ---------- Cloudflare DNS Challenge ----------
CF_API_TOKEN=PASTE_YOUR_CLOUDFLARE_DNS_EDIT_TOKEN

# ---------- Ports (change if needed) ----------
TECHNITIUM_WEB=5380
PORTAINER_WEB=9000
NPM_WEB=81
HTTP_PORT=80
HTTPS_PORT=443


The CF_API_TOKEN should be a Cloudflare API token with Zone:DNS Edit for your domain.

5) stack.yml (Compose file)
version: "3.9"

services:
  technitium-dns:
    image: technitium/dns-server
    container_name: technitium-dns
    restart: unless-stopped
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "${TECHNITIUM_WEB}:${TECHNITIUM_WEB}"     # Web UI
      - "853:853/tcp"                              # DNS over TLS (optional)
    environment:
      - DNS_SERVER_DOMAIN=dns.${ROOT_DOMAIN}
    volumes:
      - technitium-data:/etc/dns

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: unless-stopped
    ports:
      - "${PORTAINER_WEB}:${PORTAINER_WEB}"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - portainer-data:/data

  nginx-proxy-manager:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    ports:
      - "${HTTP_PORT}:80"
      - "${HTTPS_PORT}:443"
      - "${NPM_WEB}:81"
    environment:
      # Used when requesting DNS challenge certs
      - CF_API_TOKEN=${CF_API_TOKEN}
    volumes:
      - npm-data:/data
      - npm-letsencrypt:/etc/letsencrypt

volumes:
  technitium-data:
  portainer-data:
  npm-data:
  npm-letsencrypt:


Start the stack:

docker compose up -d

6) If Technitium can’t bind port 53

Ubuntu’s systemd-resolved may hold port 53. Free it:

sudo systemctl disable systemd-resolved
sudo systemctl stop systemd-resolved
sudo rm -f /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf   # or 8.8.8.8
docker compose down && docker compose up -d

7) Access URLs
Service	URL (example)
Technitium	http://${LAN_IP}:${TECHNITIUM_WEB}
Portainer	http://${LAN_IP}:${PORTAINER_WEB}
NPM Admin	http://${LAN_IP}:${NPM_WEB}

NPM default login: admin@example.com / changeme → change immediately.

8) Local DNS (Technitium)

Create A records for friendly names on your LAN:

Hostname	IP
portainer.lan.local	${LAN_IP}
proxy.lan.local	${LAN_IP}
dns.lan.local	${LAN_IP}

Point your client/router DNS to ${LAN_IP} if you want local resolution.

9) Public DNS & SSL (Cloudflare DNS Challenge)

Cloudflare (for example.com):

Add A records (if exposing publicly):

portainer.example.com → ${PUBLIC_IP}

proxy.example.com → ${PUBLIC_IP}

NGINX Proxy Manager:

Add Proxy Host → portainer.example.com → http://${LAN_IP}:${PORTAINER_WEB}

SSL tab → Request a new cert → Use DNS Challenge → Provider: Cloudflare

In the credentials field, paste:

dns_cloudflare_api_token=${CF_API_TOKEN}


(Optional) Request a wildcard *.example.com certificate once, then reuse.

If you don’t want to expose your WAN IP, consider Cloudflare Tunnel and skip port-forwarding.

10) Useful Commands
# Status
docker compose ps
docker compose logs -f nginx-proxy-manager

# Restart a single service
docker compose restart portainer

# Stop and remove (keep volumes)
docker compose down

# Full cleanup (removes volumes!)
docker compose down -v

11) Hardening Tips

Create unique admin users in Portainer and NPM; disable defaults.

Limit NPM admin (:81) to trusted IPs (NPM Access Lists or firewall).

Back up volumes: technitium-data, portainer-data, npm-data, npm-letsencrypt.

Keep secrets in .env (don’t commit real tokens).

Run on a non-privileged user; consider host firewall rules (UFW).

Use Cloudflare Tunnel to avoid exposing ports 80/443 from your home/LAN.

Attribution / License

This guide is generic and sanitized for public sharing. Feel free to adapt it for your environment.
