#!/bin/bash

while [ $# -gt 0 ]
do
i=$1
    case $i in
        -c)
        conf=$2
        shift
        ;;
        -o)
        out=$2
        shift
        ;;
        -u)
        numUE=$2
        shift
        ;;
        *)
        exit 1
        ;;
    esac
    shift
done

msin=0000000001
msin_prefix_part=0000000
msin_add_part=$(echo -n $msin | tail -c 3)

imei=356113022094149
imei_prefix_part=356113022094
imei_add_part=$(echo -n $imei | tail -c 3)

msisdn=33611123456
msisdn_prefix_part=33611123
msisdn_add_part=$(echo -n $msisdn | tail -c 3)

sed -e '/UE0/,$d' $conf > ${conf}.final

for (( count=0 ; count<$numUE; count++ ))
do
    cp $conf ${conf}.bak

    sed -i "s/UE0/UE${count}/g" $conf

    new_msin=$(($msin_add_part + $count))
    (( $count < 9 )) && new_msin="${msin_prefix_part}00${new_msin}"
    (( $count < 99 && $count >= 9 )) && new_msin="${msin_prefix_part}0${new_msin}"
    (( $count >= 99 )) && new_msin="${msin_prefix_part}${new_msin}"
    sed -i "s/$msin/$new_msin/g" $conf
    
    new_imei=$(($imei_add_part + $count)) 
    new_imei="${imei_prefix_part}${new_imei}"
    sed -i "s/$imei/$new_imei/g" $conf

    new_msisdn=$(($msisdn_add_part + $count)) 
    new_msisdn="${msisdn_prefix_part}${new_msisdn}"
    sed -i "s/$msisdn/$new_msisdn/g" $conf

    sed -n -e "/UE${count}/,\$p" $conf >> ${conf}.final 
    mv ${conf}.bak $conf
done

(cd /srv/openair5G/targets/bin; rm -rf .ue_emm.nvram*)
(cd /srv/openair5G/targets/bin; rm -rf .ue.nvram*)
(cd /srv/openair5G/targets/bin; rm -rf .usim.nvram*)

(cd /srv/openair5G/targets/bin; ./conf2uedata -c ${conf}.final -o $out > /dev/null)
