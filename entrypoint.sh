# Init docker
nohup dockerd &
echo "sleep 10 seconds to wait docker init"
sleep 10

# Make swap
dd if=/dev/zero of=/swapfile bs=1M count=2048
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


echo "Entrypoint.sh Done."
read -n 1 -s  # Wait to not finish bash script
