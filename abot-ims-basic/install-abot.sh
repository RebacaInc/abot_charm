#!/bin/bash

ABOT_DEPLOY_DIR=/etc/rebaca-test-suite

red='\E[31m'
green='\E[32m'
blue='\E[1;34m'
reset_color='\E[00m'

# Green echo
function echo_green {
    message=$1
    echo -e "${green}${message}${reset_color}"
}

# Red echo
function echo_red {
    message=$1
    echo -e "${red}${message}${reset_color}"
}

# Blue echo
function echo_blue {
    message=$1
    echo -e "${blue}${message}${reset_color}"
}

function exit_on_error {
    LAST_RESULT=$?
    MESSAGE=$1
    if [ ${LAST_RESULT} -eq 0 ]
    then
        if [ "$2" != "ECHO=ON_FAILURE_ONLY" ]; then
            echo_green "<< ABOT Installer - Success: ${MESSAGE} >>"
        fi
    else
        if [ "$2" != "ECHO=ON_WARNING_ONLY" ]; then
            echo_red "<< ABOT Installer - Error: ${MESSAGE} >>"
            exit 1
        else
            echo_blue "<< ABOT Installer - Warning: ${MESSAGE} >>"
        fi
    fi
}


function usage {
    echo_blue "./install-abot <options>"
    echo_blue "Run with sudo privileges"
    echo_blue "Example: sudo ./install-abot.sh -a abot-ims-basic -v 3.1.0 -nc"
    echo ""
    echo "options"
    echo ""
    echo "-a  | --app) application name: abot-ims-basic | abot-epc-basic | abot-functest-basic | abot-volte-basic"
    echo "-v  | --version) version: 3.1.0"
    echo "-et | --external-tester) external tester: ixia | dsTest"
    echo "-nc | --null-configuration) No configuration done during deployment of system"
    echo ""
    exit 0
}

function check_input {
    case $APP_NAME in
        abot-ims-basic|abot-epc-basic|abot-functest-basic|abot-volte-basic) true;;
        *) usage;;
    esac
    exit_on_error "Application Name $APP_NAME"

    case $APP_VERSION in
        3.[0-9].[0-9]) true;;
        *) usage;;
    esac
    exit_on_error "Version $APP_VERSION"

    case $APP_EXTERNAL_TESTER in
        none) true;;
        ixia) true;;
        *) usage;;
    esac
    exit_on_error "External Tester $APP_EXTERNAL_TESTER"
}

function install_oai_packages {
    source ${ABOT_DEPLOY_DIR}/oaisim/bin/build_helper_rebaca
    set_openair_deploy_env
    check_install_oai_software

    # ue_ip driver compilation
    {
        cd ${ABOT_DEPLOY_DIR}/oaisim/openair2/NETWORK_DRIVER/UE_IP;
        cp Makefile.rebaca Makefile;
        make clean &> /dev/null;
        make;
        cp -f ue_ip.ko ${ABOT_DEPLOY_DIR}/oaisim/bin;
    } &> ${ABOT_DEPLOY_DIR}/oaisim/cmake_targets/log/ue_ip.txt

    exit_on_error "Installing oaisim"

    # Not installing additional tools
    # for the time being

    # check_install_additional_tools
}

function install_ixia_packages {
    pip install pyyaml
    pip install paramiko
    pip install dnspython
    pip install scp
    pip install jinja2
    pip install httplib2

    exit_on_error "Installing Ixia python packages"
}

function set_ixia_ims_information {
    PRIVATE_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
    sed -i "s/ABOT.SecureShell.IPAddress=[^ ]*/ABOT.SecureShell.IPAddress=${PRIVATE_IP}/" ${ABOT_DEPLOY_DIR}/config/ABotConfig.properties

    read -p "IMS DNS IP Address (e.g. IMS DNS Server): " DNS_IP; DNS_IP=${DNS_IP:="192.168.255.255"}
    echo $DNS_IP > ${ABOT_DEPLOY_DIR}/dns_ip
    read -p "IMS Clearwater Ellis IP Address (e.g. Clearwater Ellis IP): " ELLIS_IP; ELLIS_IP=${ELLIS_IP:=192.168.255.255}
    echo $ELLIS_IP > ${ABOT_DEPLOY_DIR}/ellis_ip
    read -p "IMS IxLoad IP Address: " IXLOAD_IP; IXLOAD_IP=${IXLOAD_IP:=192.168.255.255}
    echo $IXLOAD_IP > ${ABOT_DEPLOY_DIR}/ixload_ip
    read -p "IMS IxChassis IP Address: " IXCHASSIS_IP; IXCHASSIS_IP=${IXCHASSIS_IP:=192.168.255.255}
    echo $IXCHASSIS_IP > ${ABOT_DEPLOY_DIR}/ixchassis_ip
    read -p "IMS IxCard1 IP Address: " IXCARD1_IP; IXCARD1_IP=${IXCARD1_IP:=192.168.255.255}
    echo $IXCARD1_IP > ${ABOT_DEPLOY_DIR}/ixcard1_ip
    read -p "IMS IxCard2 IP Address: " IXCARD2_IP; IXCARD2_IP=${IXCARD2_IP:=192.168.255.255}
    echo $IXCARD2_IP > ${ABOT_DEPLOY_DIR}/ixcard2_ip

    exit_on_error "Setting Ixia Information"
}

