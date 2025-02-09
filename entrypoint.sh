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
echo "Installing portainer-ce"
docker pull portainer/portainer-ce
docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 -p 9000:9000 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce

# Set up SSH
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
# Start SSH service
service ssh start


echo "entrypoint.sh Done."
read -n 1 -s  # Wait to not finish bash script
