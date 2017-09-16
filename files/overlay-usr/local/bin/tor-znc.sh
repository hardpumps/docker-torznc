#!/bin/bash
#set -e

if [ -f /firstrun ]; then
	echo 'First run of the container.'
	echo 'If exist, configuration and data will be reused and upgraded as needed.'

	# Configure timezone if needed
	if [ -n "$TZ" ]; then
		echo "Configuring TimeZone... "
		cp /usr/share/zoneinfo/$TZ /etc/localtime 
		if [ $? -eq 0 ]; then echo "successful"; else echo "failed"; fi
	fi

	##
	## Ident service	
	##

	## required for znc to access ident
	if [ ! -f /var/lib/znc/.oidentd.conf ]; then 
		echo -n "Creating '/var/lib/znc/.oidentd.conf with 'touch /var/lib/znc/.oidentd.conf'... "
		touch /var/lib/znc/.oidentd.conf
		if [ $? -eq 0 ]; then echo "successful"; else echo "failed"; fi
	fi
	
	## sets permissions
	if [ -f /var/lib/znc/.oidentd.conf ]; then chown znc:znc /var/lib/znc/.oidentd.conf; fi

	## enables oidentd service

	##
	## Tor service
	##

	## enables tor service
	# su -s /bin/bash tor -c '/usr/bin/tor -f /etc/tor/torrc -d' >>/var/log/tor/tor.log 2>&1

	##
	## ZNC service
	##

	## create znc config dir
        if [ ! -d /etc/znc/configs ]; then 
		echo -n "Directory '/etc/znc/configs' doesn't exist, creating with 'mkdir -p /etc/znc/configs'... "
		mkdir -p /etc/znc/configs
		if [ $? -eq 0 ]; then echo "successful"; else echo "failed"; fi
	fi

	if [ -f /usr/src/znc.conf ]; then
		echo -n "Moving '/usr/src/znc.conf' to '/etc/znc/configs' with 'mv /usr/src/znc.conf /etc/znc/configs'... "
		mv /usr/src/znc.conf /etc/znc/configs
		if [ $? -eq 0 ]; then echo "successful"; else echo "failed"; fi
	fi
	# create run pid dir
	if [ ! -d /var/run/znc ]; then  
		echo -n "Creating '/var/run/znc/' with 'mkdir -p /var/run/znc'... "
		mkdir -p /var/run/znc/
	fi
	## create pem file
	echo -n "Creating ZNC pem file with '/usr/bin/znc --datadir=/etc/znc --makepem'... "
	su -s /bin/bash znc -c '/usr/bin/znc --datadir=/etc/znc --makepem' >>/var/log/znc/znc.log 2>&1
	if [ $? -eq 0 ]; then echo "successful"; else echo "failed"; fi
	## updates file permissions
	#chown znc:znc -R /etc/znc

	## sets permissions on znc-logs
	#chown znc:znc /var/log/znc

	## enables znc service
	echo -n "Starting ZNC daemon with 'su -s /bin/bash znc -c '/usr/bin/proxychains /usr/bin/znc --datadir=/etc/znc -f'... "
	su -s /bin/bash znc -c '/usr/bin/proxychains /usr/bin/znc --datadir=/etc/znc -f' >/var/log/znc.log 2>&1
	if [ $? -eq 0 ]; then echo "successful"; else echo "failed"; fi

fi

# delete first run
rm -f /firstrun

# Exec given CMD in Dockerfile
exec "$@"
