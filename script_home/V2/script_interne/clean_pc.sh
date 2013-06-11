 #!/bin/bash
# Première version de test !

echo "script Nettoyage Crunchbang"
if which aptitude;then 
	sudo aptitude clean 
	sudo aptitude autoclean
else
	sudo apt-get clean
	sudo apt-get autoclean
fi
echo "Suppression des paquets dans le cache"
sleep 3
if find $HOME/ -name 'Trash'
rm -R $HOME/.local/share/Trash
echo "Vidage de la corbeille"
if which dpkg; then 
	sudo dpkg -P $(dpkg -l | grep '^rc' | awk '{ print $2 }') 
fi
echo "Suppression des paquets orphelins"
sleep 3
find ~/ -name '*~' -exec rm {} \;
echo "Suppression des fichiers temporaires du dossier HOME terminant par ~ "
echo "TERMINÉ"
