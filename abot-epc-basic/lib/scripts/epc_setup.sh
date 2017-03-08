#!/bin/bash
search_and_replace()
{
    LHS=$1
    RHS=$2

    #echo "$LHS=$RHS"

    str=$(grep -w "$LHS\s*=" $ENBCONFIGFILE)

    #echo "str=:"$str

    IFS='=' read -ra WORDSARR <<< $str

    #echo "${WORDSARR[0]}=${WORDSARR[1]}"

    OLD_RHS=`echo ${WORDSARR[1]} | tr -d '"' | tr -d ';'`

    #echo "OLD_RHS :"$OLD_RHS"----RHS :"$RHS"----LHS  :"$LHS

    sed -i -e "s?\(\s*{*\)\(${LHS}\)\(\s*= *\)\(\"*\)\(${OLD_RHS}\)\(\"*\)\(;\)?\1\2\3\4${RHS}\6\7?g" $ENBCONFIGFILE
}


LINE=$1
ENBCONFIGFILE=$2

if [ "$ENBCONFIGFILE" = "" ]
then
    ENBCONFIGFILE="/srv/openair5G/targets/PROJECTS/GENERIC-LTE-EPC/CONF/enb.band7.generic.conf"
fi

#echo $LINE

if [[ $LINE == *"ABOT.ENB"* ]]
then
    IFS='=' read -ra WORDS <<< $LINE
    IFS='.' read -ra LeftString <<< ${WORDS[0]}
    LHS=${LeftString[-1]}
    RHS=${WORDS[1]}
    
    #Special handling for mme_ip_address in ipv4
    echo $LHS|grep "mme_ip_address_ipv4" >> /dev/null

    if [ $? -eq 0 ]; then LHS=ipv4 ; fi

    search_and_replace $LHS $RHS
fi
