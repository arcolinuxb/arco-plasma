#!/bin/bash
#set -e
##################################################################################################################
# Author	:	Erik Dubois
# Website	:	https://www.erikdubois.be
# Website	:	https://www.arcolinux.info
# Website	:	https://www.arcolinux.com
# Website	:	https://www.arcolinuxd.com
# Website	:	https://www.arcolinuxb.com
# Website	:	https://www.arcolinuxiso.com
# Website	:	https://www.arcolinuxforum.com
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################
buildFolder="$HOME/arcolinuxb-build"
outFolder="$HOME/ArcoLinuxB-Out"

#Setting variables
#Let us change the name"
#First letter of desktop small

desktop="plasma"
xdesktop="plasma"

#build.sh
oldname1="iso_name=arcolinux"
newname1="iso_name=arcolinuxb-$desktop"

oldname2='iso_label="arcolinux'
newname2='iso_label="arcolinuxb-'$desktop

#os-release
oldname3='ISO_CODENAME=ArcoLinux'
newname3='ISO_CODENAME=ArcoLinuxB-'$desktop

#hostname
oldname7='ArcoLinux'
newname7='ArcoLinuxB-'$desktop

#lightdm.conf user-session
oldname9='user-session=xfce'
newname9='user-session='$xdesktop

#lightdm.conf autologin-session
oldname10='#autologin-session='
newname10='autologin-session='$xdesktop

##############  ONLY PLASMA ###############
#cursor PLASMA
oldname11='Inherits=Bibata_Ice'
newname11='Inherits=Breeze_Snow'

echo
echo "################################################################## "
tput setaf 2;echo "Phase 1 : clean up and download the latest ArcoLinux-iso from github";tput sgr0
echo "################################################################## "
echo
echo "Deleting the work folder if one exists"
[ -d ../work ] && sudo rm -rf ../work
echo "Deleting the build folder if one exists - takes some time"
[ -d $buildFolder ] && sudo rm -rf $buildFolder

echo "Git cloning files and folder to work folder"
git clone https://github.com/arcolinux/arcolinux-iso ../work

echo
echo "################################################################## "
tput setaf 2;echo "Phase 2 : Getting the latest versions for some important files";tput sgr0
echo "################################################################## "
echo
echo "Removing the old packages.x86_64 file from work folder"
rm ../work/archiso/packages.x86_64
echo "Copying the new packages.x86_64 file"
cp -f ../archiso/packages.x86_64 ../work/archiso/packages.x86_64

echo "Removing old files/folders from /etc/skel"
rm -rf ../work/archiso/airootfs/etc/skel/.* 2> /dev/null

echo "getting .bashrc from arcolinux-root"
wget https://raw.githubusercontent.com/arcolinux/arcolinux-root/master/etc/skel/.bashrc-latest -O ../work/archiso/airootfs/etc/skel/.bashrc

echo
echo "################################################################## "
tput setaf 2;echo "Phase 3 : Renaming the ArcoLinux iso";tput sgr0
echo "################################################################## "
echo
echo "Renaming to "$newname1
echo "Renaming to "$newname2
echo
sed -i 's/'$oldname1'/'$newname1'/g' ../work/archiso/build.sh
sed -i 's/'$oldname2'/'$newname2'/g' ../work/archiso/build.sh
sed -i 's/'$oldname3'/'$newname3'/g' ../work/archiso/airootfs/etc/dev-rel
sed -i 's/'$oldname7'/'$newname7'/g' ../work/archiso/airootfs/etc/hostname
sed -i 's/'$oldname9'/'$newname9'/g' ../work/archiso/airootfs/etc/lightdm/lightdm.conf
sed -i 's/'$oldname10'/'$newname10'/g' ../work/archiso/airootfs/etc/lightdm/lightdm.conf
##############  ONLY PLASMA ###############
sed -i 's/'$oldname11'/'$newname11'/g' ../work/archiso/airootfs/usr/share/icons/default/index.theme

echo
echo "################################################################## "
tput setaf 2;echo "Phase 4 : Checking if archiso is installed";tput sgr0
echo "################################################################## "
echo

package="archiso"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

		echo "################################################################"
		echo "################## "$package" is already installed"
		echo "################################################################"

else

	#checking which helper is installed
	if pacman -Qi yay &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with yay"
		echo "################################################################"
		yay -S --noconfirm $package

	elif pacman -Qi trizen &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with trizen"
		echo "################################################################"
		trizen -S --noconfirm --needed --noedit $package

	fi

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then

		echo "################################################################"
		echo "#########  "$package" has been installed"
		echo "################################################################"

	else

		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		echo "!!!!!!!!!  "$package" has NOT been installed"
		echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
		exit 1
	fi

fi


echo
echo "################################################################## "
tput setaf 2;echo "Phase 5 : Moving files to build folder";tput sgr0
echo "################################################################## "
echo

echo "Copying files and folder to build folder as root"
sudo mkdir $buildFolder
sudo cp -r ../work/* $buildFolder

sudo chmod 750 ~/arcolinuxb-build/archiso/airootfs/etc/sudoers.d
sudo chmod 750 ~/arcolinuxb-build/archiso/airootfs/etc/polkit-1/rules.d
sudo chgrp polkitd ~/arcolinuxb-build/archiso/airootfs/etc/polkit-1/rules.d
sudo chmod 750 $buildFolder/archiso/airootfs/root

echo "adding time to /etc/dev-rel"
date_build=$(date -d now)
sudo sed -i "s/\(^ISO_BUILD=\).*/\1$date_build/" $buildFolder/archiso/airootfs/etc/dev-rel

cd $buildFolder/archiso

echo
echo "################################################################## "
tput setaf 2;echo "Phase 6 : Cleaning the cache";tput sgr0
echo "################################################################## "
echo

yes | sudo pacman -Scc

echo
echo "################################################################## "
tput setaf 2;echo "Phase 7 : Building the iso";tput sgr0
echo "################################################################## "
echo

sudo ./build.sh -v

echo
echo "################################################################## "
tput setaf 2;echo "Phase 8 : Moving the iso to out folder";tput sgr0
echo "################################################################## "
echo

[ -d $outFolder ] || mkdir $outFolder
cp $buildFolder/archiso/out/arcolinuxb* $outFolder

echo
echo "################################################################## "
tput setaf 2;echo "Phase 9 : Making sure we start with a clean slate next time";tput sgr0
echo "################################################################## "
echo
echo "Deleting the build folder if one exists - takes some time"
[ -d $buildFolder ] && sudo rm -rf $buildFolder
