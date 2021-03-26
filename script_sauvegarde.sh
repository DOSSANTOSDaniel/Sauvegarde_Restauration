#!/bin/bash

# TITRE: Script de création d'un point de sauvegarde
#================================================================#

# AUTEURS: Daniel DOS SANTOS < danielitto91@gmail.com >
#----------------------------------------------------------------#
# DATE DE CRÉATION: 18/07/2018
#----------------------------------------------------------------#
# USAGE: ./script_sauvegarde.sh
#----------------------------------------------------------------#
# BASH VERSION: GNU bash 4.3.30
#================================================================#

#Variable utilisateur
user="daniel"

#Création des logs
mkdir -p /home/$user/sauvegardes/backup_log
exec > >(tee -a /home/$user/sauvegardes/backup_log/log_sauv)
exec 2>&1

#Mise à jour système
apt-get update -y
apt-get upgrade -y

#Synchronisation avec un serveur de temps
apt-get install ntp ntpdate -y
ntpdate ntp1.jussieu.fr 
/etc/init.d/ntp restart
                                                            
#Variables globales
doc="/home/$user/Documents"
sauv="/home/$user/sauvegardes/"
rep_bak_ap="/home/$user/sauvegardes/backup_applications"
rep_bak_rep="/home/$user/sauvegardes/backup_dossier_perso"
rep_log="/home/$user/sauvegardes/backup_log"

#Variable date du jour
dat='date_'$(date +%F'_heure_'%H-%M)

#Variable fichiers
ap="bak_ap_"
rep="bak_rep_"

#Fonctions
function rep
{

	if [ ! -d $1 ]
	then
    	if mkdir -p $1
    	then
        	echo -e "\nCréation du répertoire $1 termine!\n"
    	else
        	echo -e "\nErreur de la création du répertoire $1\n"
        	exit
        fi
    fi
}


echo -e "\n Début de la sauvegarde "
echo -e "------------------------\n"

#Création de repertoires
for i in $sauv $rep_bak_ap $rep_bak_rep
do
	rep $i
done

#Test
if [ -d $doc ]
then
	echo -e "\nLe répertoire Documents existe bien\n"
else
	echo -e "\nAttention le répertoire Documents n'existe pas!\n"
	exit
fi

#Archivage et compression
cd $doc
if tar -cvpjf $rep_bak_rep/$rep$dat.tar.bz2 .
then
    echo -e "\n Compression terminé \n"
else
    echo -e "\n Erreur de la Compression \n"
    exit
fi

#Sauvegarde des applications
if dpkg --get-selections > $rep_bak_ap/$ap$dat
then
	echo -e "\nLe point de restauration des applications a été créé avec succès!\n"
else
	echo -e "\nLa création du point de restauration des applications a echoué\n"
fi

mv $rep_log/log_sauv $rep_log/log_sauv$dat
