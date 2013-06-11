#!/bin/bash
#
#	Installation des paquets communs à tous les OS debian

### import file functions ###
. library/functions.sh
### END import file functions ###

set -ue
export LC_ALL=C

debs_to_install="
    #
    #	CLés
    #
    debian-keyring
    debian-archive-keyring

"

debs_to_purge="
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
