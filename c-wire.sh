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


	function help_manual() {
		slow_print "User manual : " 
		slow_print "   #1 : CSV File"
		slow_print "   #2 : Station type ( hva, hvb, lv )" 
		slow_print "   #3 : Consumer type ( comp, indiv, all )   Note : hva and hvb only works with comp !"
		slow_print "   #4 : Power plant id > 0"
		slow_print "Option : -h : Display help manual"
		slow_print "   -h : Display help manual"
		sleep 1
	}
	
	
##################################################################################################	
##### O T H E R S ################################################################################
##################################################################################################




##################################################################################################	
##### V E R I F I C A T I O N ####################################################################
##################################################################################################


#----Help if -h option is used
	for arg in "$@";do
		if [ "$arg" == "-h" ];then
			help_manual
			sleep 1
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

	power_plant_id=$4 
	if [ ! -z "$power_plant_id" ]; then
		if [ "$power_plant_id" -le 0 ] || [[ ! "$power_plant_id" =~ ^[0-9]+$ ]]; then
			slow_print "/!\ Error : Power plant id must be a positive number"
			echo
			help_manual
			exit 1
		fi
	fi

nohup xdg-open codeShell/nuclear.mp3  > /dev/null 2>&1 &
disown
bash codeShell/login.sh
bash codeShell/fakeloading.sh
bash codeShell/loading.sh&
loading_pid=$!
#----Check if the executable exists

	if [ ! -x exe ]; then
	    make clean -s -C codeC
	    make -s -C codeC
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

# IF ERROR TIME ELAPSED = 0s
# Initialize duration
start_timer=$(date +%s)

input_csv=$file_csv
output_csv="tmp/temp.csv"


# HVB COMP
 if [ "$station_type" == "hvb" ]; then
	tail -n +2 $input_csv | awk -F ";" '$2 != "-" && $3 == "-" {print $0}' > "$output_csv"
fi

# HVA COMP
if [ "$station_type" == "hva" ]; then
	tail -n +2 $input_csv | awk -F ";" '$3 != "-" && $4 == "-" {print $0}' > "$output_csv"
fi

# LV COMP
if [ "$station_type" == "lv" ]; then
	if [ "$consumer_type" == "comp" ]; then
	tail -n +2 $input_csv | awk -F ";" '$4 != "-" && $6 == "-" {print $0}' > "$output_csv"
	fi
	# LV INDIV
	if [ "$consumer_type" == "indiv" ]; then
	tail -n +2 $input_csv | awk -F ";" '$4 != "-" && $5 == "-" {print $0}' > "$output_csv"
	fi
	# LV ALL
	if [ "$consumer_type" == "all" ]; then
	tail -n +2 $input_csv | awk -F ";" '$4 != "-" {print $0}' > "$output_csv"
	fi
fi

if [ ! -z "$power_plant_id" ]; then
    awk -F ";" -v id="$power_plant_id" '$1 == id {print $0}' "$output_csv" > "${output_csv}.tmp" # -v = variable
    mv "${output_csv}.tmp" "$output_csv"
else
	power_plant_id=0
fi

output_file_name=""
if [ $power_plant_id -eq 0 ];then
	output_file_name="tmp/${station_type}_${consumer_type}.csv"
else
	output_file_name="tmp/${station_type}_${consumer_type}_${power_plant_id}.csv"
fi

touch "$output_file_name"


# C PROGRAMM

chmod 777 tmp

make -s -C codeC 

./exe $station_type $consumer_type $power_plant_id $output_file_name 

