#!/bin/bash
Basepath=$(cd `dirname $0`; pwd)
cd /root
groupadd -r www && useradd -r -g www -s /sbin/nologin -d /usr/local/nginx -M www
mkdir -p /usr/local/nginx

apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev unzip git sysv-rc-conf
wget --no-check-certificate http://nginx.org/download/nginx-1.15.8.tar.gz && tar xzf nginx-1.15.8.tar.gz && rm -rf nginx-1.15.8.tar.gz
cd nginx-1.15.8/
git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli && git submodule update --init && cd ../
wget --no-check-certificate https://github.com/openssl/openssl/archive/OpenSSL_1_1_1b.zip && unzip OpenSSL_1_1_1b.zip && rm -rf OpenSSL_1_1_1b.zip
mv openssl-OpenSSL_1_1_1b/ openssl-1_1_1b/
./configure --user=www --group=www --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-stream_ssl_module --with-openssl=./openssl-1_1_1b --add-module=./ngx_brotli
make -j$(nproc) && make install
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx

mkdir -p /usr/local/nginx/conf/vhost
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
rm -rf /usr/local/nginx/conf/nginx.conf
cp ${Basepath}/../Config/nginx.conf /usr/local/nginx/conf/
cp ${Basepath}/../Config/nginx /etc/init.d/ && ln -s /etc/init.d/nginx /etc/rc5.d/S01nginx && /usr/sbin/nginx
openssl  dhparam -out /usr/local/nginx/conf/dhparam.pem 2048
sysv-rc-conf nginx on
update-rc.d nginx defaults
service nginx start