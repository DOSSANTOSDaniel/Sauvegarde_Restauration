#!/bin/bash

# TITRE: Script de restauration d'un point de sauvegarde
#================================================================#

# AUTEURS: Daniel DOS SANTOS < danielitto91@gmail.com >
#----------------------------------------------------------------#
# DATE DE CRÉATION: 18/07/2018
#----------------------------------------------------------------#
# USAGE: ./restauration.sh
#----------------------------------------------------------------#
# BASH VERSION: GNU bash 4.3.30
#================================================================#

#Variables globales
user="daniel"

#Variable date du jour
dat='date_'$(date +%F'_heure_'%H-%M)

#Création des logs
mkdir -p /home/$user/sauvegardes/backup_log
exec > >(tee -a /home/$user/sauvegardes/backup_log/restauration_log$dat)
exec 2>&1

main="/home/$user/Documents"

rep_bak_ap="/home/$user/sauvegardes/backup_applications"
rep_bak_rep="/home/$user/sauvegardes/backup_dossier_perso"
rep_log="/home/$user/sauvegardes/backup_log"

ap="bak_ap_"
rep="bak_rep_"

#fonctions
function dernier
{
	last=$(ls -got $1 | grep $2* | head -1 | awk '{print $7}')

echo -e "\nVoici la dernière sauvegarde: $last \n"
}

echo -e "\n Début de la restauration "
echo -e "--------------------------\n"

#Teste si le repertoire personnel existe
if [ -d $main ]
then
	echo -e "\nLe repertoire personnel existe bien\n"
else
	echo -e "\nAttention le repertoire personnel indiqué n'existe pas!\n"
	exit
fi	

if [ ! -d $rep_bak_ap ]
then
	echo -e "\nErreur le repertoire $rep_bak_ap n'existe pas\n"
	exit
elif [ ! -d $rep_bak_rep ]
then
	echo -e "\nErreur le repertoire $rep_bak_rep n'existe pas\n"
	exit
else
	echo -e "\nLes repertoires de sauvegarde existent bien!\n"
fi 

dernier $rep_bak_rep $rep

cd $rep_bak_rep

if tar xvpfj $last -C $main 
then
	echo -e "\nVotre dossier a ete restauré\n"
else
	echo -e "\nla restauration du dossier a echoue\n"
	exit
fi

dernier $rep_bak_ap $ap

dpkg --clear-selections
if dpkg --set-selections < $rep_bak_ap/$last
then
	apt-get dselect-upgrade -y
	echo -e "\nLa sauvegarde des applications a ete restauré\n"
else
	echo -e "\nla restauration a echoue\n"
	exit
fi