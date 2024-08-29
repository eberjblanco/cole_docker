echo '*************************************************'
echo '**Iniciando instalación del Backend de Cole**'
echo '*************************************************'

php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
php -r "unlink('composer-setup.php');"

read -p "Descargar el Repositorio? (Y/N) " yn
case $yn in 
	Y ) echo Descargando Repositorio...
        git clone -b main https://$1@github.com/eberjblanco/cole.git
        ;;
	N ) echo No;;
	* ) echo invalid response;
		exit 1;;
esac

read -p "Actualizar .env? (Y/N) " yn
case $yn in 
	Y ) echo Actualizando .env ...
        echo Copiando archivo .env ...
		cp .env cole/.env
        ;;
	N ) echo No;;
	* ) echo invalid response;
		exit 1;;
esac

cd /var/www/html/cole
cp -R assets/adminlte/dist public/dist
cp -R assets/adminlte/plugins public/plugins

read -p "Instalar Vendor? (Y/N) " yn
case $yn in 
	Y ) echo instalando Vendor .env ...
		composer install
        ;;
	N ) echo No;;
	* ) echo invalid response;
		exit 1;;
esac

read -p "Crear Migración? (Y/N) " yn
case $yn in 
	Y ) echo Creando Migración ...
		rm -r migrations
		mkdir migrations
		php bin/console make:migration
        ;;
	N ) echo No;;
	* ) echo invalid response;
		exit 1;;
esac

read -p "Ejecutar Migración? (Y/N) " yn
case $yn in 
	Y ) php bin/console doctrine:migrations:migrate
        ;;
	N ) echo No;;
	* ) echo invalid response;
		exit 1;;
esac

read -p "Ejecutar fixtures? (Y/N) " yn
case $yn in 
	Y ) echo Ejecutando fixtures...
		php bin/console doctrine:fixtures:load
        ;;
	N ) echo No;;
	* ) echo invalid response;
		exit 1;;
esac

composer require symfony/asset-mapper symfony/asset symfony/twig-pack
php bin/console asset-map:compile
composer require symfony/stimulus-bundle

echo 'TODO SE INSTALO BIEN...YUPIIIIIIII'