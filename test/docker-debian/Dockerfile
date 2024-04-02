FROM debian:bookworm
ARG DEBIAN_FRONTEND=noninteractive
# python3 is required for ansible
RUN apt-get update && apt install -y openssh-server python3 vim sudo curl
# dependencies for docker (not actually needed, but makes install on recreated container faster)
RUN apt-get install -y gnupg2 apt-transport-https ca-certificates
RUN mkdir /var/run/sshd && \
  echo 'root:root' | chpasswd && \
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN useradd -s /bin/bash -G sudo -m pi && echo 'pi:raspberry' | chpasswd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
