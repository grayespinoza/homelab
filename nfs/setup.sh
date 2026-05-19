#!/bin/bash -eu

sudo apt update && sudo apt upgrade -y

sudo apt install -y ufw

sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw enable

sudo apt install -y unattended-upgrades apt-listchanges

sudo tee /etc/apt/apt.conf.d/20auto-upgrades <<EOF
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

sudo tee /etc/apt/apt.conf.d/50unattended-upgrades <<EOF
Unattended-Upgrade::Origins-Pattern {
  "origin=Debian,codename=${distro_codename},label=Debian";
  "origin=Debian,codename=${distro_codename}-security,label=Debian-Security";
  "origin=Debian,codename=${distro_codename},label=Debian-Security";
};
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF

systemctl enable unattended-upgrades

sudo apt install -y nfs-kernel-server

sudo mkdir -p /etc/nfs.conf.d
sudo tee /etc/nfs.conf.d/nfsv4.conf <<EOF
[nfsd]
vers2=n
vers3=n
vers4=y
EOF

read -p "Enter Jellyfin IP address: " JELLYFIN_IP
sudo ufw allow from ${JELLYFIN_IP} to any port 2049 proto tcp

DIRS=(
  "mnt/media/anime/movies"
  "mnt/media/anime/shows"
  "mnt/media/movies"
  "mnt/media/music"
  "mnt/media/shows"
)

for dir in "${DIRS[@]}"; do
  sudo mkdir -p "/$dir"
  if ! grep -q "/$dir " /etc/exports; then
    echo "/$dir $JELLYFIN_IP(ro,sync,no_subtree_check,root_squash)" | sudo tee -a /etc/exports
  fi
done
sudo chown -R 1000:1000 "/mnt/media"
sudo chmod -R 750 "/mnt/media"

sudo exportfs -ra

sudo systemctl enable nfs-server
sudo systemctl restart nfs-server
