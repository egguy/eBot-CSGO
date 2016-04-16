#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR
INSTALL_DIR=$DIR/php/install/
RUNTIME_DIR=$DIR/php/runtime/
PATH=$PATH:$RUNTIME_DIR/bin/

sudo apt-get install gcc make libxml2-dev autoconf ca-certificates unzip nodejs curl libcurl4-openssl-dev pkg-config

mkdir -p $INSTALL_DIR
if [ ! -f $RUNTIME_DIR/bin/php ]; then
	cd $INSTALL_DIR
	if [ ! -f php-5.5.15.tar.bz2 ]; then
		wget http://be2.php.net/get/php-5.5.15.tar.bz2/from/this/mirror -O php-5.5.15.tar.bz2
		tar -xjvf php-5.5.15.tar.bz2
	fi
	cd $INSTALL_DIR/php-5.5.15
	./configure --prefix=$RUNTIME_DIR --with-mysql --enable-maintainer-zts --enable-sockets --with-openssl --with-pdo-mysql 
	make -j 4
	make install
fi
cd $INSTALL_DIR
wget http://pecl.php.net/get/pthreads-2.0.7.tgz
tar -xvzf pthreads-2.0.7.tgz
cd $INSTALL_DIR/pthreads-2.0.7
phpize
echo "configuring threads"
./configure 
make -j 4
make install
if [ ! -f $RUNTIME_DIR/bin/php.ini ]; then
	echo '[php]' >> $RUNTIME_DIR/bin/php.ini
	echo 'date.timezone = Europe/Paris' >> $RUNTIME_DIR/bin/php.ini
	echo 'extension=pthreads.so' >> $RUNTIME_DIR/bin/php.ini
fi

cd $DIR
NODE_PATH=$DIR/node/
NODE_BIN=$NODE_PATH/node-v4.4.3-linux-x64/bin/
PATH=$PATH:$NODE_PATH
if [ ! -f $NODE_PATH/node-v4.4.3-linux-x64.tar.xz ]; then
	mkdir -p $NODE_PATH
	cd $NODE_PATH
	wget https://nodejs.org/dist/v4.4.3/node-v4.4.3-linux-x64.tar.xz -O node-v4.4.3-linux-x64.tar.xz
	tar xvf node-v4.4.3-linux-x64.tar.xz
fi
cd $DIR
npm install socket.io@0.9.12 archiver formidable
curl -sS https://getcomposer.org/installer | php
php composer.phar install

echo "Creating run script"
cat <<SCRIPT > run.sh
#!/bin/sh

PATH=$PATH
php bootstrap.php
SCRIPT
chmod +x run.sh


exit 0

#### opt #####
# apt-get install mysql-server
#and make database
#############


mkdir /home/ebot
cd /home/ebot
wget https://github.com/deStrO/eBot-CSGO/archive/threads.zip
unzip threads.zip
mv eBot-CSGO-threads ebot-csgo
cd ebot-csgo
#curl --silent --location https://deb.nodesource.com/setup_0.12 | bash -
#apt-get install -y nodejs
#npm install socket.io@0.9.12 archiver formidable
#cd $DIR
#curl -sS https://getcomposer.org/installer | php5
#php5 composer.phar install
# edit config config/config.ini with IP/PORT and MySQL access
cd /home/ebot
wget https://github.com/deStrO/eBot-CSGO-Web/archive/master.zip
unzip master.zip
mv eBot-CSGO-Web-master ebot-web
cd ebot-web
cp config/app_user.yml.default config/app_user.yml
# edit config config/app_user.yml with ebot_ip and ebot_port
# edit database config/database.yml
mkdir cache
php5 symfony cc
php5 symfony doctrine:build --all --no-confirmation
php5 symfony guard:create-user --is-super-admin admin@ebot admin admin

#To start ebot daemon
/home/ebot/ebot-csgo
php bootstrap.php
