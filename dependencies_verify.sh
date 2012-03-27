#!/bin/bash
# simple script to verify if your system already has the needed binary for express

echo "                 _           _"
echo "                | |         | |"
echo " _ __   ___   __| | ___  ___| |_ ___ _ __"
echo "| '_ \ / _ \ / _' |/ _ \/ __| __/ _ \ '__|"
echo "| | | | (_) | (_| |  __/\__ \ ||  __/ |"
echo "|_| |_|\___/ \__,_|\___||___/\__\___|_|"
echo ""

# define your system dependencies here
declare -a sys_dependencies 
sys_dependencies=("node" "npm" "curl" "git")

# define your npm dependencies here
declare -a npm_modules_dependencies 
npm_modules_dependencies=("pool" "express" "request" "npm-wrapper" "daemon" "cradle" "connect" "coffee-script" "colors" "nodemailer" "bouncy" "nodeinfo")

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

# checking system dependencies
declare -a sys_deps_not_ok
sys_deps_not_ok=()
for sys_dep in ${sys_dependencies[@]} 
do
	type -P $sys_dep &>/dev/null \
		&& { 
			DEP_OK="I need $sys_dep and it is correctly installed." ; 
			OK_MSG="OK - :)"; 
			TRM_COL=$(tput cols) ; DEP_COL_OK=${#DEP_OK} ; OK_MSG_COL=${#OK_MSG} ; 
			COL_OK=$(( $TRM_COL - $DEP_COL_OK - $OK_MSG_COL )) ; 
			sys_dep="${BLDCYA}${sys_dep}${NOCOLR}"
			DEP_OK="I need $sys_dep and it is correctly installed." ; 
			printf '%s%*s%s' "$DEP_OK" $COL_OK "[${BLDGRN}${OK_MSG}${NOCOLR}]" >&2; 
			echo ;
		} \
		|| { 
			DEP_KO="I need $sys_dep but it is missing." ; 
			KO_MSG="KO - :("; 
			TRM_COL=$(tput cols) ; DEP_COL_KO=${#DEP_KO} ; KO_MSG_COL=${#KO_MSG} ; 
			COL_KO=$(( $TRM_COL - $DEP_COL_KO - $KO_MSG_COL )) ; 
			sys_dep="${BLDCYA}${sys_dep}${NOCOLR}"
			DEP_KO="I need $sys_dep but it is missing." ; 
			printf '%s%*s%s' "$DEP_KO" $COL_KO "[${BLDRED}${KO_MSG}${NOCOLR}]" >&2; 
			echo ;
			new_len=$(( ${#sys_deps_not_ok[@]} + 1 ))
			sys_deps_not_ok[$new_len]=$sys_dep
		} 
done
# checking npm dependencies
declare -a npm_deps_not_ok
declare -a npm_deps_to_install
npm_deps_not_ok=()
npm_deps_to_install=()

for npm_mod in ${npm_modules_dependencies[@]} 
do
	npm_version=`npm --version 2>&1`
	if [ $( echo $npm_version | grep -E '^0\.[1-3]\..*$' ) ] ; then
		installed=$(npm ls installed 2>&1 | grep -E "^$npm_mod\\@.*installed.*$" | wc -l)
	elif [ $( echo $npm_version | grep -E '1\.[0-1]\..*' ) ] ; then
		installed=$(npm -dg ls 2>&1 | grep -E '[├│└]' | grep " $npm_mod\\@" | wc -l)
	else
		installed="0"
	fi
	if [ "${installed}" -gt "0" ] ;
	then 
		DEP_OK="I need $npm_mod and it is correctly installed." ; 
		OK_MSG="OK - :)"; 
		TRM_COL=$(tput cols) ; DEP_COL_OK=${#DEP_OK} ; OK_MSG_COL=${#OK_MSG} ; 
		COL_OK=$(( $TRM_COL - $DEP_COL_OK - $OK_MSG_COL )) ; 
		npm_mod="${BLDVIO}${npm_mod}${NOCOLR}"
		DEP_OK="I need $npm_mod and it is correctly installed." ; 
		printf '%s%*s%s' "$DEP_OK" $COL_OK "[${BLDGRN}${OK_MSG}${NOCOLR}]" >&2; 
		echo ;
	else
		DEP_KO="I need $npm_mod but it is missing." ; 
		KO_MSG="KO - :("; 
		TRM_COL=$(tput cols) ; DEP_COL_KO=${#DEP_KO} ; KO_MSG_COL=${#KO_MSG} ; 
		COL_KO=$(( $TRM_COL - $DEP_COL_KO - $KO_MSG_COL )) ;
    npm_mod_to_install="${npm_mod}"
		npm_mod="${BLDVIO}${npm_mod}${NOCOLR}"
		DEP_KO="I need $npm_mod but it is missing." ; 
		printf '%s%*s%s' "$DEP_KO" $COL_KO "[${BLDRED}${KO_MSG}${NOCOLR}]" >&2; 
		echo ;
		new_len=$(( ${#npm_deps_not_ok[@]} + 1 ))
		npm_deps_not_ok[$new_len]=$npm_mod
    new_install_len=$(( ${#npm_deps_to_install[@]} + 1 ))
    npm_deps_to_install[$new_install_len]=$npm_mod_to_install    
	fi
done
# printing missing dependencies
if [ "${#sys_deps_not_ok[@]}" -gt "0" ] ;
then
	echo -n "System Components ${BLDYEL}not found${NOCOLR}: "
	for i in "${sys_deps_not_ok[@]}"
	do 
		echo -n "$i "
	done
	echo 
fi 
if [ "${#npm_deps_not_ok[@]}" -gt "0" ] ;
then 
	echo -n "NPM modules ${BLDYEL}not found${NOCOLR}: "
	for i in "${npm_deps_not_ok[@]}"
	do 
		echo -n "$i "
	done
	echo ;
  echo ;
  echo -n "I can install these missing NPM modules for you."
  echo ;
  echo -n "Typing ${BLDYEL}yes${NOCOLR} will run ${BLDYEL}npm install${NOCOLR} ${BLDVIO}[missing module]${NOCOLR} ${BLDYEL}-g${NOCOLR}"
  echo ;
  echo -n "Would you like to install these dependencies globally? [type ${BLDYEL}yes${NOCOLR} to proceed]: "
  read install_npm_modules
  if [ "$install_npm_modules" == 'yes' ] ;
  then
    declare -a npm_deps_met
    npm_deps_met=()
	  for i in "${npm_deps_to_install[@]}"
	  do
      echo -n "installing npm module ${BLDVIO}$i${NOCOLR}"
      echo ;
      sh -c "npm install $i -g"
      echo ;
      new_installed_len=$(( ${#npm_deps_met[@]} + 1 ))
      npm_deps_met[$new_installed_len]=$i
      echo
      if [ "${#sys_deps_not_ok[@]}" -eq "0" ] && [ "${#npm_deps_not_ok[@]}" -eq "${#npm_deps_met[@]}" ] ;
      then
        echo ;
        echo "All Nodester dependencies are now met"
        echo "Now, please run ${BLDYEL}sudo ./env_creation.sh${NOCOLR} to create your nodester environment"
    fi
    done
    echo ;
  else
    echo ;
    echo -n "The following NPM modules will need to be installed manually before nodester can be installed" ;
    echo ;
    for i in "${npm_deps_not_ok[@]}"
    do 
      echo -n "$i "
    done
    echo 
  fi
fi

if [ "${#sys_deps_not_ok[@]}" -gt "0" ] || [ "${#npm_deps_not_ok[@]}" -gt "0" ] ;
then
	exit 1
fi

if [ "${#sys_deps_not_ok[@]}" -eq "0" ] && [ "${#npm_deps_not_ok[@]}" -eq "0" ] ;
then
  echo ;
  echo "All Nodester dependencies are met"
  echo "Now, please run ${BLDYEL}sudo ./env_creation.sh${NOCOLR} to create your nodester environment"
  exit 1
fi

