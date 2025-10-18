ARG BUILD_FROM
FROM ${BUILD_FROM}

# install corosync-qnetd, corosync-qdevice, and openssh-server
RUN apt update &&  \
    apt install -y corosync-qnetd corosync-qdevice openssh-server &&  \
    rm -rf /var/lib/apt/lists/*

# Copy data for add-on
COPY run.sh /
COPY sshd_config /etc/ssh/
RUN chmod a+x /run.sh

# Expose corosync-qnetd port
EXPOSE 5403

# Expose SSH port
EXPOSE 22

CMD [ "/run.sh" ]