function set_sut_ims_information {
    PRIVATE_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`
    sed -i "s/ABOT.SecureShell.IPAddress=[^ ]*/ABOT.SecureShell.IPAddress=${PRIVATE_IP}/" ${ABOT_DEPLOY_DIR}/config/ABotConfig.properties
    sed -i "/ip=/s/[^ ]*/ip=${PRIVATE_IP}/" ${ABOT_DEPLOY_DIR}/bin/sip
    sed -i "/ip=/s/[^ ]*/ip=${PRIVATE_IP}/" ${ABOT_DEPLOY_DIR}/bin/sip_imsi_domain
    sed -i "/ip=/s/[^ ]*/ip=${PRIVATE_IP}/" ${ABOT_DEPLOY_DIR}/bin/sip-stress

    PUBLIC_HOSTNAME=`hostname | cut -d"." -f1`

    read -p "IMS DNS IP Address (e.g. IMS DNS Server): " DNS_IP; DNS_IP=${DNS_IP:="192.168.255.255"}

    read -p "IMS SIP Domain (default: rebaca.local): " ZONE; ZONE=${ZONE:="rebaca.local"}
    echo $ZONE > ${ABOT_DEPLOY_DIR}/sip_domain

    read -p "IMS HSS Mirror IP Address: " IMS_HSS_MIRROR_IP; IMS_HSS_MIRROR_IP=${IMS_HSS_MIRROR_IP:="192.168.255.255"}
    sed -i "s/HSS_MIRROR.SecureShell.IPAddress=[^ ]*/HSS_MIRROR.SecureShell.IPAddress=${IMS_HSS_MIRROR_IP}/" \
        ${ABOT_DEPLOY_DIR}/config/ABotConfig.properties

    read -p "IMS P-CSCF IP Address: " IMS_PCSCF_IP; IMS_PCSCF_IP=${IMS_PCSCF_IP:="192.168.255.255"}
    sed -i "s/P_CSCF.SecureShell.IPAddress=[^ ]*/P_CSCF.SecureShell.IPAddress=${IMS_PCSCF_IP}/" \
        ${ABOT_DEPLOY_DIR}/config/ABotConfig.properties
    echo -n ${IMS_PCSCF_IP} > ${ABOT_DEPLOY_DIR}/sip_server

    exit_on_error "Setting IMS SUT Information"
}

function set_sut_epc_information {
    PRIVATE_IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

    read -p "EPC Mobile Network Code (default: 208): " MCC; MCC=${MCC:="208"}
    sed -i "s/ABOT.ENB.mobile_country_code=[^ ]*/ABOT.ENB.mobile_country_code=${MCC}/" \
        ${ABOT_DEPLOY_DIR}/config/abot-epc-basic_defaults.conf

    read -p "EPC Mobile Network Code (default: 93): " MNC; MNC=${MNC:="93"}
    sed -i "s/ABOT.ENB.mobile_network_code=[^ ]*/ABOT.ENB.mobile_network_code=${MNC}/" \
        ${ABOT_DEPLOY_DIR}/config/abot-epc-basic_defaults.conf

    read -p "MME IP Address: " EPC_MME_IP; EPC_MME_IP=${EPC_MME_IP:="192.168.255.255"}
    sed -i "s/ABOT.ENB.mme_ip_address_ipv4=[^ ]*/ABOT.ENB.mme_ip_address_ipv4=${EPC_MME_IP}/" \
        ${ABOT_DEPLOY_DIR}/config/abot-epc-basic_defaults.conf
    sed -i "s/MME.SecureShell.IPAddress=[^ ]*/MME.SecureShell.IPAddress=${EPC_MME_IP}/" \
        ${ABOT_DEPLOY_DIR}/config/ABotConfig.properties

    read -p "EPC Subscriber OPC (e.g. 79477a68055263cb0c3052057e0d20b8): " EPC_OPC; EPC_OPC=${EPC_OPC:="79477a68055263cb0c3052057e0d20b8"}
    sed -i -e "s/OPC=\".*\";/OPC=\"${EPC_OPC}\";/" \
        ${ABOT_DEPLOY_DIR}/oaisim/config/ue_eurecom_test_sfr.conf

}

function configure_dnsmasq {
    # Update DNS server using DNSMASQ
    echo nameserver ${DNS_IP} > /etc/dnsmasq.resolv.conf
    grep -v ^RESOLV_CONF= /etc/default/dnsmasq > /tmp/dnsmasq.$$
    mv /tmp/dnsmasq.$$ /etc/default/dnsmasq
    echo RESOLV_CONF=/etc/dnsmasq.resolv.conf >> /etc/default/dnsmasq
    service dnsmasq restart
    sleep 5
    # Change Resolvconf order and put dnsmasq on top
    dnsmasq=lo.dnsmasq
    resolvconf=/etc/resolvconf
    loinet=`grep  ^[a-z] /etc/resolvconf/interface-order | head -n1`
    if [ $loinet != $dnsmasq ]
    then
        cp /etc/resolvconf/interface-order /etc/resolvconf/interface-order.orig
        sed  '/'$dnsmasq'/d' /etc/resolvconf/interface-order.orig > /etc/resolvconf/interface-order
        sed -i '/'$loinet'/i lo.dnsmasq' /etc/resolvconf/interface-order
        service dnsmasq restart
        resolvconf -u
    else
        false
        exit_on_error "dnsmasq interface order $loinet $dnsmasq"
    fi
    exit_on_error "Setup dnsmasq"
}

function verify_dns_records {
    if [[ `dig +short ${PRIVATE_IP}` =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
    then
        exit_on_error "Verifying ${PRIVATE_IP} in dns"
    elif [[ "${PRIVATE_IP}" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
    then
        exit_on_error "Verifying ${PRIVATE_IP} in dns"
    else
        cp /etc/resolvconf/interface-order.orig /etc/resolvconf/interface-order
        resolvconf -u
        false
        exit_on_error "Unable to fetch ${PRIVATE_IP} dns order changed to original"
    fi
}

function set_keys {
    # Generate ssh key for root user
    if [ ! -f /root/.ssh/id_rsa.pub ];
    then
        ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
        pub_key=`cat /root/.ssh/id_rsa.pub`
        echo "${pub_key}" | sed 's/\r//' >> /root/.ssh/authorized_keys
    else
        pub_key=`cat /root/.ssh/id_rsa.pub`
        echo "${pub_key}" | sed 's/\r//' >> /root/.ssh/authorized_keys
    fi
}

function configure_volte {
    configure_epc
    configure_ims
}

function configure_epc {
    install_oai_packages

    if [ ! $APP_NULL_CONFIG ]; then
       set_sut_epc_information
       set_keys
    fi
}

function configure_ixia {
    install_ixia_packages

    if [ ! $APP_NULL_CONFIG ]; then
       set_ixia_ims_information
       set_keys
    fi
}

function configure_ims {
    if [ ! $APP_NULL_CONFIG ]; then
       set_sut_ims_information
       configure_dnsmasq
       verify_dns_records
       set_keys
    fi
}


function configure_abot {

    # If there is an external tester,
    # then only configure tester and return

    case $APP_EXTERNAL_TESTER in
        none) true;;
        ixia)
            configure_ixia
            exit_on_error "Configuring $APP_EXTERNAL_TESTER"
            return
            ;;
        *) false;;
    esac

    # If there is no external tester,
    # then configure application

    case $APP_NAME in
        none) false;;
        abot-ims-basic) configure_ims;;
        abot-epc-basic) configure_epc;;
        abot-functest-basic) configure_epc;;
        abot-volte-basic) configure_volte;;
        *) false;;
    esac
    exit_on_error "Configuring $APP_NAME"

}

APP_NAME=none
APP_VERSION=none
APP_EXTERNAL_TESTER=none
APP_NULL_CONFIG=false

sudo -v
exit_on_error "Checking sudo privileges"

while [ $# -gt 0 ]
do

    case $1 in
        -a | --app)
            APP_NAME=$2
            shift
            ;;
        -v | --version)
            APP_VERSION=$2
            shift
            ;;
        -h | --help)
            usage
            ;;
        -et | --external-tester)
            APP_EXTERNAL_TESTER=$2
            shift
            ;;
        -nc | --null-config)
            APP_NULL_CONFIG=true
            ;;
        *)
            usage
            ;;
    esac
    shift
done

check_input

ABOT_DIR=/var/lib/${APP_NAME}
ABOT_URL="http://artifacts.opnfv.org/functest/epc"
ABOT_DEBIAN=${APP_NAME}_${APP_VERSION}_all.deb

# Installing dependencies for abot-volte-basic
#echo_blue "Oracle Java Prerequisites..."
#add-apt-repository -y ppa:webupd8team/java
apt-get update
#echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
#echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
#apt-get -y install oracle-java8-installer
apt-get -y install openjdk-8-jdk

#Set JAVA_HOME variable
echo "Java_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

# Download ABot Debian and Install
mkdir -p ${ABOT_DIR}/payload
wget ${ABOT_URL}/${ABOT_DEBIAN} -O ${ABOT_DIR}/payload/${ABOT_DEBIAN}
exit_on_error "Download Debian $ABOT_DEBIAN"
dpkg --install ${ABOT_DIR}/payload/${ABOT_DEBIAN} || true
apt-get -f -y install
exit_on_error "ABot Debian Installed!!!"

# Configure ABot
configure_abot
