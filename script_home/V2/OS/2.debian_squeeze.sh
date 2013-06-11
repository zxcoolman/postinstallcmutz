#!/bin/bash
#
#	TODO:
#	- Suivre la procédure du wiki

set -ue
export LC_ALL=C

################################################################################
#
#	Activation de bootlogd
#

sed -i 's/^BOOTLOGD_ENABLE=.*/BOOTLOGD_ENABLE=Yes/' /etc/default/bootlogd

################################################################################
#
#	Mise en place de la réplication externe des logs avec rsyslog
#

mkdir -p /var/log/remote

dest_file=/etc/rsyslog.d/00-from-network-clients.celya.conf
if [ -e "$dest_file" ]; then
    echo "WARNING: '$dest_file' already exists and is left unchanged" >&2
else
    mkdir -p "$(dirname "$dest_file")"
    cat <<- "_END_" > "$dest_file"
	#
	#	Redirection de tous les logs reçus de l'extérieur vers un fichier dédié.
	#
	
	## Un des deux blocs qui suit (ou les deux) doit être décommenté, soit ici, soit
	## dans /etc/rsyslog.conf. À vous de choisir sachant que l'écoute réseau ne doit
	## être lancée qu'une seule fois. Les lignes sont répétées ici afin de vous
	## permettre de laisser intact le fichier général fourni par Debian.

	## Ecoute TCP
	# $ModLoad imtcp
	# $InputTCPServerRun 514
	
	## Ecoute UDP
	# $ModLoad imudp
	# $UDPServerRun 514
	
	## Archivage des logs extérieurs dans un fichier correspondant à l'IP du client.
	## Doit être la TOUTE PREMIÈRE règle afin de ne plus traiter le log par la suite.
	$template logfile_for_remote,"/var/log/remote/%FROMHOST-IP%.log"
	if not ($FROMHOST-IP startswith '127.') then ?logfile_for_remote
	& ~
	_END_
fi

dest_file=/etc/rsyslog.d/99-to-network-server.celya.conf
if [ -e "$dest_file" ]; then
    echo "WARNING: '$dest_file' already exists and is left unchanged" >&2
else
    mkdir -p "$(dirname "$dest_file")"
    cat <<- "_END_" > "$dest_file"
	#
	#	Réplication de tous les logs internes sur une machine externe.
	#

	# Précisez l'IP et le port du ou des serveurs de logs
	#SERVEUR_NO_1_TCP#	*.*     @@192.168.1.1:514
	#SERVEUR_NO_2_UDP#	*.*     @192.168.1.2:514
	#SERVEUR_NO_3_RELP#	*.*     :omrelp:192.168.1.2:514
	_END_
fi

dest_file=/etc/logrotate.d/remote_logs.celya
if [ -e "$dest_file" ]; then
    echo "WARNING: '$dest_file' already exists and is left unchanged" >&2
else
    mkdir -p "$(dirname "$dest_file")"
    cat <<- "_END_" > "$dest_file"
	#
	#	Rotation des logs provenant des machines externes
	#
	/var/log/remote/*.log
	{
	    create 0640 root adm
	    rotate 60
	    daily
	    missingok
	    delaycompress
	    compress
	    sharedscripts

	    postrotate
	    invoke-rc.d rsyslog reload > /dev/null
	    endscript
	}
	_END_
fi

service=rsyslog
action=restart
[ -f "/etc/init.d/$service" ] && invoke-rc.d "$service" "$action"