if [ $station_type == "lv" ] && [ $consumer_type == "all" ]; then
	tail -n +2 "$output_file_name" | sort -t":" -k3 -n  > "tmp/lv_allminmax.csv.tmp"
	
	if [ $(wc -l < "$output_file_name") -gt 21 ]; then
		{
		head -n 10 "tmp/lv_allminmax.csv.tmp"
		tail -n 10 "tmp/lv_allminmax.csv.tmp" 
		} > "tmp/minmax.csv.tmp"
	else
		mv "tmp/lv_allminmax.csv.tmp" "tmp/minmax.csv.tmp"
	fi
	{
	head -n 2 "tmp/lv_allminmax.csv"
	awk -F":" '{diff = $2 - $3; print $1 ":" $2 ":" $3 ":" diff}' "tmp/minmax.csv.tmp" | sort -t":" -k4 -n | cut -d":" -f1-3
	} > "tmp/lv_allminmax.csv.tmp"

	mv "tmp/lv_allminmax.csv.tmp" "tmp/lv_allminmax.csv"
	rm -rf tmp/*.tmp
fi

kill $loading_pid
clear
sleep 0.1




# Sort for LV ALL MIN MAX


end_time=$(date +%s)
duration=$(($end_time - $start_timer))

# Remove .o files in codeC/

find codeC -type f -name "*.o" -exec rm -f {} \;

#print Treatment time




notify-send "Treatment finished!" "File $output_file_name generated sucessfully."

if [ $station_type == "lv" ] && [ $consumer_type == "all" ]; then
	notify-send "Treatment finished!" "File tmp/lv_allminmax.csv generated sucessfully"
fi
p=" 
                                                                      
  ██████╗██╗   ██╗     ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗███████╗██████╗ 
 ██╔════╝╚██╗ ██╔╝     ██╔══██╗██║   ██║████╗  ██║██║ ██╔╝██╔════╝██╔══██╗
 ██║      ╚████╔╝█████╗██████╔╝██║   ██║██╔██╗ ██║█████╔╝ █████╗  ██████╔╝
 ██║       ╚██╔╝ ╚════╝██╔══██╗██║   ██║██║╚██╗██║██╔═██╗ ██╔══╝  ██╔══██╗
 ╚██████╗   ██║        ██████╔╝╚██████╔╝██║ ╚████║██║  ██╗███████╗██║  ██║
  ╚═════╝   ╚═╝        ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                 
"
p1=" 
    ╔═════════════════════════════╗  ╔═════════════════════════════════╗                                            
    ║ ⚒︎ USEFULL FILES :           ║  ║ ⚒︎ RADIATIONS AS TIME GOES BY :  ║       
    ║                             ║  ║                                 ║
    ║  ⛘ CY-Bunker/               ║  ║   ☢                             ║
    ║  ├──⛘ codeC/                ║  ║   ┃                  ╭──        ║
    ║  │  ├── include/            ║  ║   ┃                  │          ║
    ║  │  └── main.c              ║  ║   ┃             ╭────╯          ║
    ║  ├──⛘ codeShell/            ║  ║   ┃             │               ║
    ║  │  └── c-wire.sh           ║  ║   ┃         ╭───╯               ║
    ║  ├──⛘ documents             ║  ║   ┃     ╭───╯                   ║
    ║  │  └── subject.pdf         ║  ║   ┃  ╭──╯                       ║
    ║  ├── c-wire_V25.dat         ║  ║   ┃──╯                          ║
    ║  └──⛘ tmp/                  ║  ║   ┗━━━━━━━━━━━━━━━━━━━━━━━━━☢   ║
    ║     └── temp_file.tmp       ║  ║                                 ║
    ╚═════════════════════════════╝  ╚═════════════════════════════════╝   
    ╔═════════════════════════════╗  ╔═════════════════════════════════╗
    ║  ⚒︎ HEXA-DATA :              ║  ║ ⚒︎ TREATMENT TIME:               ║
    ║                             ║  ║                                 ║                   
"
printf "$p" 
LC_TIME=ru_RU.UTF-8 date
printf "$p1"
if [ $duration -ge 60 ]; then
    minutes=$(($duration / 60))
    seconds=$(($duration % 60))
    if [ $seconds -eq 0 ]; then
	printf "    ║  0xA1B2C3D4E5F60789         ║  ║  $minutes minutes\n"
    else
        printf "    ║  0xA1B2C3D4E5F60789         ║  ║  $minutes minutes and $seconds seconds\n"
    fi
else
    printf "    ║  0xA1B2C3D4E5F60789         ║  ║    $duration seconds\n"
fi
printf "    ║  0x8C3F7D1A9B2E6F48C0       ║  ║                                 ║
    ║  0xD23E7B5A9C1A3E8F2A       ║  ║                                 ║
    ║  0xA1B2C3D4E5F60789         ║  ║                                 ║
    ║                             ║  ║                                 ║
    ╚═════════════════════════════╝  ╚═════════════════════════════════╝\n"
    
printf "    ╔══════════════════════════════════════════════════════════════════╗\n"
printf "    ║                                                                  ║\n"
printf "    ║  ⚒︎ File $output_file_name generated sucessfully.     \n"
if [ $station_type == "lv" ] && [ $consumer_type == "all" ]; then
        printf "    ║  ⚒︎ File tmp/lv_allminmax.csv generated sucessfully.              ║\n"
fi
printf "    ║                                                                  ║    \n"
printf "    ╚══════════════════════════════════════════════════════════════════╝\n"
printf '\033[0m'
