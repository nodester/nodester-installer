#!/bin/bash
# install Nodester - Node.JS PaaS

echo "                 _           _"
echo "                | |         | |"
echo " _ __   ___   __| | ___  ___| |_ ___ _ __"
echo "| '_ \ / _ \ / _' |/ _ \/ __| __/ _ \ '__|"
echo "| | | | (_) | (_| |  __/\__ \ ||  __/ |"
echo "|_| |_|\___/ \__,_|\___||___/\__\___|_|"
echo ""

# CHOOSE THE HOME_DIR FOR THE NODESTER USER
NODESTER_HOME_DIR="/node/nodester"
NODESTER_USER="nodester"
NODESTER_USER_PASS="YourUb3rSecretPassword!"
NODESTER_GROUP="nodester"
# PASTE YOUR USER SSH KEY IN THE VAR BELOW
YOUR_PUB_KEY=""

if ($use_color) ;
then
	BLDYEL=$(tput bold ; tput setaf 3)
	BLDVIO=$(tput bold ; tput setaf 5)
	BLDCYA=$(tput bold ; tput setaf 6)
	BLDRED=$(tput bold ; tput setaf 1)
	BLDGRN=$(tput bold ; tput setaf 2)
	NOCOLR=$(tput sgr0)
fi

whoami=`whoami`
system=`uname -s`
case $whoami in
	root)
		echo "You're root! *with great power comes great responsibility*"
		case $system in
			'Darwin')
			
				#### - http://osxdaily.com/2007/10/29/how-to-add-a-user-from-the-os-x-command-line-works-with-leopard/
				dscl . -create /Users/nodester && \
				dscl . -create /Users/nodester UserShell /bin/bash && \
				dscl . -create /Users/nodester RealName "nodester" && \
				dscl . -create /Users/nodester UniqueID 503 && \
				dscl . -create /Users/nodester PrimaryGroupID 1000 && \
				dscl . -create /Users/nodester NFSHomeDirectory $NODESTER_HOME_DIR && \
				dscl . -passwd /Users/nodester $NODESTER_USER_PASS || \
				#
				# sudo /System/Library/ServerSetup/serversetup -createUser $NODESTER_USER $NODESTER_USER NODESTER_USER_PASS && \
				###########
			
				# groupadd $NODESTER_GROUP && \
				# useradd -d $NODESTER_HOME_DIR -c "nodester user" -g $NODESTER_GROUP -m -r -N -s /bin/bash $NODESTER_USER && \
				# (sleep 1s; echo $NODESTER_USER_PASS ; sleep 1s ; echo $NODESTER_USER_PASS) | passwd $NODESTER_USER && \
				# break || \
				( echo "error making group/user!" ; exit 1 )
			;;
			'Linux')
				sh -c " groupadd $NODESTER_GROUP && \
				useradd -d $NODESTER_HOME_DIR -c \"nodester user\" -g $NODESTER_GROUP -m -r -N -s /bin/bash $NODESTER_USER && \
				( ( sleep 1s; echo $NODESTER_USER_PASS ; sleep 1s ; echo $NODESTER_USER_PASS ) | passwd $NODESTER_USER ) && \
				break " || \
				( echo "error making group/user!" ; exit 1 )
			;;
			'*')
				echo "Your OS is not supported yet.. please contact the dev staff" && exit 1 
			;;
		esac
    echo "cloning Nodester from https://github.com/nodester/nodester.git"
    echo ;
    sh -c "git clone https://github.com/nodester/nodester.git $NODESTER_HOME_DIR/nodester"
    echo "Installing the git folder shell to restrict git to per user folders"
    echo ;
    echo "writing public key to $NODESTER_HOME_DIR/.ssh/authorized_keys"
    echo ;
		sh -c " mkdir -p $NODESTER_HOME_DIR/.ssh &&
					echo $YOUR_PUB_KEY > $NODESTER_HOME_DIR/.ssh/authorized_keys &&
					chmod -R 700 $NODESTER_HOME_DIR/.ssh &&
          cd $NODESTER_HOME_DIR/nodester"
    echo "Installing the git folder shell to restrict git to per user folders"       
    sh -c " cp $NODESTER_HOME_DIR/nodester/scripts/git-shell-enforce-directory /usr/local/bin &&
          chmod +x /usr/local/bin/git-shell-enforce-directory &&
					echo \"# nodester related rules
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/nodester/proxy/start_proxy.sh *
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/nodester/proxy/stop.sh
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/nodester/scripts/launch_app.sh *
		\" >> /etc/sudoers && break " ||\
		( echo "error make FS skeleton!" ; exit 1 )
	;;
	*)
		echo "Dude, You ain't root :("
	;;
esac
    
exit 0
