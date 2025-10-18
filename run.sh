#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

bashio::log.info "Stopping ssh server"
service ssh stop

#bashio::log.info "Updating the sshd_config"
#SSHD_CONFIG="$(bashio::config 'sshd_config')"
#echo "${SSHD_CONFIG}" > /etc/ssh/sshd_config

#Create config file for ssh server
#bashio::log.info "Creating the sshd_config (Port:22)"
#echo "Port 22" > /etc/ssh/sshd_config
#echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
#echo "StrictModes yes" >> /etc/ssh/sshd_config
#echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
#echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
#echo "UsePAM yes" >> /etc/ssh/sshd_config
#echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config

bashio::log.info "Updating the authorized_keys"
echo "" > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
for idx in $(bashio::config 'public_keys|keys'); do
    PUBLIC_KEY=$(bashio::config "public_keys[${idx}].public_key")
    echo "${PUBLIC_KEY}" >> ~/.ssh/authorized_keys
    bashio::log.info "added: ${PUBLIC_KEY}"
done

ENABLE_SSH=$(bashio::config 'Enable SSH Server (Required for Setup)')
if ${ENABLE_SSH}; then
  bashio::log.info "Starting SSH Server"
  service ssh start
else
  bashio::log.info "SSH Server Disabled"
fi

bashio::log.info "Setting 'root' password"
ROOT_PWD="$(bashio::config 'AddOn root Password')"
echo "root:${ROOT_PWD}" | chpasswd

bashio::log.info "Run corosync-qnetd in foreground:"
bashio::log.info "  using -p $(bashio::config 'port')"
bashio::log.info "  using -s $(bashio::config 'server_tls')"
bashio::log.info "  using -c $(bashio::config 'client_tls')"
DEBUG=$(bashio::config 'debug')
bashio::log.info "  using -d ${DEBUG}"
service corosync-qnetd stop
corosync-qnetd -f "$([ "${DEBUG}" = "true" ] && echo "-d")" -p "$(bashio::config 'port')" -s "$(bashio::config 'server_tls')" -c "$(bashio::config 'client_tls')"

