#!/data/data/com.termux/files/usr/bin/bash -e
# Copyright ©2018 by Hax4Us. All rights reserved.  🌎 🌍 🌏 🌐 🗺
#
# https://hax4us.com
################################################################################

# colors

red='\033[1;31m'
yellow='\033[1;33m'
blue='\033[1;34m'
reset='\033[0m'

# Clean up
pre_cleanup() {
	find $HOME -name "kali*" -type d -exec rm -rf {} \;
} 

post_cleanup() {
	find $HOME -name "kalifs*" -type f -exec rm -rf {} \;
} 

		# Get patched proot binary for aarch64

proot_patch() {
	printf "\n\n"
		axel --alternate https://github.com/Hax4us/Nethunter-In-Termux/raw/beta/proot
			mv proot $PREFIX/bin
				chmod +x $PREFIX/bin/proot
				apt-mark hold proot 		
	}

# Utility function for Unknown Arch

#####################
#    Decide Chroot  #
#####################

setchroot() {
	chroot=minimal
}
unknownarch() {
figlet -f shadow Cesar Hack'\033[1;33m'
	printf "$red"
	echo "[*] Unknown Architecture :("
	printf "$reset"
	exit
}

# Utility function for detect system

checksysinfo() {
	printf "$blue [*] Checking host architecture ..."
	case $(getprop ro.product.cpu.abi) in
		arm64-v8a)
			SETARCH=arm64
			;;
		armeabi|armeabi-v7a)
			SETARCH=armhf
			;;
		*)
			unknownarch
			;;
	esac
}

# Check if required packages are present

checkdeps() {
	printf "${blue}\n"
	echo " [*] Updating apt cache..."
	apt update -y &> /dev/null
	echo " [*] Checking for all required tools..."

	for i in proot tar axel; do
		if [ -e $PREFIX/bin/$i ]; then
			echo "  • $i is OK"
		else
			echo "Installing ${i}..."
			apt install -y $i || {
				printf "$red"
				echo " ERROR: check your internet connection or apt\n Exiting..."
				printf "$reset"
				exit
			}
		fi
	done
}

# URLs of all possibls architectures

seturl() {
	URL="https://build.nethunter.com/kalifs/kalifs-20171013/kalifs-${1}-${chroot}.tar.xz"
}

# Utility function to get tar file

gettarfile() {
	printf "$blue [*] Getting tar file...$reset\n\n"
	DESTINATION=$HOME/kali-${SETARCH}
	seturl $SETARCH
	axel --alternate "$URL"
	rootfs="kalifs-${SETARCH}-${chroot}.tar.xz"
}

# Utility function to get SHA

getsha() {
	printf "\n${blue} [*] Getting SHA ... $reset\n\n"
	axel --alternate "https://build.nethunter.com/kalifs/kalifs-20171013/kalifs-${SETARCH}-${chroot}.sha512sum"
}

# Utility function to check integrity

checkintegrity() {
	printf "\n${blue} [*] Checking integrity of file...\n"
	echo " [*] The script will immediately terminate in case of integrity failure"
	printf ' '
	sha512sum -c kalifs-${SETARCH}-${chroot}.sha512sum || {
		printf "$red Sorry :( to say your downloaded linux file was corrupted or half downloaded, but don't worry, just rerun my script\n${reset}"
		exit 1
	}
}

# Utility function to extract tar file

extract() {
	printf "$blue [*] Extracting... $reset\n\n"
	proot --link2symlink tar -xf $rootfs 2> /dev/null || :
}

# Utility function for login file

createloginfile() {
	bin=${PREFIX}/bin/startkali
	cat > $bin <<- EOM
#!/data/data/com.termux/files/usr/bin/bash -e
unset LD_PRELOAD
exec proot --link2symlink -0 -r ${DESTINATION} -b /dev/ -b /sys/ -b /proc/ -b /storage/ -b $HOME -w $HOME /usr/bin/env -i HOME=/root USER=root TERM="$TERM" LANG=$LANG PATH=/bin:/usr/bin:/sbin:/usr/sbin /bin/bash --login
EOM

	chmod 700 $bin
}

