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

#Setting variables
#Let us change the name"
#First letter of desktop small
desktop="plasma"
calamaresdesktopname="plasma"

#build.sh
oldname1="iso_name=arcolinux"
newname1="iso_name=arcolinuxb-$desktop"

oldname2='iso_label="arcolinux'
newname2='iso_label="alb-'$desktop

#os-release
oldname3='NAME="ArcoLinux"'
newname3='NAME=ArcoLinuxB-'$desktop

oldname4='ID=ArcoLinux'
newname4='ID=ArcoLinuxB-'$desktop

#lsb-release
oldname5='DISTRIB_ID=ArcoLinux'
newname5='DISTRIB_ID=ArcoLinuxB-'$desktop

oldname6='DISTRIB_DESCRIPTION="ArcoLinux"'
newname6='DISTRIB_DESCRIPTION=ArcoLinuxB-'$desktop

#hostname
oldname7='ArcoLinux'
newname7='ArcoLinuxB-'$desktop

#hosts
oldname8='ArcoLinux'
newname8='ArcoLinuxB-'$desktop

echo
echo "################################################################## "
echo "Phase 1 : clean up and download the latest ArcoLinux-iso from github"
echo "################################################################## "
echo
echo "Deleting the work folder if one exists"
[ -d ../work ] && rm -rf ../work
echo "Deleting the build folder if one exists - takes some time"
[ -d ~/arcolinuxb-build ] && sudo rm -rf ~/arcolinuxb-build
echo "Git cloning files and folder to work folder"
git clone https://github.com/arcolinux/arcolinux-iso ../work

echo
echo "################################################################## "
echo "Phase 2 : Getting the latest versions for some important files"
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
echo "Phase 3 : Renaming the iso to BYOI and the desktop"
echo "################################################################## "
echo
echo "Renaming to ArcoLinuxB"-$desktop

sed -i 's/'$oldname1'/'$newname1'/g' ../work/archiso/build.sh
sed -i 's/'$oldname2'/'$newname2'/g' ../work/archiso/build.sh
sed -i 's/'$oldname3'/'$newname3'/g' ../work/archiso/airootfs/etc/os-release
sed -i 's/'$oldname4'/'$newname4'/g' ../work/archiso/airootfs/etc/os-release
sed -i 's/'$oldname5'/'$newname5'/g' ../work/archiso/airootfs/etc/lsb-release
sed -i 's/'$oldname6'/'$newname6'/g' ../work/archiso/airootfs/etc/lsb-release
sed -i 's/'$oldname7'/'$newname7'/g' ../work/archiso/airootfs/etc/hostname
sed -i 's/'$oldname8'/'$newname8'/g' ../work/archiso/airootfs/etc/hosts

echo
echo "################################################################## "
echo "Phase 4 : Let us build the iso"
echo "################################################################## "
echo
echo "Checking if archiso is installed"

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

	elif pacman -Qi yaourt &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with yaourt"
		echo "################################################################"
		yaourt -S --noconfirm $package

	elif pacman -Qi pacaur &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with pacaur"
		echo "################################################################"
		pacaur -S --noconfirm --noedit  $package

	elif pacman -Qi packer &> /dev/null; then

		echo "################################################################"
		echo "######### Installing with packer"
		echo "################################################################"
		packer -S --noconfirm --noedit  $package

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

	fi

fi



echo "Copying files and folder to ~/arcolinuxb-build as root"
sudo mkdir ~/arcolinuxb-build
sudo cp -r ../work/* ~/arcolinuxb-build

sudo chmod 750 ~/arcolinuxb-build/archiso/airootfs/etc/sudoers.d
sudo chmod 750 ~/arcolinuxb-build/archiso/airootfs/etc/polkit-1/rules.d
sudo chgrp polkitd ~/arcolinuxb-build/archiso/airootfs/etc/polkit-1/rules.d

echo "Deleting the work folder if one exists - clean up"
[ -d ../work ] && rm -rf ../work

cd ~/arcolinuxb-build/archiso


echo "################################################################"
echo "In order to build an iso we need to clean your cache"
echo "################################################################"

yes | sudo pacman -Scc

echo "################################################################"
echo "Building the iso - Start"
echo "################################################################"
echo

sudo ./build.sh -v

echo
echo "################################################################## "
echo "Phase 5 : Moving the iso to ~/ArcoLinuxB-Out"
echo "################################################################## "
echo

[ -d  ~/ArcoLinuxB-Out ] || mkdir ~/ArcoLinuxB-Out
cp ~/arcolinuxb-build/archiso/out/arcolinux* ~/ArcoLinuxB-Out

echo
echo "################################################################## "
echo "Phase 8 : Making sure we start with a clean slate next time"
echo "################################################################## "
echo
echo "Deleting the build folder if one exists - takes some time"
[ -d ~/arcolinuxb-build ] && sudo rm -rf ~/arcolinuxb-build
