###############################################################################
#		Mise à niveau du system
###############################################################################

### import file functions ###
. library/functions.sh
### END import file functions ###

set -u  # u pour envoyer sur l'entrée standard les variables non définies
export LC_ALL=C

pkg_manager="sudo apt-get"
type -p aptitude > /dev/null && pkg_manager="sudo aptitude"

println info " Mise à jour de la liste des paquets \n "
sleep 1
$pkg_manager update

#read -r -p "Mettre à jour les paquets de cette machine (o/N)? " answer
if ask_yn_question "\tMettre à jour les paquets de cette machine ?"; then
    println info "Faire \" $pkg_manager upgrade ... \" "
    $pkg_manager -yf upgrade
fi

################################################################################

