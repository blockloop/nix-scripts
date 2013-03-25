#!/bin/bash

#==================== Functions ========================

check_pk() {
	if [ -f $pkfile ]; then
	    return 1;
	else
		echo "No private key file found. Run with -g to create a private key file."
		exit 1
	fi
}

show_usage() {
	echo "Usage: $0 {argument} {parameter}"
	echo "	-g,		Generate a private key file. ( -g {password}"
	echo "	-r,		Read a password. ( -w {application} )"
	echo "	-w,		Write a password. ( -w {application} {password} )"
	echo
}
#=======================================================

echo 

pkfile="$HOME/.kpk";

case $1 in
    -g)
    	if [ $# -lt 2 ]; then
    		echo "Error: Password parameter required."
    		echo
    		show_usage
    		exit 1;
    	fi
    	
    	sudo rm ~/.rnd
    	echo "Creating private key file."
    	openssl genrsa -out $pkfile 1024 -pass env:$2
    	echo
    	echo "Private key file generated. Proceed."
    	;;
    -r)
        check_pk 
        
        
        
        ;;
    -w)
    	check_pk 
    	
    	unenc_pw=".pw_un.tmp"
    	enc_pw=".pw.tmp"
    	
    	stty -echo
    	read -p "$2 Password: " passw; echo
		stty echo
    	
    	# put the password in a tmp file
    	echo $passw > $unenc_pw
        
        #generate the encrypted password file
    	openssl rsautl -encrypt -inkey $pkfile -in $unenc_pw -out $enc_pw
    	
    	#remove the unencrypted password file
    	rm -f $unenc_pw
    	
    	#read the encrypted password
    	encryptedpw=$(cat $enc_pw)
    	
    	cat $encryptedpw
    	
    	;;
    *)
    	show_usage
    	exit 0
    	;;
esac



echo