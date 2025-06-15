FROM ubuntu:latest

RUN apt update

# Install docker
RUN apt install -y ca-certificates curl
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt update
RUN apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Expose ports of portainer-ce
EXPOSE 8000
EXPOSE 9000

# Install SSH server
RUN apt install -y openssh-server

# Create SSH directory and set proper permissions
RUN mkdir /var/run/sshd
RUN chmod 0755 /var/run/sshd

# Generate SSH host keys
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""

# Copy entrypoint script
COPY entrypoint.sh .
WORKDIR /

ENTRYPOINT ["bash", "entrypoint.sh"]
