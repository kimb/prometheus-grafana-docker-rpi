FROM debian:bookworm
RUN apt-get update && apt-get install -y openssh-server python3 vim sudo
RUN mkdir /var/run/sshd && \
  echo 'root:root' | chpasswd && \
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN useradd -s /bin/bash -G sudo -m pi && echo 'pi:raspberry' | chpasswd
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
