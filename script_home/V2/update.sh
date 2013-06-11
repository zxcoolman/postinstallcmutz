#!/bin/bash
#################################################################################################
#	WARNING !!!!!!!!!!!!!!!!!								#
#	Bien lire le TODO avant d'executer le script						#
#################################################################################################
#			nom du programme : update.sh 						#
#			last update : 07/06/2013
#												#
#	description : un ensemble de script pour installer					#
#	une distrib neuve, ou pour les mises à jour su systeme					#
#												#
#	Les fichiers executés sont présent dans le dossier OS					#
#	Ils peuvent être écrit de différentes manières : 					#
#	- <Priorite>.sh										#
#	- <Priorite>_<NomSysteme>.sh								#
#	- <Priorite>_<NomSysteme>_<NomVersion>.sh						#
#	priorite : 0 à n : ordre d'execution des scripts					#
#	NomSysteme : ubuntu, debian, centOS ... (lsb_release --short --id)			#
#	NomVersion : quantal, maverick, wheezy, squeeze ... (lsb_release --short --codename)	#
#												#
#################################################################################################


### import file functions ###
. library/functions.sh
### END import file functions ###

export LOGFILE=./log.`date +%s`.out

println info "\n\tLOGFILE : $LOGFILE\n"

### ask if this machine is client or serveur 
while true;
do
    println info "\tAre you serveur OR client ?\n\n\t choice (serveur or client) :"; read type_CS
    if [[ "$type_CS" = "client" || "$type_CS" = "serveur" ]]; then
	export SCRIPT_TYPE=$type_CS
	break

    else
	println warn "\tAre you for real ? Please enter (serveur) OR (client) :"; read type_CS
	
    fi
done

#### to ask copy configuration file ####
if ask_yn_question "\tWould you copy configuration file for user $(id -u -n) ?"; then
    for file_exist in `find $(pwd)/OS/HOME_DIR/ -type f -exec basename {} \;`; do
	if ask_yn_question "\tWould you copy $file_exist ?"; then
	    if [ -e $HOME/$file_exist ]; then
		println warn "\tFile $file_exist already exists."
		if ! ask_yn_question "\tWould you like to replace it ?"; then
		    println error "\tFile not replaced. Exiting"
		else 
		    cp -va OS/HOME_DIR/$file_exist $HOME/
		    chown $(id -u -n):$(id -u -n) $HOME/$file_exist
		    println info "\tFile replaced. Exiting"
		fi
	    else
		cp -va OS/HOME_DIR/$file_exist $HOME/
		chown $(id -u -n):$(id -u -n) $HOME/$file_exist
		println info "\tFile copied"
	    fi
	fi
    done
    chmod +x $HOME/whereami
fi


#### search package lsb_release ###
if ! type -p lsb_release > /dev/null; then
    echo "Avant toute chose, installez le programme lsb_release (paquet lsb-release sur Debian et CentOS et redhat-lsb sur RedHat)" >&2
    exit 2
fi

### search aptitude else ask installation ###
if ! type -p aptitude > /dev/null; then
    if ask_yn_question "\t*** Le paquet aptitude n'est pas présent, voulez-vous l'installer ? ***"; then sudo apt-get -y install aptitude; fi
else echo " *** aptitude déjà installé sur cette machine *** ;) "
fi
sleep 1
### search sudo else ask installation ###
if ! type -p sudo > /dev/null; then
    if ask_yn_question "\t*** Le paquet sudo n'est pas présent, voulez-vous l'installer ? ***"; then sudo apt-get -y install sudo; fi
else echo " *** sudo déjà installé sur cette machine *** ;) "
fi

### update/upgrade/install for type distribution  ###
detectdistro

#dist_vendor=$(lsb_release --short --id | tr [A-Z] [a-z])
dist_vendor=$distro
println info "\t$distro"
dist_name=$(lsb_release --short --codename | tr [A-Z] [a-z])
cd "$(dirname "$0")"		# WARNING: current directory has changed!
num_scripts=0
num_failures=0

if  ! ask_yn_question "\t*** Vous avez une '$dist_vendor - $dist_name' ***"; then
    read -r -p " *** Renseigner le nom du syteme (ubuntu,debian,linux_mint) *** " dist_vendor
    read -r -p " *** Renseigner le nom de votre version (quantal,wheezy) *** " dist_name
fi


for i in {0..9}; do
  postinst_base="./OS/$i"
  postinst_vendor_base="$postinst_base.${dist_vendor}"
  postinst_dist_base="${postinst_vendor_base}_$dist_name"

   println info "
   postinst_base : $postinst_base.sh\n postinst_vendor_base: $postinst_vendor_base.sh \n 
   postinst_dist_base : $postinst_dist_base \n 
   "


   for script in "$postinst_base.sh" "$postinst_vendor_base.sh" "$postinst_dist_base.sh" "$postinst_base".ALL.*.sh "$postinst_vendor_base".*.sh "$postinst_dist_base".*.sh; do
	println "\n\n  script en cours d'execution : $script\n\n"
	[ -f "$script" -a -s "$script" ] || continue
	cat <<- _END_ >&2

	################################################################################
	#
	#	$(readlink -f "$script")
	#
	_END_
	let "num_scripts++"
	if ! bash -u -e "$script"; then
	    echo "*** ATTENTION: une erreur s'est produite dans le script '$script' ***" >&2
	    let "num_failures++"
	fi
    done
done

source ~/.bashrc


clear

echo -e "\n\n\n"

echo >&2
if [ "$num_scripts" -eq 0 ]; then
    echo "ATTENTION: aucun script n'a été exécuté."
elif [ "$num_failures" -eq 0 ]; then
    echo "$num_scripts scripts ont été exécutés sans erreur."
else
    echo "$num_scripts scripts ont été exécutés."
    echo "ATTENTION: $num_failures scripts se sont terminés avec une erreur."
fi >&2

echo -e "\n\n\n"

# pour le fun ......
chmod +x script_interne/resume_system.sh
./script_interne/resume_system.sh
sleep 2
 
chmod +x script_interne/clean_pc.sh
./script_interne/clean_pc.sh
sleep 2
