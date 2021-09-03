#!/bin/bash
#l2i (Wegare)
route2="$(route | grep default | grep ppp | head -n1 | awk '{print $8}')" 
route3="$(lsof -i | grep xl2tpd)" 
	if [[ -z $route2 ]]; then
		   printf '\n' | l2i
           exit
    elif [[ -z $route3 ]]; then
           printf '\n' | l2i
           exit
	fi
