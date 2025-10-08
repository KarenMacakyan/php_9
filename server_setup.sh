#!/bin/bash

# Скрипт для настройки сервера под QloApps
# Для Ubuntu 20.04/22.04 или Debian 10/11
# Использование: sudo ./server_setup.sh

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами root (sudo)"
    exit 1
fi

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "  Настройка сервера для QloApps"
echo "========================================="
echo ""

# Обновление системы
echo -e "${YELLOW}Обновление системы...${NC}"
apt update && apt upgrade -y

# Установка Apache
echo -e "${YELLOW}Установка Apache...${NC}"
apt install -y apache2

# Установка MySQL
echo -e "${YELLOW}Установка MySQL...${NC}"
apt install -y mysql-server

# Установка PHP 8.2 и необходимых модулей
echo -e "${YELLOW}Установка PHP 8.2 и расширений...${NC}"
apt install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
apt update

apt install -y php8.2 \
    php8.2-cli \
    php8.2-common \
    php8.2-mysql \
    php8.2-curl \
    php8.2-gd \
    php8.2-mbstring \
    php8.2-xml \
    php8.2-xmlrpc \
    php8.2-soap \
    php8.2-intl \
    php8.2-zip \
    php8.2-bcmath \
    libapache2-mod-php8.2

# Настройка PHP
echo -e "${YELLOW}Настройка PHP...${NC}"
PHP_INI="/etc/php/8.2/apache2/php.ini"

# Создание бэкапа конфига
cp $PHP_INI "${PHP_INI}.backup"

# Изменение настроек PHP
sed -i 's/memory_limit = .*/memory_limit = 256M/' $PHP_INI
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' $PHP_INI
sed -i 's/post_max_size = .*/post_max_size = 100M/' $PHP_INI
sed -i 's/max_execution_time = .*/max_execution_time = 500/' $PHP_INI
sed -i 's/max_input_time = .*/max_input_time = 500/' $PHP_INI
sed -i 's/;max_input_vars = .*/max_input_vars = 5000/' $PHP_INI
sed -i 's/display_errors = .*/display_errors = Off/' $PHP_INI
sed -i 's/;date.timezone =.*/date.timezone = Europe\/Moscow/' $PHP_INI

# Включение OpCache
cat >> $PHP_INI << 'EOF'

; OpCache settings for QloApps
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=0
EOF

# Включение необходимых модулей Apache
echo -e "${YELLOW}Включение модулей Apache...${NC}"
a2enmod rewrite
a2enmod headers
a2enmod expires
a2enmod deflate
a2enmod ssl

# Настройка виртуального хоста
echo -e "${YELLOW}Создание виртуального хоста...${NC}"
cat > /etc/apache2/sites-available/qloapps.conf << 'EOF'
<VirtualHost *:80>
    ServerAdmin admin@your-domain.com
    ServerName your-domain.com
    ServerAlias www.your-domain.com
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/qloapps_error.log
    CustomLog ${APACHE_LOG_DIR}/qloapps_access.log combined

    # Безопасность
    ServerTokens Prod
    ServerSignature Off
    
    # Ограничение размера запросов
    LimitRequestBody 104857600
</VirtualHost>
EOF

# Отключение дефолтного сайта и включение нового
a2dissite 000-default.conf
a2ensite qloapps.conf

# Настройка MySQL
echo -e "${YELLOW}Настройка MySQL...${NC}"
mysql_secure_installation

# Создание пользователя и базы данных для QloApps
echo -e "${YELLOW}Создание базы данных для QloApps...${NC}"
echo ""
read -p "Введите имя базы данных [qloapps_db]: " DB_NAME
DB_NAME=${DB_NAME:-qloapps_db}

read -p "Введите имя пользователя БД [qloapps_user]: " DB_USER
DB_USER=${DB_USER:-qloapps_user}

read -sp "Введите пароль для пользователя БД: " DB_PASS
echo ""

# Создание БД и пользователя
mysql << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

# Установка Certbot для SSL
echo -e "${YELLOW}Установка Certbot для SSL сертификатов...${NC}"
apt install -y certbot python3-certbot-apache

# Создание директории для веб-сайта
echo -e "${YELLOW}Создание директории для сайта...${NC}"
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Установка дополнительных утилит
echo -e "${YELLOW}Установка дополнительных утилит...${NC}"
apt install -y unzip zip curl wget git htop

# Настройка firewall (если используется)
if command -v ufw &> /dev/null; then
    echo -e "${YELLOW}Настройка UFW firewall...${NC}"
    ufw allow 'Apache Full'
    ufw allow OpenSSH
    ufw --force enable
fi

# Перезапуск Apache
echo -e "${YELLOW}Перезапуск Apache...${NC}"
systemctl restart apache2
systemctl enable apache2

# Проверка статуса сервисов
echo ""
echo -e "${GREEN}========================================="
echo -e "  Настройка завершена!"
echo -e "=========================================${NC}"
echo ""
echo -e "${GREEN}Статус сервисов:${NC}"
systemctl is-active --quiet apache2 && echo -e "  ✅ Apache: ${GREEN}работает${NC}" || echo -e "  ❌ Apache: ${RED}не работает${NC}"
systemctl is-active --quiet mysql && echo -e "  ✅ MySQL: ${GREEN}работает${NC}" || echo -e "  ❌ MySQL: ${RED}не работает${NC}"

echo ""
echo -e "${YELLOW}Информация о базе данных:${NC}"
echo "  Database name: ${DB_NAME}"
echo "  Database user: ${DB_USER}"
echo "  Database password: ${DB_PASS}"
echo "  Database host: localhost"
echo ""
echo -e "${YELLOW}Следующие шаги:${NC}"
echo "  1. Загрузите файлы QloApps в /var/www/html/"
echo "  2. Настройте права доступа:"
echo "     sudo chown -R www-data:www-data /var/www/html"
echo "     sudo find /var/www/html -type d -exec chmod 755 {} \;"
echo "     sudo find /var/www/html -type f -exec chmod 644 {} \;"
echo ""
echo "  3. Откройте браузер и перейдите по адресу http://your-domain.com/install/"
echo ""
echo "  4. Для настройки SSL выполните:"
echo "     sudo certbot --apache -d your-domain.com -d www.your-domain.com"
echo ""
echo -e "${GREEN}Версии установленного ПО:${NC}"
apache2 -v | head -1
mysql --version
php -v | head -1
echo ""
echo -e "${GREEN}PHP модули:${NC}"
php -m | grep -E "pdo_mysql|curl|openssl|soap|gd|simplexml|dom|zip"
echo ""

