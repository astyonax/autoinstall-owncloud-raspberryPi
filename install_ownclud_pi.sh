# from:
# http://www.techjawab.com/2014/08/how-to-setup-owncloud-7-on-raspberry-pi.html
set -x

sudo apt-get update
sudo apt-get upgrade
sudo groupadd www-data
sudo usermod -a -G www-data www-data
sudo apt-get install nginx openssl ssl-cert php5-cli php5-sqlite php5-gd php5-common php5-cgi sqlite3 php-pear php-apc curl libapr1 libtool curl libcurl4-openssl-dev php-xml-parser php5 php5-dev php5-gd php5-fpm memcached php5-memcache varnish

# needed by .../owncloud/core/img/image-optimization.sh
sudo apt-get install jpegoptim optipng
sudo apt-get --purge remove php5-curl
# 2 years valid certificate 
# https://t37.net/a-poodle-proof-bulletproof-nginx-ssl-configuration.html
sudo openssl req $@ -new -x509 -days 730 -nodes -out /etc/nginx/cert.pem -keyout /etc/nginx/cert.key
sudo chmod 600 /etc/nginx/cert.pem
sudo chmod 600 /etc/nginx/cert.key
sed s/'technet.example.com'/'wolfeat.duckdns.org'/ nginx.conf > tmp
sudo mv  tmp /etc/nginx/sites-available/default -v

#configure here the php files.. 
sed s/'upload_max_filesize.*'/'upload_max_filesize = 1024M'/ /etc/php5/fpm/php.ini |sed s/'post_max_size.*'/'post_max_size = 1024M'/ > tmp_php.ini
sudo mv /etc/php5/fpm/php.ini /etc/php5/fpm/php.ini~ -v
sudo mv tmp_php.ini /etc/php5/fpm/php.ini -v

sed s/'^listen .*'/'listen=127.0.0.1:9000'/ /etc/php5/fpm/pool.d/www.conf > tmp_www.conf
sudo mv /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/www.conf~ -v
sudo mv tmp_www.conf /etc/php5/fpm/pool.d/www.conf -v

cat CONF_SWAPSIZE=512 > tmp_swapfile
sudo mv /etc/dphys-swapfie /etc/dphys-swapfie~ -v
sudo mv tmp_swapfile /etc/dphys-swapfile -v

#you need to cofigure apc and NGINX too to serve static files as static
# configured the sites-available
#and /etc/nginx/nginx.conf

sudo /etc/init.d/php5-fpm restart
sudo /etc/init.d/nginx restart

OCLD=owncloud-7.0.4.tar.bz2

wget -c https://download.owncloud.org/community/${OCLD}
wget -c https://download.owncloud.org/community/${OCLD}.md5
echo "============================================="
echo "         VERIFing MD5SUM of downloaded files "
md5sum ${OCLD}
cat ${OCLD}.md5
echo "                      DONE                   "


tar xjf $OCLD 
sudo mv owncloud/ /var/www/
sudo chown -R www-data:www-data /var/www

rm $OCLD $OCLD.md5 owncloud

echo "DONE"
exit
