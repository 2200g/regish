#!/bin/sh

[ ! -d $HOME/.config ] && mkdir $HOME/.config
[ ! -d $HOME/.config/regish ] && mkdir $HOME/.config/regish
[ ! -s $HOME/.config/regish/register.csv ] && touch $HOME/.config/regish/register.csv && echo "epoch,subadd,amount" >>$HOME/.config/regish/register.csv

ballad="$HOME/.config/regish/register.csv"
poem="$HOME/.config/regish/tmp"
epoch=$(date +%s)

help() {
	echo "REGISH"
	echo "Accounting -- done right in your shell."
	echo ""
	echo "Usage: "
	echo "   regish -[h/b/t]"
	echo ""
	echo "Options: "
	echo "   -h | --help"
	echo "     View this help text."
	echo "   -r | --registry"
	echo "     View the account's transactions."
	echo "   -t | --transact  {+/- AMOUNT}"
	echo "     Make a transaction."
	echo "   -b | --balance"
	echo "     View account balance."
	echo ""
}

registry() {
	echo "REGISH -- Registry"
	cat $ballad | tail -n +2 | while IFS="," read -r column1 column2 column3; do
		echo "$(date -d @$column1 "+%a %d %b -- %I:%M %P")"
		echo "  $column2$column3"
	done
}

transact() {
	echo "REGISH -- Transactions"
	read -r -p "+ OR - ? " addsub
	read -r -p "Amount: " amount

	echo "$epoch,$addsub,$amount" >>$ballad
}

balance() {
	sum=0
	cat $ballad | tail -n +2 | while IFS="," read -r column1 column2 column3; do
		sum=$(
			echo "scale=4;$sum$column2$column3" | bc
		)
		echo "$sum" >>$poem
	done
	echo "REGISH -- Balance"
	echo "Total: $(cat $poem | tail -n1)"
}

while [[ $1 ]]; do
	case $1 in
	"-h")
		help
		exit
		;;
	"--help")
		help
		exit
		;;
	"-b")
		balance
		exit
		;;
	"--balance")
		balance
		exit
		;;
	"-r")
		registry
		exit
		;;
	"--registry")
		registry
		exit
		;;
	"-t")
		while [[ $2 ]]; do
			case $2 in
			"+")
				while [[ $3 ]]; do
					if [[ $3 =~ ^[0-9]*\.[0-9]+$ || $3 =~ ^[0-9]+$ ]]; then
						echo "$epoch,+,$3" >>$ballad
					fi
					exit
				done
				read -r -p "Amount: " amountadd
				echo "$epoch,+,$amountadd" >>$ballad
				exit
				;;
			"-")
				while [[ $3 ]]; do
					if [[ $3 =~ ^[0-9]*\.[0-9]+$ || $3 =~ ^[0-9]+$ ]]; then
						echo "$epoch,-,$3" >>$ballad
					fi
					exit
				done
				read -r -p "Amount: " amountsub
				echo "$epoch,-,$amountsub" >>$ballad
				exit
				;;
			esac
			echo "Use {+/- AMOUNT}."
			exit 3
		done
		transact
		exit
		;;
	esac
	echo "Use the --help flag for help."
	exit 1
done
