#!/bin/bash
search_and_replace()
{
    LHS=$1
    RHS=$2

    #echo "$LHS=$RHS"

    str=$(grep -w "$LHS\s*=" $USIMCONFIGFILE)

    #echo "str=:"$str

    IFS='=' read -ra WORDSARR <<< $str

    #echo "${WORDSARR[0]}=${WORDSARR[1]}"

    OLD_RHS=`echo ${WORDSARR[1]} | tr -d '"' | tr -d ';'`

    #echo "OLD_RHS :"$OLD_RHS"----RHS :"$RHS"----LHS  :"$LHS

    sed -i -e "s?\(\s*{*\)\(${LHS}\)\(\s*= *\)\(\"*\)\(${OLD_RHS}\)\(\"*\)\(;\)?\1\2\3\4${RHS}\6\7?g" $USIMCONFIGFILE
}


LINE=$1
USIMCONFIGFILE=$2

if [ "$USIMCONFIGFILE" = "" ]
then
    USIMCONFIGFILE="/srv/openair5G/targets/bin/usim_config_rebaca.conf"
fi

#echo $LINE

if [[ $LINE == *"ABOT.UE.USIM"* ]]
then
    IFS='=' read -ra WORDS <<< $LINE
    IFS='.' read -ra LeftString <<< ${WORDS[0]}
    LHS=${LeftString[-1]}
    RHS=${WORDS[1]}
    
    search_and_replace $LHS $RHS
fi