printline() {
	printf "${blue}\n"
	echo " #-----------------------------------------------#"
}

# Start
clear
	printf "${red}\n"
	echo "   __   _       _   _   _      _   _                 _"
	echo "  | |/ /__ _| (_) | \ | | ___| |_| |__  _   _ _ __ | |_ ___ _ __ "
	echo "  |   // _  | | | |  \| |/ _ \ __|  _ \| | | |  _ \| __/ _ \  __|"
	echo "  | . \ (_| | | | | |\  |  __/ |_| | | | |_| | | | | ||  __/ |"
	echo "  |_|\_\__,_|_|_| |_| \_|\___|\__|_| |_|\__,_|_| |_|\__\___|_|"
	printf "${green}\n"
	echo "     ____                       _   _            _"
	echo "    / ___|___  ___  __ _ _ __  | | | | __ _  ___| | _____ _ __"
	echo "   | |   / _ \/ __|/ _  |  __| | |_| |/ _  |/ __| |/ / _ \  __|"
	echo "   | |__|  __/\__ \ (_| | |    |  _  | (_| | (__|   <  __/ |"
	echo "    \____\___||___/\__,_|_|    |_| |_|\__,_|\___|_|\_\___|_ v 1.w.0|"
#EXTRAARGS="default"
#if [[ ! -z $1 ]]
#	then
#EXTRAARGS=$1
#if [[ $EXTRAARGS = "uninstall" ]]
#	then
#		cleanup
#		exit
#		fi
#		fi
# Dont run in non-home
if [ `pwd` != $HOME ]; then
printf "$red You are not in home :($reset"
exit 2
fi
printf "\n${yellow} Ahora podemos instalar kali nethunter sin ser Root cool grasias a Cesar Hacker The Gray ;) Cool\n\n"
pre_cleanup
checksysinfo
checkdeps
if [ $(getprop ro.product.manufacturer) = SAMSUNG -a $SETARCH = arm32 ]
then
proot_patch
fi
setchroot
gettarfile
getsha
checkintegrity
extract
createloginfile
post_cleanup

printf "$blue [*] Configuring Kali For You ..."

# Utility function for resolv.conf
resolvconf() {
	#create resolv.conf file 
	printf "\nnameserver 8.8.8.8\nnameserver 8.8.4.4" > ${DESTINATION}/etc/resolv.conf
} 
resolvconf

################
# finaltouchup #
################

finalwork() {
	[ -e $HOME/finaltouchup.sh ] && rm $HOME/finaltouchup.sh
	echo
	axel -a https://github.com/Hax4us/Nethunter-In-Termux/raw/master/finaltouchup.sh
	DESTINATION=$DESTINATION SETARCH=$SETARCH bash $HOME/finaltouchup.sh
} 
#finalwork

printline
printf "\n${yellow} Asta instalado kali en termux grasias a Cesar Hacker The Gray cool :)\n Don't forget to like my hard work for termux and many other things\n"
printline
printline
	printf "{$red}"
        echo "   ____                       _   _            _"
	echo " / ___|___  ___  __ _ _ __  | | | | __ _  ___| | _____ _ __"
	echo "| |   / _ \/ __|/ _  |  __| | |_| |/ _  |/ __| |/ / _ \  __|"
	echo "| |__|  __/\__ \ (_| | |    |  _  | (_| | (__|   <  __/ |"
	echo " \____\___||___/\__,_|_|    |_| |_|\__,_|\___|_|\_\___|_| v.1.2.0"
	printf"{$yellow}"
	echo "==================================================================="
	echo "  (1)  Buscame en las redes sosiales como:"
	echo "  (2)  Nombre : Cesar Hackeando desee android"
	echo "  (3)  Youtube: https://www.youtube.com/channel/UCjs0N8PbEo-se0r_4O_svNQ"
	echo "  (4)  Instagram: @The Crater viruz gray "
	echo "  (5)  Facebook: Creater viruz-the green hacking anonymous"
	printf "{$cyan}"
	echo "ejecuta kalinethunter con el comando (startkali)"
printline
printf "$reset"
