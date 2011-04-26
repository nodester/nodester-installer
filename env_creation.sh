# CHOOSE THE HOME_DIR FOR THE NODESTER USER
NODESTER_HOME_DIR="/var/nodester"
NODESTER_USER="nodester"
NODESTER_USER_PASS="YourUb3rSecretPassword!"
NODESTER_GROUP="nodester"

groupadd $NODESTER_GROUP
useradd -d $NODESTER_HOME_DIR -c "nodester user" -g $NODESTER_GROUP -m -r -N -s /bin/bash $NODESTER_USER
(sleep 1s; echo $NODESTER_USER_PASS ; sleep 1s ; echo $NODESTER_USER_PASS) | passwd $NODESTER_USER

mkdir -p $HOME_DIR/.ssh
# PASTE YOUR SSH KEY IN THE VAR HERE BELOW
YOUR_PUB_KEY=""
echo $YOUR_PUB_KEY > $HOME_DIR/.ssh/authorized_keys
chmod -R 700 $HOME_DIR/.ssh

# ENABLING SUDO FOR THE NODESTER USER
echo "# nodester related rules
nodester ALL = NOPASSWD: /var/nodester/nodester/proxy/start_proxy.sh *
nodester ALL = NOPASSWD: /var/nodester/nodester/proxy/stop.sh
nodester ALL = NOPASSWD: /var/nodester/nodester/scripts/launch_app.sh *
" >> /etc/sudoers
