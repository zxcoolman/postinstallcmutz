#!/bin/bash
#
#	Installation des paquets communs à tous les serveurs que nous installons (internes ou clients)

set -ue
export LC_ALL=C

debs_to_install="
    #
    #	CLés
    #
    debian-keyring
    debian-archive-keyring

    #
    #	Outils de la dernière chance
    #
    bash-static
    busybox-static
    e2fsck-static

    #
    #	Développement
    #
    binutils
    make
    patch

    #
    #	Debug
    #
    dmidecode
    gdb
    lshw
    lsof
    ltrace
    strace
    tcpdump
    tshark

    #
    #	Surveillance
    #
    atop
    htop
    iftop
    iotop
    ipmitool
    iptraf
    itop
    lm-sensors
    mytop

    #
    #	Serveurs
    #
    ntp
    rsync

    #
    #	Utilitaires réseau
    #
    bridge-utils
    dnsutils
    ethtool
    ftp-ssl
    heirloom-mailx
    host
    ipcalc
    mutt
    net-tools
    socat
    telnet
    vlan
    w3m

    #
    #	Utilitaires d'archivage
    #
    bzip2
    p7zip
    unrar-free
    unzip

    #
    #	Autres utilitaires
    #
    apt-file
    bash-completion
    bc
    gawk
    kpartx
    less
    lsb-release
    mbr
    minicom
    mlocate
    mmv
    molly-guard
    ncurses-hexedit
    psmisc
    pwgen
    screen
    time
    vim

"

debs_to_purge="
    busybox		# Remplacé par busybox-static
    # mawk		# Remplacé par gawk -- mais nécessaires pour certains programmes comme corosync
    vim-tiny		# Remplacé par vim
"

debs_to_remove="
    # Lister ici les paquets à retirer mais dont on veut conserver la configuration
"


function clean_list()
{
    IFS=$'\n'

    sed -r '
	s/^[[:space:]]+//
	s/[[:space:]]*(#.*)?$//
	/^[[:space:]]*$/d
    ' <<< "$*"
}

debs_to_install=$(clean_list "$debs_to_install")
debs_to_purge=$(clean_list "$debs_to_purge")
debs_to_remove=$(clean_list "$debs_to_remove")

# Pour améliorer la gestion des dépendances, on passe simultanément à "apt-get install"
# les paquets à installer ainsi que les paquets à retirer (suffixés par "-")
pkg_install_params="$debs_to_install"
pkg_install_params="$pkg_install_params $(echo -n "$debs_to_remove" | sed -r 's/[[:space:]]+|$/-&/')"
pkg_install_params="$pkg_install_params $(echo -n "$debs_to_purge" | sed -r 's/[[:space:]]+|$/-&/')"

# On passe les paquets à purger à "apt-get purge"
pkg_purge_params="$debs_to_purge"

#
#	Installation et retrait des paquets
#
pkg_manager="sudo apt-get"
type -p aptitude > /dev/null && pkg_manager="sudo aptitude"
$pkg_manager install $pkg_install_params
$pkg_manager purge --assume-yes $pkg_purge_params

#
#	Postinst
#
sudo update-alternatives --set editor /usr/bin/vim.basic
apt-file update
