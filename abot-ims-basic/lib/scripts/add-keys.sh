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
ABOT_UNITS=`juju status --format=short abot-ims-basic | grep abot-ims-basic | awk -F'[: ]' '{print $2}'`
BONO_UNITS=`juju status --format=short clearwater-bono | grep clearwater-bono | awk -F'[: ]' '{print $2}'`
SIPP_UNITS=`juju status --format=short clearwater-sipp | grep clearwater-sipp | awk -F'[: ]' '{print $2}'`
HSS_UNITS=`juju status --format=short clearwater-homestead | grep clearwater-homestead | awk -F'[: ]' '{print $2}'`

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

     #Distribute to all BONO units
     for bono_unit in $BONO_UNITS
     do
       echo "Publishing key to $bono_unit"
       juju ssh $bono_unit "echo $key >> ~/.ssh/authorized_keys"
     done

     #Distribute to all SIPP units
     for sipp_unit in $SIPP_UNITS
     do
       echo "Publishing key to $sipp_unit"
       juju ssh $sipp_unit "echo $key >> ~/.ssh/authorized_keys"
     done

     #Distribute to all HSS units
     for hss_unit in $HSS_UNITS
     do
       echo "Publishing key to $hss_unit"
       juju ssh $hss_unit "echo $key >> ~/.ssh/authorized_keys"
     done
   
   done #For all abot units
fi
