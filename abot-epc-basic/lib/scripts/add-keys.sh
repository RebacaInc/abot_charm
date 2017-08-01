#!/bin/bash

##########################################################################
 # 
 # @!$ Rebaca Technologies
 # __________________
 # 
 # 2016 Rebaca Technologies
 # 
 # NOTICE:  All information contained herein is, and remains
 # the property of Rebaca Technologies and its suppliers, if any.
 # The intellectual and technical concepts contained herein are 
 # proprietary to Rebaca Technologies and its suppliers and may be  
 # covered by Indian and Foreign Patents, patents in process, and 
 # are protected by trade secret or copyright law. Dissemination
 # of this information or reproduction of this material is strictly
 # forbidden unless prior written permission is obtained from 
 # Rebaca Technologies.
 # 
 # @!$Id$
 #

#Get all units of abot
ABOT_UNITS=`juju status --format=short abot-epc-basic | grep abot-epc-basic | awk -F'[: ]' '{print $2}'`
EPC_UNITS=`juju status --format=short oai-epc | grep oai-epc | awk -F'[: ]' '{print $2}'`

if [ ! -z "$ABOT_UNITS" ]; then
   for abot_unit in $ABOT_UNITS
   do
     echo "Circulating public key of Abot unit $abot_unit"

     juju ssh $abot_unit "if [ ! -f ~/.ssh/id_rsa.pub ]; then ssh-keygen -t rsa -N \"\" -f ~/.ssh/id_rsa; fi"
     key=`juju ssh $abot_unit "cat ~/.ssh/id_rsa.pub"`
     key=`echo "$key" | sed 's/\r//'`
     echo "Key($abot_unit): $key"

     #Distribute to current Abot unit
     juju ssh $abot_unit "echo $key >> ~/.ssh/authorized_keys"

     Distribute to all EPC units
     for epc_unit in $EPC_UNITS
     do
       echo "Publishing key to $epc_unit"
       juju ssh $epc_unit "echo $key >> ~/.ssh/authorized_keys"
     done

   done #For all abot units
fi
