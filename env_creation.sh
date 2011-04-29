# CHOOSE THE HOME_DIR FOR THE NODESTER USER
NODESTER_HOME_DIR="/root/nodester"
NODESTER_USER="nodester"
NODESTER_USER_PASS="YourUb3rSecretPassword!"
NODESTER_GROUP="nodester"
# PASTE YOUR USER SSH KEY IN THE VAR BELOW
YOUR_PUB_KEY=""

whoami=`whoami`
system=`uname -s`
case $whoami in
	root)
		echo "You're root! *pew pew*"
		case $system in
			'Darwin')
				groupadd $NODESTER_GROUP && \
				useradd -d $NODESTER_HOME_DIR -c "nodester user" -g $NODESTER_GROUP -m -r -N -s /bin/bash $NODESTER_USER && \
				(sleep 1s; echo $NODESTER_USER_PASS ; sleep 1s ; echo $NODESTER_USER_PASS) | passwd $NODESTER_USER && \
				break || \
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

		sh -c " mkdir -p $NODESTER_HOME_DIR/.ssh &&
					echo $YOUR_PUB_KEY > $NODESTER_HOME_DIR/.ssh/authorized_keys &&
					chmod -R 700 $NODESTER_HOME_DIR/.ssh &&
					echo \"# nodester related rules
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/nodester/proxy/start_proxy.sh *
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/nodester/proxy/stop.sh
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/nodester/scripts/launch_app.sh *
		\" >> /etc/sudoers && break " ||\
		( echo "error make FS skeleton!" ; exit 1 )
	;;
	*)
		echo "You ain't root! *:(*"
		case $system in
			'Darwin')
####
#dscl / -create /Users/toddharris
#dscl / -create /Users/toddharris UserShell /bin/bash
#dscl / -create /Users/toddharris RealName "Dr. Todd Harris"
#dscl / -create /Users/toddharris UniqueID 503
#dscl / -create /Users/toddharris PrimaryGroupID 1000
#dscl / -create /Users/toddharris NFSHomeDirectory /Local/Users/toddharris
#dscl / -passwd /Users/toddharris PASSWORD
#
#sudo /System/Library/ServerSetup/serversetup -createUser fullname shortname password
###########
				groupadd $NODESTER_GROUP && \
				useradd -d $NODESTER_HOME_DIR -c "nodester user" -g $NODESTER_GROUP -m -r -N -s /bin/bash $NODESTER_USER && \
				(sleep 1s; echo $NODESTER_USER_PASS ; sleep 1s ; echo $NODESTER_USER_PASS) | passwd $NODESTER_USER && \
				break || \
				( echo "error creating user/group!" ; exit 1 )
			;;
			'Linux')
				sudo sh -c "groupadd $NODESTER_GROUP && 
							useradd -d $NODESTER_HOME_DIR -c 'nodester user' -g $NODESTER_GROUP -m -r -N -s /bin/bash $NODESTER_USER &&
							( ( sleep 1s; echo $NODESTER_USER_PASS ; sleep 1s ; echo $NODESTER_USER_PASS ) | passwd $NODESTER_USER ) && break " ||\
				( echo "*HERE* Error while creating user/group!" ; exit 1 )
			;;
			'*')
				( echo "Your OS is not supported yet.. please contact the dev staff" ; exit 1 )
			;;
		esac

		sudo sh -c "mkdir -p $NODESTER_HOME_DIR/.ssh &&
					echo $YOUR_PUB_KEY > $NODESTER_HOME_DIR/.ssh/authorized_keys &&
					chmod -R 700 $NODESTER_HOME_DIR/.ssh &&
					echo \"# nodester related rules
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/proxy/start_proxy.sh *
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/proxy/stop.sh
$NODESTER_USER ALL = NOPASSWD: $NODESTER_HOME_DIR/scripts/launch_app.sh *
		\" >> /etc/sudoers && break" ||\
		( echo "error make FS skeleton!" ; exit 1 )
	;;
esac

exit 0
