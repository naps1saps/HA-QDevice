#!/usr/bin/with-contenv bashio
# shellcheck shell=bash
set -e

bashio::log.info "Stopping ssh server"
#service ssh stop

#bashio::log.info "Updating the authorized_keys"
#echo "" > ~/.ssh/authorized_keys
#chmod 600 ~/.ssh/authorized_keys
#for idx in $(bashio::config 'public_keys|keys'); do
#    PUBLIC_KEY=$(bashio::config "public_keys[${idx}].public_key")
#    echo "${PUBLIC_KEY}" >> ~/.ssh/authorized_keys
#    bashio::log.info "added: ${PUBLIC_KEY}"
#done

#### Start SSH Server (Required for Setup) ####
ENABLE_SSH=$(bashio::config 'Enable_SSH_Server')
if [ "$ENABLE_SSH" == true ]; then
  bashio::log.info "Starting SSH Server"
  service ssh start
else
  bashio::log.info "SSH Server Disabled"
fi

#### Set ROOT Password ####
bashio::log.info "Setting 'root' password"
ROOT_PWD="$(bashio::config 'AddOn_root_Password')"
echo "root:${ROOT_PWD}" | chpasswd


#bashio::log.info "Run corosync-qnetd in foreground:"
#bashio::log.info "  using -p $(bashio::config 'Port')"
#bashio::log.info "  using -s $(bashio::config 'Server_TLS')"
#bashio::log.info "  using -c $(bashio::config 'Client_TLS')"
#DEBUG=$(bashio::config 'Debug')
#bashio::log.info "  using -d ${DEBUG}"
#service corosync-qnetd stop
#corosync-qnetd -f "$([ "${DEBUG}" = "true" ] && echo "-d")" -p "$(bashio::config 'Port')" -s "$(bashio::config 'Server_TLS')" -c "$(bashio::config 'Client_TLS')"

