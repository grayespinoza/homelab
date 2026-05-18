#!/bin/bash -eu

sudo apt update && sudo apt upgrade -y

sudo apt install -y ufw

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw enable

sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER

sudo ufw allow 8096/tcp
sudo ufw allow 8920/tcp
sudo ufw allow 7359/udp
sudo ufw allow 1900/udp

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SCRIPT_DIR/config"
sudo chown -R 1000:1000 "$SCRIPT_DIR/config"

DIRS=(
  "mnt/media/anime/movies"
  "mnt/media/anime/shows"
  "mnt/media/movies"
  "mnt/media/music"
  "mnt/media/shows"
)

for dir in "${DIRS[@]}"; do
  sudo mkdir -p "/$dir"
done
sudo chown -R 1000:1000 "/mnt/media"

sudo apt install -y nfs-common
