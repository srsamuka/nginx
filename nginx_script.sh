#!/bin/bash

# Installing Nginx 1.12.2 Automation Script
#
## @author              Samuel Costa
## @section LICENSE     GPL

##########################
# Start of script 'body' #
##########################

SELF_NAME=$(basename $0)

# Prints warning/error $MESSAGE in red foreground color
#
# For e.g. You can use the convention of using RED color for [E]rror messages

red_echo() {
    echo -e "\x1b[1;31m[E] $MESSAGE\e[0m"
}

simple_red_echo() {
    echo -e "\x1b[1;31m$MESSAGE\e[0m"
}

# Prints success/info $MESSAGE in green foreground color
#
# For e.g. You can use the convention of using GREEN color for [S]uccess messages

green_echo() {
    echo -e "\x1b[1;32m[S] $MESSAGE\e[0m"
}

simple_green_echo() {
    echo -e "\x1b[1;32m$MESSAGE\e[0m"
}

# Prints $MESSAGE in blue foreground color
#
# For e.g. You can use the convetion of using BLUE color for [I]nfo messages
# that require special user attention (especially when script requires input from user to continue)

blue_echo() {
    echo -e "\x1b[1;34m[I] $SELF_NAME: $MESSAGE\e[0m"
}

simple_blue_echo() {
    echo -e "\x1b[1;34m$MESSAGE\e[0m"
}

MESSAGE="Installing pre-req for Nginx 1.12.2" ; simple_green_echo
echo

yum install -y wget openssl openssl-devel zlib gcc etcd perl perl-devel perl-ExtUtils-Embed GeoIP GeoIP-devel libxslt libxslt-devel libxml2 libxml2-devel gd gd-devel


echo "" &&

if [ $? -eq 0 ]; then
    MESSAGE="All packages installed successfully!"; green_echo
else
    MESSAGE="Please verify the error before continue..."; red_echo
fi

sleep 1
echo "" &&

MESSAGE="Creating user to Nginx" ; simple_green_echo
echo
sleep 1

useradd -s /sbin/nologin nginx
echo "" &&

MESSAGE="Updating system" ; simple_green_echo
echo
sleep 1

yum check-update || yum update -y

if [ $? -eq 0 ]; then
    MESSAGE="All packages updated successfully!"; green_echo
else
    MESSAGE="Please verify the error before continue..."; red_echo
fi
sleep 1
echo "" &&


MESSAGE="Install Development Tools if you did not do before" ; simple_green_echo
echo
sleep 1

yum groupinstall -y 'Development Tools'

if [ $? -eq 0 ]; then
    MESSAGE="All packages installed successfully!"; green_echo
else
    MESSAGE="Please verify the error before continue..."; red_echo
fi
sleep 1
echo "" &&


MESSAGE="Install Extra Packages" ; simple_green_echo
echo
sleep 1

yum install  epel-release   -y

if [ $? -eq 0 ]; then
    MESSAGE="All packages installed successfully!"; green_echo
else
    MESSAGE="Please verify the error before continue..."; red_echo
fi
sleep 1
echo "" &&

MESSAGE="Download and install OpenSSL HTTPs Module from source code" ; simple_green_echo
echo
sleep 1

cd /tmp

wget http://www.openssl.org/source/openssl-1.0.2k.tar.gz  && tar xzvf openssl-1.0.2k.tar.gz

cd openssl-1.0.2k

./Configure linux-x86_64 --prefix=/usr

make & make install

if [ $? -eq 0 ]; then
    MESSAGE="All packages installed successfully!"; green_echo
else
    MESSAGE="Please verify the error before continue..."; red_echo
fi
sleep 1
echo "" &&


MESSAGE="Download and install PCRE dependency from source code" ; simple_green_echo
echo
sleep 1

wget https://ftp.exim.org/pub/pcre/pcre-8.41.tar.gz  &&  tar xzvf pcre-8.41.tar.gz

cd pcre-8.41

./configure

make && make install

echo "" &&

if [ $? -eq 0 ]; then
    MESSAGE="PCRE installed successfully!"; green_echo
else
    MESSAGE="Please verify the error before continue..."; red_echo
fi
sleep 1
echo "" &&

cd /tmp

rm *.tar.gz

MESSAGE="Download, install and start Nginx from source code" ; simple_green_echo
echo
sleep 1

wget http://nginx.org/download/nginx-1.12.2.tar.gz   && tar xzvf nginx-1.12.2.tar.gz

cd nginx-1.12.2/

./configure

make && make install

rm *.tar.gz


cp  /usr/local/nginx/sbin/nginx    /usr/sbin/

nginx -v

ln -s /usr/local/nginx/   /etc/nginx

/usr/sbin/nginx

curl -I http://127.0.0.1

if [ $? -eq 0 ];

then
    MESSAGE="Nginx installed successfully!"; green_echo
else
    MESSAGE="Please verify the error before continue..."; red_echo
fi
sleep 1
echo "" &&

MESSAGE="Installing SSL/TLS and enforing HTTPS redirection" ; blue_echo
echo
sleep 1

mkdir /etc/ssl/private

openssl req -new -newkey rsa:2048 -nodes -keyout /etc/ssl/private/ewpschellmanco.key -out /etc/ssl/certs/ewpschellmanco.crt -subj "/C=US/ST=Arizona/L=Tempe/O=Schellman, Inc./OU=IT/CN=ewp.schellmanco.com"

openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

mkdir /etc/nginx/snippets

echo -e "ssl_certificate /etc/ssl/certs/ewpschellmanco.crt\nssl_certificate_key /etc/ssl/private/ewpschellmanco.key" >> /etc/nginx/snippets/self-signed.conf

if [ $? -eq 0 ];

then
    MESSAGE="Self-signer certifieds configured successfully!"; blue_echo
else
    MESSAGE="Please verify the error before continue..."; red_echo
fi
sleep 1
echo "" &&


cd /etc/nginx/snippets/

wget https://github.com/srsamuka/nginx/blob/main/ssl-params.conf

cp /etc/nginx/conf/nginx.conf  /etc/nginx/conf/nginx.conf.bak

nginx -t

: <<'END_COMMENT'
pid=$!

#while kill -0 $pid  # Signal 0 just tests whether the process exists

while [ "$(ps a | awk '{print $1}' | grep $pid)" ];
do
  echo -n "."
  sleep 0.5
done
END_COMMENT
