#!/bin/sh
# Author: Corentin Fresnel - Mekom Solutions
# Contact: support@mekomsolutions.com
#
# Script to disconnect a client from an OpenVPN server

if [ "$1" = "" ]
then {
        echo "Please provide the Common Name to disconnect as an argument to this script. Eg, '$0 romain.vpn.mekomsolutions.net'"
        echo "Aborting…"
        exit 1
}
fi

# Setting up variables
HOST="127.0.0.1" # Host on which to connect via Telnet
PORT="23" # Telnet port
CMD="kill $1" # Command that will be run in Telnet

(
echo open "$HOST $PORT"
sleep 1
echo "$CMD"
sleep 1
echo "exit"
) | telnet