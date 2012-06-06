#!/bin/bash
#
# --------------------------------------------------------------
# download and run this file with:
#  curl -s https://raw.github.com/nodester/nodester-installer/master/nodester_auto.sh > nodester_auto.sh; 
#  chmod a+x nodester_auto.sh
#  ./nodester_auto.sh
# --------------------------------------------------------------
#

whoami=`whoami`
system=`uname -s`
case $whoami in
  root)

    # color used for printing
    use_color=true
    if ($use_color) ;
    then
      BLDYEL=$(tput bold ; tput setaf 3)
      BLDVIO=$(tput bold ; tput setaf 5)
      BLDCYA=$(tput bold ; tput setaf 6)
      BLDRED=$(tput bold ; tput setaf 1)
      BLDGRN=$(tput bold ; tput setaf 2)
      NOCOLR=$(tput sgr0)
    fi

    echo ${BLDCYA}
    echo "                     _           _"
    echo "                    | |         | |"
    echo "     _ __   ___   __| | ___  ___| |_ ___ _ __"
    echo "    | '_ \ / _ \ / _' |/ _ \/ __| __/ _ \ '__|"
    echo "    | | | | (_) | (_| |  __/\__ \ ||  __/ |"
    echo "    |_| |_|\___/ \__,_|\___||___/\__\___|_|"
    echo ${NOCOLR}

    echo "###########################################################";
    echo "#     -- STARTING NODESTER AUTO-INSTALL PROCESS --        #";
    echo "#     ${BLDYEL}>> This should be run on a fresh install. <<${NOCOLR}       #";
    echo "#     ${BLDYEL}>> It may destroy things you care about   <<${NOCOLR}       #";
    echo "#     ${BLDYEL}>> so proceed only if everything id safe! <<${NOCOLR}       #";
    echo "###########################################################";
    echo "Type '${BLDGRN}yes${NOCOLR}' if you want to install Nodester (or just press enter to exit)!";
    read keep_going
    if [ "$keep_going" != 'yes' ] ;
    then
      echo "----------------------------------------------------------";
      echo "   ok. no worries, then.       rock out!  \m/             ";
      echo "----------------------------------------------------------";
      exit;
    fi

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Make directories and fetch nodester installers           |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    mkdir ~/build
    mkdir ~/build/nodester-installer
    mkdir /node
    mkdir /node/logs
    mkdir /app
    mkdir /git

    cd ~/build/nodester-installer
    wget -q https://raw.github.com/nodester/nodester-installer/master/dependencies_verify.sh
    wget -q https://raw.github.com/nodester/nodester-installer/master/env_creation.sh
    wget -q https://raw.github.com/nodester/nodester-installer/master/package.json
    wget -q https://raw.github.com/nodester/nodester-installer/master/nodester_official_install_guide.txt
    chmod a+x *.sh

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Updating Apt-Get                                         |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    apt-get update
    
    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Updgrading outstanding apt-get updates                   |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    apt-get upgrade

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Removing Apache (it may be installed by default)         |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    apt-get remove apache2
    update-rc.d -f apache2 remove

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Installing apt-get packages                              |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    apt-get install git-core curl build-essential openssl libssl-dev psmisc couchdb htop redis-server

    #echo ${BLDCYA};
    #echo ".----------------------------------------------------------.";
    #echo "| Generating RSA Key for local machine                     |";
    #echo "'----------------------------------------------------------'";
    #echo ${NOCOLR}
    #ssh-keygen -t rsa

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Nodester: Create CouchDB Nodester account                |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    #couchdb -k;
    /etc/init.d/couchdb start
    sleep 2;
    if [ `grep -Fc "nodester" /etc/couchdb/local.ini` != "0" ]
    then
        # code if found
      echo "No need to update /etc/couchdb/local.ini, Looks like nodester change was already made."
      echo "";
    else
      # code if not found
      /etc/init.d/couchdb stop;
      # FORCE KILL COUCHDB (this gets around the kill -1 issue reported)
      ps -U couchdb -o pid= | xargs kill -9
      sleep 2;
      echo "adding nodester admin account [nodester:password] to CouchDB";
      echo "nodester = password" >> /etc/couchdb/local.ini
      #nano /etc/couchdb/local.ini
      /etc/init.d/couchdb restart;
      sleep 2;
    fi
    /etc/init.d/couchdb status
    sleep 1;

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| VERIFY: Is there a nodester admin account for CouchDB?   |";
    echo "'----------------------------------------------------------'";
    echo ${BLDVIO}
    curl http://nodester:password@127.0.0.1:5984
    sleep 1;
    echo ${NOCOLR}
    echo "Type '${BLDGRN}yes${NOCOLR}' if the response looks good. Otherwise, press ENTER to exit.";
    read keep_going
    if [ "$keep_going" != 'yes' ] ;
    then
      echo "${BLDYEL}----------------------------------------------------------";
      echo "ARG. sometimes the solution is to just restart the server.";
      echo "perhaps 'reboot', log back in, and try running this again.";
      echo "----------------------------------------------------------${NOCOLR}";
      echo "   - stay strong, young Nodester!  \m/                    ";
      echo "";  
      exit;
    fi

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Node: Installing n (the node.js version manager)         |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd ~/build
    git clone https://github.com/visionmedia/n.git
    cd n && make install

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Node: Installing node                                    |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    n 0.6.18

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Node: NPM fix for n (until patched)                      |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd /usr/local/bin
    rm npm
    ln -s /usr/local/n/current/bin/npm npm

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| INSTALL NODEJS & DEPENDENCIES...                         |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd ~/build/nodester-installer
    ./dependencies_verify.sh 

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| INSTALLING NODESTER -- :]                                |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    echo ${BLDGRN}"Press any key to edit the env_creation.sh file (set the ${BLDYEL}password for nodester${BLDGRN}))"${NOCOLR};
    echo "When you're done, just save the file and exit the editor to contiue.";
    read
    nano ./env_creation.sh
    sudo ./env_creation.sh

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| ENSURE ALL NPM DEPENDENCIES ARE MET                      |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd /node/nodester/nodester
    npm update
    npm update
    npm update

    clear;
    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| NodesterHelper: Setup Nodester!                          |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd /node/nodester/nodester
    echo ${BLDGRN}"Press any key to edit the config.js file. This is important! :)"${NOCOLR};
    echo "When you're done, just save the file and exit the editor to contiue.";
    read
    cp ./example_config.js ./config.js
    nano ./config.js
    clear;
    cp ./scripts/example_gitrepoclone.sh ./scripts/gitrepoclone.sh
    #Update scripts/gitrepoclone.sh with the key you specified in config.js
    #nano ./scripts/gitrepoclone.sh
    chown nodester -R ./var/proxy_table.json 

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| NodesterHelper: Setup CouchDB Tables                     |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd /node/nodester/nodester
    ./scripts/couchdb/create_all_couchdb_tables.js
    ./scripts/couchdb/setup_default_views.js

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| NodesterHelper: Copy over Upstart scripts                |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd /node/nodester/nodester
    cp ./upstart/* /etc/init/

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| NodesterHelper: Set permissions for /node/nodester/.ssh  |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd /node/nodester
    chown nodester -R .ssh
    chgrp nodester -R .ssh 
    cd /
    chown nodester app
    chgrp nodester app
    chown nodester git
    chgrp nodester git

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| NodesterHelper: Starting up Proxy and Main API           |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    cd ~/
    start proxy && start app

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| All done :)   Test web frontent on port 80!              |";
    echo "'----------------------------------------------------------'";
    echo ${NOCOLR}
    sleep 1;
    echo "  >> SERVER RESPONSE IS BELOW  :)";
    echo "     Note: it may look like a 404 because no apps are running yet.";
    echo ${BLDVIO}
    curl http://127.0.0.1:80
    echo ${NOCOLR}

    echo ${BLDCYA};
    echo ".----------------------------------------------------------.";
    echo "| Nodester Auto-Installation is Complete!      \m/         |";
    echo "'----------------------------------------------------------'";
    echo " \  ${BLDYEL}Here are some next steps you should take...${BLDCYA}           / ";
    echo "  | 1. get familiar with /node                           |";
    echo "  | 2. point a domain name at your server.               |";
    echo "  | 3. update paths in /node/nodester/nodester/config.js |";
    echo "  | 4. view logs in /node/logs                           |";
    echo "  | 5. change the password for user 'nodester'           |";
    echo "  | 6. set password for database (and update config.js)  |";
    echo "  | 7. run as needed >> ${BLDGRN}start${NOCOLR}|${BLDRED}stop${NOCOLR} ${BLDVIO}proxy${NOCOLR}|${BLDVIO}app${BLDCYA}            |";
    echo "  | 8. run: tail -n 50 ./nodester_auto.sh for examples   |";
    echo "  '------------------------------------------------------'";
    echo ${NOCOLR}

  ;;
  *)
    echo "Dude, You ain't root :("
  ;;
esac
    
exit 0


# ------------------------------------------------------------------------
# EXAMPLES (last 50 lines of this file) 
# ------------------------------------------------------------------------

#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
# curl -X POST -d "coupon=CouponCode&user=testuser&password=123&email=you@email.com&rsakey=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..." http://<yourdomain>/user
#
# curl -u "testuser:123" http://api.<yourdomain>/status
# -> {"status":"up","appshosted":0,"appsrunning":0}
#
# curl -u "testuser:123" http://api.<yourdomain>/apps
# -> []
#
# curl -X POST -u "testuser:123" -d "appname=testapp&start=hello.js" http://api.<yourdomain>/app
# -> {"status":"success","port":10007,"gitrepo":"nodester@git.<yourdomain>:/git/testuser/1-e0637cb80f0e660fe133a308f86eb9ad.git","start":"hello.js","running":false,"pid":"unknown"}
#
# The point of the RSA token is to allow for git clone/push without username and password.
# if it doesn't know your RSA token, you'll need the nodester user/pass ( nodester / YourUb3rSecretPassword! )
#
# git clone nodester@git.<yourdomain>:/git/testuser/1-e0637cb80f0e660fe133a308f86eb9ad.git testapp
# cd testapp
# ls
# echo "console.log('mooo');" > hello.js
# git add .
# git commit -m "first commit"
# git push origin master
#











