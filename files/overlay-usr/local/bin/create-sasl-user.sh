#!/bin/bash

_USER=$1
_NETWORK=$2
_NICK=$3

: ${_USER:=admin}
: ${_NETWORK:=freenode}
: ${_NICK:=admin}

openssl req -nodes -newkey rsa:2048 -keyout /etc/znc/users/${_USER}/networks/${_NETWORK}/moddata/cert/user.pem -x509 -days 3650 -out /etc/znc/users/${_USER}/networks/${_NETWORK}/moddata/cert/user.pem -subj "/CN=${_NICK}"
echo "/msg NickServ CERT ADD $(openssl x509 -in /etc/znc/users/${_USER}/networks/${_NETWORK}/moddata/cert/user.pem -outform der | sha1sum -b | cut -d' ' -f1)"

