#! /bin/bash

#===============================================================================================
#   System Required:  Ubuntu
#   Description:  Install SS for Ubuntu
#   Author: nero
#  
#===============================================================================================
clear
echo "#############################################################"
echo "# Install SS for Ubuntu"
echo "# Intro: "
echo "#"
echo "# Author:nero"
echo "#"
echo "#############################################################"
echo ""

# Install SS
function install_SS(){
    rootness
    get_my_ip
    install_lib
    pre_doc
    apps
    show_doc
    #optimizatioin
    run_doc
}
# Make sure only root can run our script
function rootness(){
if [[ $EUID -ne 0 ]]; then
   echo "Error:This script must be run as root!" 1>&2
   exit 1
fi
}

# Get IP address of the server
function get_my_ip(){
    echo "Preparing, Please wait a moment..."  
    #IP=`curl -s checkip.dyndns.com | cut -d' ' -f 6  | cut -d'<' -f 1`
    #if [ -z $IP ]; then
    #    IP=`curl -s ifconfig.me/ip`
    #fi
    IP=$(ifconfig eth0|awk '/inet/ {split ($2,x,":");print x[2]}')
}

#install necessary lib
function install_lib(){
    apt-get -y update
    apt-get install vim -y
    apt-get install python-pip -y
    pip install shadowsocks
}

function pre_doc(){
    echo "{
\"server\":\"${IP}\",
\"local_address\": \"127.0.0.1\",
\"local_port\":1080,
\"port_password\":{
    \"7000\":\"wt5-Kpk-bx9-cW2\",
    \"7777\":\"33K-b47-BAN-xx4\",
    \"9000\":\"password0\",
    \"9001\":\"password1\"
},
\"timeout\":600,
\"method\":\"rc4-md5\",
\"workers\":4
}" >>/etc/shadowsocks.json
}

function show_doc(){
    cat /etc/shadowsocks.json
}

function run_doc(){
    echo "reboot"
    echo "ssserver -c /etc/shadowsocks.json -d start"
    echo "Test your VPS: speedtest-cli"
    echo "/sbin/modprobe tcp_hybla"
}
function apps(){
    wget https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py
    chmod a+rx speedtest_cli.py
    sudo mv speedtest_cli.py /usr/local/bin/speedtest-cli
    sudo chown root:root /usr/local/bin/speedtest-cli
}

function optimizatioin(){
echo "
* soft nofile 51200
* hard nofile 51200
" >> /etc/security/limits.conf
echo "
session required pam_limits.so
" >> /etc/pam.d/common-session
echo "
ulimit -SHn 51200
" >> /etc/profile
echo "
net.ipv4.ip_forward = 1
fs.file-max = 51200
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.netdev_max_backlog = 250000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_congestion_control = hybla
" >> /etc/sysctl.conf
sysctl -p
/sbin/modprobe tcp_hybla
}

install_SS



