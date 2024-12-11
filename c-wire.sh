#!/bin/bash
clear
	
##################################################################################################	
##### F O N C T I O N S ##########################################################################
##################################################################################################


	function slow_print(){
		printf '\033[1;32;32m'
		local phrase="$1"
		for ((i=0;i<${#phrase};i++)); do
			echo -n "${phrase:i:1}"
			sleep 0.015
		done
		echo
		printf '\033[0m'
	}

	function fast_print(){
		printf '\033[1;32;32m'
		local phrase="$1"
		for ((i=0;i<${#phrase};i++)); do
			echo -n "${phrase:i:1}"
			sleep 0.001
		done
		echo
		printf '\033[0m'
	}

	function help_manual() {
		slow_print "User manual : " 
		slow_print "   #1 : CSV File"
		slow_print "   #2 : Station type ( hva, hvb, lv )" 
		slow_print "   #3 : Consumer type ( comp, indiv, all )   Note : comp is only works with hva or hvb in #2."
		slow_print "   #4 : Power plant id"
		slow_print "Option : -h : Display help manual"
		slow_print "   -h : Display help manual"
	}
	
	
##################################################################################################	
##### O T H E R S ################################################################################
##################################################################################################


	fast_print "╔═══════════════════════════════════════════════════════════════════════════════════════════════════╗"
	fast_print "║                 Пользовательский файл                          21 января 1949 г.                  ║"
	fast_print "╟───────────────────────────────────────────────────────────────────────────────────────────────────╢"
	fast_print "║                       OFFICER                                       ACCESS                        ║" 
	fast_print "║                       K-12345                                       ******                        ║" 
	fast_print "╚═══════════════════════════════════════════════════════════════════════════════════════════════════╝"
	echo


##################################################################################################	
##### V E R I F I C A T I O N ####################################################################
##################################################################################################


#----Help if -h option is used

	for arg in "$@";do
	    if [ "$arg" == "-h" ];then
		help_manual
		exit 1
	    fi
	done

#----Check if the number of arguments is correct

	if  [ $# -eq 0 ]; then
	    slow_print "/!\ Error : No argument provided."
	    echo
	    help_manual
	    exit 1
	fi

#----Check if file_csv is a file and is readable

	file_csv=$1
	
	if [ ! -f $file_csv ]; then
	    slow_print "/!\ Error : File not found."
	    echo
	    help_manual
	    exit 1
	fi
	
	if [ ! -r $file_csv ]; then
	    slow_print "/!\ Error : File unreadable."
	    echo
	    help_manual
	    exit 1
	fi

#----Station type

	station_type=$2
	
	if [ "$station_type" != "hvb" ] && [ "$station_type" != "hva" ] && [ "$station_type" != "lv" ]; then
	    slow_print "/!\ Error : Station type not valid."
	    echo
	    help_manual
	    exit 1
	fi

#----Consumer type

	consumer_type=$3
	
	if [ "$consumer_type" != "comp" ] && [ "$consumer_type" != "indiv" ] && [ "$consumer_type" != "all" ]; then
	    slow_print "/!\ Error : Consumer type not valid."
	    echo
	    help_manual
	    exit 1
	fi
	
	if [ "$consumer_type" != "comp" ] && [ $station_type != "lv" ]; then
	    slow_print "/!\ Error : Forbidden option, only comp are linked to HV-B and HV-A stations."
	    echo
	    help_manual
	    exit 1
	fi

#----Power plant id (optional)

	power_plant_id=$4 ## check if it's a number plsss

#----Check if the executable exists

	if [ ! -x exec ]; then
	    slow_print "/!\ Error : Executable doesn't exist."
	    echo
	    ## compilation + verification ( ? make ?)
	fi

#----Check if tmp directory exists

	if [ ! -d tmp ]; then
	    mkdir tmp
	else 
	    rm -rf tmp/*
	fi

#----Check if graphs directory exists

	if [ ! -d graphs ]; then
	    mkdir graphs
	fi




# Initialize duration
duration=0

start_timer=$(date +%s.%N)


if useful_command here "${@}"; then
    #start time if condition succesful
    end_time=$(date +%s.%N)
    duration=$(echo "$end_time - $start_timer" | bc)
else
    echo "Error : task failed."
    duration=0
fi

#print Treatment time
printf "Treatment time: %.1fsec\n" "$duration"



# graph : gnuplot
# create file station list
# create avl in C
