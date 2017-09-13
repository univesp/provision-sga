echo "===> Instalando RVM ..."
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
# Appending path to rvm once
grep -qF 'source ~/.rvm/scripts/rvm' ~/.bashrc || echo 'source ~/.rvm/scripts/rvm' >> ~/.bashrc
RUBY_VERSION=$(head -n 1 .ruby-version)
rvm install $RUBY_VERSION
bash -l -c "rvm use $RUBY_VERSION --default"
bash -l -c "gem install bundler --no-doc --no-ri"
echo "===> RVM instalado com sucesso!"


echo "===> Instalando NGINX + Passenger ..."
# Link: https://www.phusionpassenger.com/library/install/nginx/install/oss/xenial/

# PGP keys and HTTPS
sudo apt-get install -y dirmngr gnupg
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
sudo apt-get install -y apt-transport-https ca-certificates

# APT repository
OS_VERSION=$(grep "VERSION_CODENAME=" /etc/os-release | awk -F= {' print $2'})
echo "deb https://oss-binaries.phusionpassenger.com/apt/passenger ${OS_VERSION} main" | sudo tee /etc/apt/sources.list.d/passenger.list
sudo apt-get update

# Installation
sudo apt-get install -y nginx-extras passenger

# Uncommenting Passenger setting
sudo sed -i 's|# include /etc/nginx/passenger.conf;|include /etc/nginx/passenger.conf;|' /etc/nginx/nginx.conf
echo "===> NGINX + Passenger instalados com sucesso!"


echo "===> Criando diretório /var/www/sga ..."
sudo mkdir -p /var/www/sga/releases
sudo mkdir -p /var/www/sga/shared
sudo chown $USER:$USER /var/www/ -R
echo "===> Diretório criado com sucesso!"


echo "===> Copiando arquivos de configuração do SGA..."
sudo cp ~/provision/config/ /var/www/sga/shared/ -r
sudo cp ~/provision/.env /var/www/sga/shared/ -r
sudo cp ~/provision/sites-available-default /etc/nginx/sites-available/ -r
sudo rm /etc/nginx/sites-available/default -f
sudo mv /etc/nginx/sites-available/sites-available-default /etc/nginx/sites-available/default
echo "===> Arquivos copiados com sucesso!"


echo "===> Instalando dependências..."
sudo apt-get install -y nodejs
sudo apt-get install -y libpq-dev
echo "===> Dependências instaladas com sucesso!"


echo "===> Completando o provisionamento..."
sudo apt -y autoremove
sudo service nginx restart
echo "===> VM provisionada com sucesso!"
