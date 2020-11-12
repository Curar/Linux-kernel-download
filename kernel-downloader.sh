#!/bin/bash
# 
# By Curar 2020r.
#
# Skrypt który automatycznie pobiera i kompiluje źródło jądra ze strony 
# https://kernel.org przy użyciem programu curl, gpg.
# https://github.com/gpg/gnupg
# https://gnupg.org/
#
# Write using vim editor
# https://github.com/vim/vim
# https://www.vim.org/

clear
tablica_info["0"]="
==============================================
https://kernel.org
 
Write using vim editor
 
 https://github.com/vim/vim
 https://www.vim.org/
==============================================
"
tablica_logo["0"]="
==============================================
     ...::: KERNEL AUTO DOWNLOAD'S :::...       
==============================================
"
echo -e "\e[33m${tablica_info["0"]}\e[0m"
echo -e "\e[32m${tablica_logo["0"]}\e[0m"
echo -e "\e[33mDZIEŃ DOBRY\e[0m"
echo ""
read -p "Naduś ENTER"
clear

# Definicja zmiennych
function zmienne() {
ADRES_KERNELA_PLIKI="https://cdn.kernel.org/pub/linux/kernel/v5.x/sha256sums.asc"
ADRES_KERNELA="https://cdn.kernel.org/pub/linux/kernel/v5.x/${wybor}.tar.xz"
ADRES_PODPISU="https://cdn.kernel.org/pub/linux/kernel/v5.x/${wybor}.tar.sign"
}

function kernele() {
	zmienne;	
	curl --compressed -o kernele.asc $ADRES_KERNELA_PLIKI
	clear
	echo -e "\e[32m${tablica_logo["0"]}\e[0m"
	#grep -o 'linux-[0-9]\+.[0-9]\+.[0-9]\+.tar.xz' kernele.asc > kernele.txt
	grep -o "linux-[0-9].[0-9].[0-9].tar.xz" kernele.asc > kernele-sort.txt	
	sort -n -t "." kernele.txt > kernele-sort.txt
	readarray -t menu < kernele-sort.txt
	for i in "${!menu[@]}"; do
		menu_list[$i]="${menu[$i]%% *}"
	done
	echo "Choose a kernel :"
		select wybor in "${menu_list[@]}" "Wyjście"; do
		case "$wybor" in
			"Wyjście")
			exit 1
			;;
			*)
			echo "Wybrałeś $wybor"		
			zmienne;
                        if [ ! -f "$wybor" ] && [ ! -f "$KERNEL_SIGN" ]; then {
		         	if curl --output /dev/null --silent --head --fail "$ADRES_KERNELA"; then {
			                echo -e "\e[32m Kernel istnieje : $ADRES_KERNELA , pobieram :\e[0m"
			                sleep 3			
			                curl --compressed --progress-bar -o "$wybor.tar.xz" "$ADRES_KERNELA"
			                curl --compressed --progress-bar -o "$wybor.tar.sign" "$ADRES_PODPISU"
                            		clear
                            		echo "Pobierma klucze GPG"
	                        	gpg --locate-keys torvalds@kernel.org gregkh@kernel.org
	                        	unxz -c $wybor.tar.xz | gpg --verify $wybor.tar.sign -
	                            		if [ $? -eq 0 ]; then {
                                    		echo -e "\e[32m=====================\e[0m"
                                    		echo -e "\e[32m=  Podpis poprawny  =\e[0m"
                                    		echo -e "\e[32m=====================\e[0m"	
                                   	 	sleep 2
						echo -e "\e[33mKERNEL POBRANY: $wybor.tar.xz\e[0m"	
                                		} else {
    		                        	echo "Problem z podpisem : $wybor.tar.xz"
                                		} fi
                            	}
		                else {
  			             echo "Kernel nie istnieje : $ADRES_KERNELA"
			             sleep 2
                            	} fi
                        }
	                else {
	                     echo -e "\e[32m===========================\e[0m"
	                     echo -e "\e[32m= Kernel jest już pobrany =\e[0m"
	                     echo -e "\e[32m===========================\e[0m"
			     echo -e "\e[33mKERNEL POBRANY: $wybor.tar.xz\e[0m"	
			     sleep 2
                        } fi
			;;
		esac
		break
		done
	read -p "Press ENTER"
	clear
}

kernele;
