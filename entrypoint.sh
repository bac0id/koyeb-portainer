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

start_docker_daemon() {
  echo "Starting Docker daemon..."
  nohup dockerd >/var/log/dockerd.log 2>&1 &

  echo "Waiting for Docker daemon to be ready..."
  TIMEOUT=60
  START_TIME=$(date +%s)
  while ! docker info >/dev/null 2>&1; do
    if [[ $(($(date +%s) - START_TIME)) -ge $TIMEOUT ]]; then
      echo "Error: Docker daemon did not start within $TIMEOUT seconds."
      cat /var/log/dockerd.log # Output Docker daemon logs for debugging
      exit 1
    fi
    echo "Docker not yet ready, waiting..."
    sleep 2
  done
  echo "Docker daemon is ready."
}

make_swap() {
  dd if=/dev/zero of=/swapfile bs=1M count=4096 # 4096 MB for swap
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
}

run_portainer_ce() {
  echo "Installing portainer-ce:$PORTAINER_TAG"
  docker pull "portainer/portainer-ce:$PORTAINER_TAG"
  docker volume create portainer_data
  docker run -d -p 8000:8000 -p 9000:9000 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    "portainer/portainer-ce:$PORTAINER_TAG"
}

config_ssh() {
  echo "Configuring SSH server..."
  # Configure SSH for public key authentication only and disable password login
  # This is a more secure default for Docker containers.
  # Ensure that you add your public key to /root/.ssh/authorized_keys or a user's authorized_keys
  # if you intend to connect via SSH.
  sed -i 's/^#*PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
  sed -i 's/^#*PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
  sed -i 's/^#*ChallengeResponseAuthentication yes/ChallengeResponseAuthentication no/g' /etc/ssh/sshd_config
  echo "UsePAM no" >>/etc/ssh/sshd_config # Disable PAM to avoid issues with minimal environments
}

start_ssh() {
  echo "Starting SSH service..."
  # Start SSH service in the background
  service ssh start
  echo "SSH service started."
}

start_cron() {
  echo "Starting cron service..."
  service cron start
  echo "Cron service started."
}

add_cron_to_curl_myself() {
  CRON_JOB="*/10 * * * * /usr/bin/curl -s -o /dev/null $KOYEB_PUBLIC_DOMAIN"
  CRON_COMMENT="# Koyeb public domain access every 10 minutes"
  (
    crontab -l 2>/dev/null
    echo "$CRON_COMMENT"
    echo "$CRON_JOB"
  ) | crontab -
}

make_swap

start_docker_daemon
run_portainer_ce

config_ssh
start_ssh

start_cron
add_cron_to_curl_myself


echo "entrypoint.sh Done. Keeping container alive..."
tail -f /var/log/dockerd.log
