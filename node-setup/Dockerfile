FROM ubuntu:20.04

RUN apt-get update && apt-get install -y \
    openssh-server \
    iproute2 \
    iputils-ping \
    curl \
    vim \
    && apt-get clean

RUN mkdir /var/run/sshd

# Allow root login via SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Set the root password to 'root' (you can change it)
RUN echo "root:root" | chpasswd

CMD ["/usr/sbin/sshd", "-D"]
