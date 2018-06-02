#!/bin/bash
set -e
#
##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	Erik Dubois
# ArcoLinux	: 	https://arcolinux.com/
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

[ -d ~/Documents/ArcoLinuxB ] || mkdir ~/Documents/ArcoLinuxB

echo "moving iso to documents"
cp ~/arcolinuxb-build/archiso/out/arcolinux* ~/Documents/ArcoLinuxB
