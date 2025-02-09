#!/bin/bash

# Set default portainer tag
PORTAINER_TAG="latest"

# Function to display help message
display_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Installs Portainer-CE with optional tag specification."
  echo ""
  echo "Options:"
  echo "  --portainer-tag <tag>  Specify the Portainer-CE tag (default: latest)"
  echo "  --help                Display this help message"
  exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --portainer-tag)
      PORTAINER_TAG="$2"
      shift 2
      ;;
    --help)
      display_help
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Init docker
nohup dockerd &
echo "sleep 10 seconds to wait docker init"
sleep 10

# Make swap
dd if=/dev/zero of=/swapfile bs=1M count=4096  # 4096 MB for swap
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Install portainer-ce
echo "Installing portainer-ce:$PORTAINER_TAG"
docker pull "portainer/portainer-ce:$PORTAINER_TAG"
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 -p 9000:9000 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    "portainer/portainer-ce:$PORTAINER_TAG"

# Set up SSH
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
# Start SSH service
service ssh start


echo "entrypoint.sh Done."
read -n 1 -s  # Wait to not finish bash script
