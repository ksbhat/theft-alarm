#!/bin/bash
# ********************************************* #
# Author: Koustubha Bhat
# Date  : 13 - Sep - 2014
# Vrije Universiteit, Amsterdam
# ********************************************* #

ALARM_FILE="${HOME}/laptop-theft-siren.wav"
SOUND_CARD_ID=1

set_high_vol()
{
  amixer -c 1 sset Master 100% > /dev/null
}

usage()
{
   echo "Laptop theft alarm"
   echo 
   echo "Inspired by the theft of Sony Vaio Laptop of Koustubha Bhat"
   echo "at Vrije Universiteit, Amsterdam, The Netherlands on 8th Sep 2014."
   echo
   echo "#################################################"
   echo "When you want to leave your laptop alone for a while,"
   echo "do:"
   echo "1. run this script ${0} on your terminal"
   echo "2. lock your screen, so that you will have to enter password to enter back"
   echo "Effect:"
   echo "Alarm goes on, if anyone grabs your laptop!"
   echo 
   echo "Take care. Be safe!"
   echo "#################################################"
   echo 
   echo "Options:"
   echo "-install [siren sound .wav file path]		Installs and sets up the environment."
   echo "-test						Lets you try/test the alarm before you leave the laptop alone."
   
   exit 1
}

alarm()
{
  set_high_vol || echo "Coudn't set high volume :("

  if [ $1 -eq 0 ]
  then
	DONTSTOP=1
  else
	DONTSTOP=0
  fi

  count=1
  while [ $count -ge 1 ]
  do
  	aplay ${ALARM_FILE} > /dev/null 2>&1
	echo $count
	if [ $DONTSTOP -ne 1 ]
	then
		let count--
	fi
  done 
}

get_battery_state()
{
	BATTERY_STATE=`acpi -a | cut -d: -f 2`
	echo ${BATTERY_STATE}
}

enable_alarm()
{
	KEEP_RUNNING=1
	while [ ${KEEP_RUNNING} -eq 1 ]
	do
		BATTERY_STATE=`get_battery_state`
		if [[ "${BATTERY_STATE}" == "off-line" ]]
		then
			echo "Hello buddy! You are about to be caught!!!!!"
			alarm 0
		fi
	done
}

# main
if [ $# -eq 0 ]
then
	B_INIT_STATE=`get_battery_state`
	if [[ "${B_INIT_STATE}" == "off-line" ]]
	then
		echo "Please ensure the following, before you leave it alone!"
		echo
		echo " 1. Laptop is plugged-in to power supply"
		echo " 2. Laptop speakers are UNMUTED"
		echo
		echo "Then, run ${0} again..."
		echo
		exit 1
	fi
	enable_alarm
elif [[ "$1" == "-test" ]]
then
	alarm 1
elif [[ "$1" == "-install" ]]
then
	if [ "$(id -u)" != "0" ]
	then
		echo "-install option requires root previleges."
		echo "Please run ${0} with sudo command."
		echo 
		exit 1
	fi
	alarm_sound_file=`basename ${ALARM_FILE}`
	if [ $# -ge 2 ]
	then
		alarm_sound_file=$2
	fi
	echo "Using alarm file: ${alarm_sound_file}"
	cp $alarm_sound_file $HOME
	my_name=`basename ${0}`
	exitcode=0
	linkname="${HOME}/Desktop/${my_name}"
	[ -e "${linkname}" ] && rm ${linkname}
	(cp ${0} "/usr/local/bin/${my_name}" && ln -s "/usr/local/bin/${my_name}" "${linkname}") || exitcode=1
	if [ ${exitcode} -eq 0 ]
	then
		echo "Installation successful."
	else
		echo "Installation didn't complete properly."
	fi
else
	usage
fi	
