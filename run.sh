#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

#### Stop SSH Server ####
bashio::log.info "Stopping SSH Server"
service ssh stop

#### Get Initial Setup status from configuration page ####
INITIAL_SETUP=$(bashio::config 'Initial_Setup')

#### Create SSH Config File ####
SSH_PORT="$(bashio::config 'SSH_Port')"
bashio::log.info "Creating 'sshd_config' File"
bashio::log.info "SSH Port: ${SSH_PORT}"
echo "Port ${SSH_PORT}" > /etc/ssh/sshd_config
echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config
if [ "$INITIAL_SETUP" == true ]; then
  bashio::log.warning "Initial Setup is ENABLED. Please DISABLE Initial Setup if your QDevice has already been added to the cluster."
  bashio::log.warning "Initial Setup: Root login is allowed via SSH!"
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
else
  echo "PermitRootLogin no" >> /etc/ssh/sshd_config
fi
echo "StrictModes yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "Subsystem sftp internal-sftp" >> /etc/ssh/sshd_config

#### Start SSH Server (Required for Setup) ####
bashio::log.info "Starting SSH Server"
service ssh start

#### Set Environment 'root' Password ####
bashio::log.info "Setting 'root' password"
ROOT_PWD="$(bashio::config 'Env_root_Password')"
echo "root:${ROOT_PWD}" | chpasswd

#### Start corosync-qnetd in foreground mode + options ####
bashio::log.info "Run corosync-qnetd in foreground:"
bashio::log.info "  using -p $(bashio::config 'Corosync_Port')"
bashio::log.info "  using -s $(bashio::config 'Server_TLS')"
bashio::log.info "  using -c $(bashio::config 'Client_TLS')"
DEBUG=$(bashio::config 'Debug')
bashio::log.info "  using -d ${DEBUG}"
#Stop Daemon(background) Service
service corosync-qnetd stop

#Start in foreground mode [-f] (required for add-on to run in HA) plus other options
corosync-qnetd -f "$([ "${DEBUG}" = "true" ] && echo "-d")" -p "$(bashio::config 'Corosync_Port')" -s "$(bashio::config 'Server_TLS')" -c "$(bashio::config 'Client_TLS')"

