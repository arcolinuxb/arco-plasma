#!/bin/bash
#set -e
#
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	Erik Dubois
# ArcoLinux	: 	https://arcolinux.info/
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

#Setting variables
#Let us change the name"
#First letter of desktop small
desktop="plasma"

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
echo "Removing the old packages.both file from work folder"
rm ../work/archiso/packages.both
echo "Copying the new packages.both file"
cp -f ../archiso/packages.both ../work/archiso/packages.both

echo "Removing old files/folders from /etc/skel"
rm -rf ../work/archiso/airootfs/etc/skel/.* 2> /dev/null

echo "getting .bashrc from arcolinux-root"
wget https://raw.githubusercontent.com/arcolinux/arcolinux-root/master/root/.bashrc-latest -O ../work/archiso/airootfs/etc/skel/.bashrc

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
	if pacman -Qi yaourt &> /dev/null; then

		echo "Installing with yaourt"
		yaourt -S --noconfirm $package

	elif pacman -Qi pacaur &> /dev/null; then

		echo "Installing with pacaur"
		pacaur -S --noconfirm --noedit  $package

	elif pacman -Qi packer &> /dev/null; then

		echo "Installing with packer"
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


cd ~/arcolinuxb-build/archiso


echo "################################################################"
read -p "In order to build an iso we need to clean your cache (y/n)?" choice

	case "$choice" in
 	 y|Y ) sudo pacman -Sc;;
 	 n|N ) echo "Script has stopped. Nothing changed." & exit;;
 	 * ) echo "Type y or n." & echo "Script ended!" & exit;;
	esac


echo "Making the Iso"

sudo ./build.sh -v
