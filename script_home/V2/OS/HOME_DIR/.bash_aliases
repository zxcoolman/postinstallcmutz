
alias tcpdump='tcpdump -e -U -s1600'

function ssh_screen()
{
    local dest="${@: -1}"
    if [[ -z "$dest" ]];then
        screen -S cmutz -D -xRR
    else
        [[ "$dest" != *@* ]] && dest="root@$dest"
        [[ "$dest" != *.* ]] && dest="$dest"
        ssh -A -C -t "${@:1: $(($#-1))}" "$dest" 'screen -s /bin/bash -S cmutz -D -xRR || /bin/bash || /bin/sh'
    fi
}
alias vi=vim
alias viewdiff='vimdiff -R'

# Recherche dans le fichier de lease d'un serveur DHCP l'adresse IP d'une machine dont on connaît l'adresse MAC
function dhcp_mac_to_ip()
{
    local mac=$1
    local lease_file=/var/lib/dhcp/dhcpd.leases

    if [ -z "$mac" ]; then
	echo "Usage: dhcp_mac_to_ip adresse_MAC" >&2
	return 1
    elif ! [ -f "$lease_file" ]; then
	echo "ERREUR: pas de fichier '$lease_file' => est-ce qu'un serveur DHCP tourne vraiment sur cette machine ?" >&2
	return 2
    fi

    sed -r -n '
	# On mémorise l adresse IP pour plus tard
	/^lease/ { h; n; }

	# Si l adresse MAC correspond, on affiche l addresse IP mémorisée
	/hardware ethernet '"$mac"'/ { g; s/lease ([0-9.]*).*/\1/p; }
    ' "$lease_file" \
    | tail -n 1		# On ne garde que la dernière, la plus récente
}

# DERNIÈRE LIGNE !
[ -r ~/.bash_aliases_local ] && source ~/.bash_aliases_local
