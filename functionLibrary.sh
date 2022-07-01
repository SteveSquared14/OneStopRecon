#!/bin/bash
#Function for each module of the tool

#whois - takes a domain and returns any name servers
whoIsFunc(){
	domain=$1
	whoIsOutput="$(whois $domain)"
	nameServers="$(echo "$whoIsOutput" | grep -E "Name Server: [a-z]")"

	echo "Name Servers for $domain have been found!"
	echo "Would you also like to conduct optional name-server enumeration? (Y/N)"
	read response
	if [[ "$response" == "Y" ]] || [[ "$response" == "y" ]]; then
		echo "======================= Summary of whois for $domain ======================="
		echo "$whoIsOutput"
		nsLookupFunc $nameServers		

	elif [[ "$response" == "N" ]] || [[ "$response" == "n" ]]; then
		echo "======================= Summary of whois for $domain ======================="
		echo "$whoIsOutput"
	fi
}

#robots.txt & security.txt - needs to be passed a domain
txtFileChecks(){
	urlPrepend="https://"
	domainToOpen=$1
	
	#robots.txt
	urlAppend="/robots.txt"
	completeUrl=$domainToOpen$urlAppend
	#xdg-open $completeURL
	echo "====================== Summary of robots.txt for "$domainToOpen" ===================="
	wget -q $completeUrl
	cat robots.txt
	echo " "
	echo " "
	rm robots.*
	#security.txt
	urlAppend2="/security.txt"
	completeUrl2=$domainToOpen$urlAppend2
	#xdg-open $completeUrl2
	echo "==================== Summary of security.txt for "$domainToOpen" ===================="
	wget -q $completeUrl2
	cat security.txt
	rm security.*
}

#exploitDB



#DNS enumeration
#Commands to use - dig, host, nslookup
dnsCheck(){
	#run dig command with a parameter of a chosen domain
	#dig $1 > tempDigFile.txt
	echo "======================= Summary of Dig for "$1" ======================="
	dig $1
	ipAddr="$(dig $1 | grep -Eo "[0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}[.][0-9]{1,3}$")"
	
	#grep output of dig, looking for an ip addrr. Pass that to host command
	echo " "
       	echo "==================== Summary of Host for "$ipAddr" ===================="
	host $ipAddr
	
	#name server enumeration - duplicate code atm, need to refine
	nameServers="$(whois $1 | grep -E "Name Server: [a-z]")"
	dnsNameServersArray=($nameServers)
	echo " "
	echo " "
	echo "=================== Summary for nsLookup of Name Servers ==================="
	for ns in "${!dnsNameServersArray[@]}"; do
		if [[ $(($ns % 3 )) == "2" ]];then
			echo "======================== Summary for "${dnsNameServersArray[ns]}" ========================"
			nslookup "${dnsNameServersArray[ns]}"
		fi
	done

}

#seperate function nslookup for dns enumeration
nsLookupFunc(){
	nameServersArray=($@)
		
	for ns in "${!nameServersArray[@]}";do
		if [[ $(($ns % 3 )) == "2" ]]; then
			echo "========== Summary for "${nameServersArray[ns]}" =========="
			
			nslookup "${nameServersArray[ns]}"
		fi
	done
	echo "============================================="
}


#google maps
googleMaps(){
	urlPrepend="https://google.com/maps/place/"
	placeToOpen=""
	for var in "$@"; do
		if [[ $placeToOpen == "" ]];
		then
			placeToOpen=$var
		else
			placeToOpen=$placeToOpen+$var
			shift
		fi
	done
	urlAppend="/"
	completeUrl=$urlPrepend$placeToOpen$urlAppend
	xdg-open $completeUrl
}

#facebook/social media


#metadata extraction - TBC by Mo


#shodan
#url parameter manipulation to open a webpage for whatever the user wants to search for
#open it in a web browser = maybe use xdg-open
shodanFunc(){
	mainUrl="https://www.shodan.io/search?query="
	searchParams=""
	for var in "$@"; do
		if [[ $searchParams == "" ]];
		then
			searchParams=$var
		else
			searchParams=$searchParams+$var
			shift
		fi
	done
	completeUrl=$mainUrl$searchParams
	xdg-open $completeUrl
}



#banner grabbing
bannerGrab(){
	searchParam=$1
	echo "==================== Summary of wget for "$searchParam" ===================="
	echo " "
	wget -q -S "$searchParam"
	echo " "
	echo "==================== Summary of curl for "$searchParam" ===================="
	echo " "
	curl -s -I "$searchParam"
}



#Testing below here
#whoIsFunc $1
#googleMaps $@
txtFileChecks $1
#dnsCheck $1
#shodanFunc $@
#bannerGrab $1
