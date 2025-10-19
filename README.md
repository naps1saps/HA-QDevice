# Proxmox QDevice External Vote Support HomeAssistant Add-on

> ⚠️ This addon is experimental and is NOT recommended for production. Use at your own risk ⚠️

This QDevice addon is intended to provide extrnal vote support for small 2 node Proxmox clusters to keep quorum.  It is recommended to also use a QDevice with even numbered node count clusters.  It is not recommended to use a QDevice with odd numbered node count clusters.
* For more details about QDevice Setup, see [Corosync External Vote Support](https://pve.proxmox.com/pve-docs/chapter-pvecm.html#_corosync_external_vote_support)
* For more details about Corosync-qnetd, see [Debian.org Corosync-qnetd](https://manpages.debian.org/testing/corosync-qnetd)
* For more details about SSH-Server, see [How to Configure the OpenSSH Server](https://www.ssh.com/academy/ssh/sshd_config)

## Prerequisites
This addon contains an SSH server.  Proxmox needs SSH to do administrative tasks in addition to communicating with the corosync-qnetd service.  If you need to use a different port for SSH, theoretically this is possible but you will need to do the research and modifications on your own.  While using a different SSH port is available, changing it to something other than port 22 is out of the scope of this project.

## Installing the addon in Home Assistant
1) Open your Home Assistant Dashboard
2) Go to SETTINGS > ADD-ONS > ADD-ON STORE
3) Click the "..." button in the top right > REPOSITORIES
4) Copy the github link below, paste it in the Repositories window, then click ADD
```
https://github.com/naps1saps/HA-QDevice
```
5) Close the Repositories window
6) Click the "..." button in the top right > CHECK FOR UPDATES
7) Locate "HA-Q Device" and click the "Proxmox External Device Vote Support" addon
8) Click INSTALL

## Addon Setup
1) Go to the configuration tab and set a secure Env_root_Password.  An environment root password is required for the initial SSH connection by your Proxmox cluster.
2) Go to the configuration tab and toggle on Initial_Setup.
3) Save the configuration and start/restart the addon

## Registering the QDevice with your Proxmox cluster
1) Navigate to your Proxmox cluster dashboard
2) Go the terminal for each node
3) Install the `corosync-qdevice` package.  You may need to configure "no subscription" updates on your node if the update command fails.
```
apt update
apt install corosync-qdevice
```
4) On each node, ssh to your QDevice.  You will need to save the SSH key for the QDevice to the allowed hosts file.
```
ssh <IP of your HomeAssistant Device>
```
* You will be prompted for the root password that was set in the configuration tab of the HA addon "Env_root_Password"
```
    This key is not known by any other names.
    Are you sure you want to continue connecting (yes/no/[fingerprint])?
```
* Type "YES" and press enter
* Type "EXIT" and press enter
* Repeat for each node in the cluster
5) Register your QDevice with the cluster.  You only need to run this command once on any of the cluster nodes.
```
pvecm qdevice setup <IP of your HomeAssistant Device>
```
* You will be prompted for the root password that was set in the configuration tab of the HA addon "Env_root_Password"
* Make sure there were no errors
7) Verify the quorum and that the Add-on is voting
```
pvecm status
```
<img width="359" height="131" alt="image" src="https://github.com/user-attachments/assets/c528420c-b9b6-4666-8881-346ce022c8cc" />

* We can see the QDevice has a vote.  If it was added but unsuccessful, the vote count would be 0.

8) **Go back to Home Assistant addon configuration page and toggle off "Initial_Setup" then restart the addon to disable SSH login as root.**

## Useful Commands and Information
* Removing the QDevice from your Proxmox cluster
```
pvecm qdevice remove
```
* Removing an old SSH Key associated with your QDevice's IP.  You will need to do this on every node any time the addon is reinstalled.  This command will be given to you as part of the error message in Proxmox
```
ssh-keygen -f "/root/.ssh/known_hosts" -R "<HomeAssistant Device IP>"
```
