#!/bin/bash
# 
# By Curar 2020r.
#
# Skrypt który automatycznie pobiera jądra ze strony 
# https://kernel.org przy użyciem programu curl, gpg, mapfile
# https://github.com/gpg/gnupg
# https://gnupg.org/
#
# Write using vim editor
# https://github.com/vim/vim
# https://www.vim.org/
# Wersja 1.0

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
echo -e "\e[33mHELLOW !\e[0m"
echo ""
read -p "Press ENTER"
clear

# Definicja zmiennych
function zmienne() {
export ADRES_KERNELA_PLIKI="https://cdn.kernel.org/pub/linux/kernel/${galaz}/sha256sums.asc"
export ADRES_KERNELA="https://cdn.kernel.org/pub/linux/kernel/${galaz}/${wybor}"
}

function exist() {
echo -e "\e[33mI will check if you have the appropriate programs in the system\e[0m"
sleep 2
for program in curl gpg mapfile; do
      	printf '%-10s' "$program"
  if hash "$program" 2>/dev/null; then
    echo -e "\e[32m- It is installed\e[0m"
    sleep 0.1 
 else
    echo -e "\e[31m- It is not installed\e[0m"
    sleep 0.1
    echo "======================================================"
    echo -e "\e[31m STOP !!! - Must have installed packet\e[0m"
    echo "======================================================"
    exit 1
  fi
done
}

function kernele() {
	zmienne;
	curl --compressed -o kernele.asc $ADRES_KERNELA_PLIKI
	clear
	echo -e "\e[32m${tablica_logo["0"]}\e[0m"
	grep -o "linux-[[:digit:]]\+.[[:digit:]]\+.[[:digit:]]\+.tar.xz" kernele.asc > kernele.txt	
	grep -o "linux-[[:digit:]]\+.[[:digit:]]\+.tar.xz" kernele.asc >> kernele.txt	
	sort -V kernele.txt > kernele-sort.txt
	mapfile -t menu < kernele-sort.txt
	echo $ADRES_KERNELA
	for i in "${!menu[@]}"; do
		menu_list[$i]="${menu[$i]}"
	done
	echo -e "\e[32mChoose a kernel :\e[0m"
		select wybor in "${menu_list[@]}" "EXIT"; do
		case "$wybor" in
			"EXIT")
			clear
			;;
			*)
			echo "You chose : $wybor"		
			sign=`echo $wybor | cut -f1 -d "t" | awk '{ printf("%star.sign", $1); }'` 
			ADRES_PODPISU="https://cdn.kernel.org/pub/linux/kernel/${galaz}/${sign}"
			zmienne;
			if [ ! -f "$wybor" ] && [ ! -f "$KERNEL_SIGN" ]; then {
		         	if curl --output /dev/null --silent --head --fail "$ADRES_KERNELA"; then {
			                echo -e "\e[32m Kernel exists : $ADRES_KERNELA , download :\e[0m"
			                curl --compressed --progress-bar -o "$wybor" "$ADRES_KERNELA"
					curl --compressed --progress-bar -o "$sign" "$ADRES_PODPISU"
                            		clear
                            		echo -e "\e[33mDownload key GPG\e[0m"
	                        	gpg --locate-keys torvalds@kernel.org gregkh@kernel.org
	                        	unxz -c $wybor | gpg --verify $sign -
	                            		if [ $? -eq 0 ]; then {
                                    		echo -e "\e[32m============================\e[0m"
                                    		echo -e "\e[32m= The signature is correct =\e[0m"
                                    		echo -e "\e[32m============================\e[0m"	
                                   	 	sleep 2
						echo -e "\e[33mKernel download: $wybor\e[0m"	
                                		} else {
    		                        	echo "Signature problem : $wybor"
                                		} fi
                            	}
		                else {
  			             echo "Kernel not exist : $ADRES_KERNELA"
			             sleep 2
                            	} fi
                        }
	                else {
	                     echo -e "\e[32m====================================\e[0m"
	                     echo -e "\e[32m= The kernel is already downloaded =\e[0m"
	                     echo -e "\e[32m====================================\e[0m"
			     echo -e "\e[33mKernel download: $wybor.tar.xz\e[0m"	
			     sleep 2
                        } fi
			;;
		esac
		break
		done
	read -p "Press ENTER"
	clear
}

while :; do
unset menu_list
echo -e "\e[32m${tablica_logo["0"]}\e[0m"
select galaz in "Downloads kernel 3.x" "Downloads kernel 4.x" "Downloads kernel 5.x" "EXIT"; do
	case "$galaz" in
		"Downloads kernel 3.x")
			unset galaz
			unset wybor
			unset menu
			galaz="v3.x"
		;;
		"Downloads kernel 4.x")
			unset galaz
			unset wybor
			unset menu
			galaz="v4.x"
		;;
		"Downloads kernel 5.x")
			unset galaz
			unset wybor
			unset menu
			galaz="v5.x"
		;;
	"EXIT")
		clear
		exit 1
		;;
esac
break
done
exist;
kernele;
done
