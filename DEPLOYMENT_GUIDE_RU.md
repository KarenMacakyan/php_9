# Руководство по развертыванию QloApps на хостинге

## 📋 Оглавление
- [Системные требования](#системные-требования)
- [Подготовка к развертыванию](#подготовка-к-развертыванию)
- [Шаг 1: Выбор и настройка хостинга](#шаг-1-выбор-и-настройка-хостинга)
- [Шаг 2: Подготовка файлов](#шаг-2-подготовка-файлов)
- [Шаг 3: Загрузка на хостинг](#шаг-3-загрузка-на-хостинг)
- [Шаг 4: Настройка базы данных](#шаг-4-настройка-базы-данных)
- [Шаг 5: Установка QloApps](#шаг-5-установка-qloapps)
- [Шаг 6: Настройка безопасности](#шаг-6-настройка-безопасности)
- [Шаг 7: SSL сертификат](#шаг-7-ssl-сертификат)
- [Оптимизация производительности](#оптимизация-производительности)
- [Резервное копирование](#резервное-копирование)
- [Решение проблем](#решение-проблем)

---

## 🔧 Системные требования

### Обязательные требования к хостингу:

#### Веб-сервер:
- Apache 1.3, Apache 2.x (рекомендуется)
- Nginx
- Microsoft IIS

#### PHP:
- **Версия**: PHP 8.1, 8.2, 8.3 или 8.4
- **Обязательные расширения**:
  - PDO_MySQL
  - cURL
  - OpenSSL
  - SOAP
  - GD
  - SimpleXML
  - DOM
  - Zip
  - Phar

#### Настройки PHP (php.ini):
```ini
memory_limit = 128M (минимум)
upload_max_filesize = 100M
max_execution_time = 500
allow_url_fopen = On
post_max_size = 100M
max_input_vars = 5000
```

#### База данных:
- **MySQL**: версия 5.7+ до 8.4
- **MariaDB**: 10.3+ (совместимо)

#### Доступ:
- SSH или FTP/SFTP доступ
- SSL сертификат (для приема платежей)

---

## 📦 Подготовка к развертыванию

### Контрольный список перед началом:

1. ✅ Доступ к хостингу (SSH/FTP)
2. ✅ Данные для подключения к MySQL
3. ✅ Доменное имя (настроенное на хостинг)
4. ✅ SSL сертификат (рекомендуется)
5. ✅ Резервная копия текущих данных (если есть)

---

## Шаг 1: Выбор и настройка хостинга

### Рекомендуемые хостинг-провайдеры:

#### Для российского рынка:
- **Timeweb** (поддержка PHP 8.x, SSL бесплатно)
- **RU-CENTER**
- **REG.RU**
- **Beget**

#### Международные:
- **DigitalOcean** (VPS)
- **AWS** (EC2)
- **Vultr**
- **Hostinger**

### Проверка совместимости хостинга:

Попросите у хостинг-провайдера или проверьте в панели управления:
```bash
# Проверка версии PHP
php -v

# Проверка расширений
php -m | grep -E "pdo_mysql|curl|openssl|soap|gd|simplexml|dom|zip|phar"
```

---

## Шаг 2: Подготовка файлов

### Создание архива проекта:

```bash
# Перейдите в директорию проекта
cd /Users/macbook/Desktop/QloApps-develop

# Создайте архив (исключая ненужные файлы)
tar -czf qloapps.tar.gz \
  --exclude='*.git' \
  --exclude='node_modules' \
  --exclude='.DS_Store' \
  --exclude='*.log' \
  --exclude='cache/smarty/cache/*' \
  --exclude='cache/smarty/compile/*' \
  .
```

### Альтернативно - через ZIP:
```bash
zip -r qloapps.zip . -x "*.git*" "node_modules/*" ".DS_Store" "*.log" "cache/smarty/cache/*" "cache/smarty/compile/*"
```

---

## Шаг 3: Загрузка на хостинг

### Вариант A: Через FTP/SFTP (FileZilla, Cyberduck)

1. **Подключитесь к FTP**:
   - Host: `ftp.your-domain.com`
   - Username: `your_ftp_user`
   - Password: `your_ftp_password`
   - Port: 21 (FTP) или 22 (SFTP)

2. **Загрузите файлы**:
   - Перейдите в корневую директорию веб-сервера (обычно `/public_html` или `/www` или `/httpdocs`)
   - Загрузите архив `qloapps.tar.gz`
   - Распакуйте на сервере (через SSH) или загрузите распакованные файлы

### Вариант B: Через SSH (рекомендуется)

```bash
# Подключитесь к серверу
ssh your_user@your-server.com

# Перейдите в корневую директорию
cd /var/www/html  # или /home/your_user/public_html

# Загрузите файлы с локальной машины (в новом терминале)
scp /Users/macbook/Desktop/QloApps-develop/qloapps.tar.gz your_user@your-server.com:/var/www/html/

# Вернитесь на сервер и распакуйте
tar -xzf qloapps.tar.gz
rm qloapps.tar.gz
```

### Вариант C: Через Git (если у вас есть репозиторий)

```bash
# На сервере
cd /var/www/html
git clone https://github.com/your-repo/qloapps.git .
```

---

## Шаг 4: Настройка базы данных

### Создание базы данных MySQL:

#### Через phpMyAdmin:
1. Войдите в phpMyAdmin
2. Создайте новую базу данных:
   - Имя: `qloapps_db`
   - Кодировка: `utf8mb4_general_ci`
3. Создайте пользователя:
   - Имя: `qloapps_user`
   - Пароль: `strong_password_here`
   - Хост: `localhost`
4. Предоставьте все права пользователю для базы данных

#### Через SSH/MySQL командную строку:
```sql
# Войдите в MySQL
mysql -u root -p

# Создайте базу данных
CREATE DATABASE qloapps_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

# Создайте пользователя
CREATE USER 'qloapps_user'@'localhost' IDENTIFIED BY 'strong_password_here';

# Предоставьте права
GRANT ALL PRIVILEGES ON qloapps_db.* TO 'qloapps_user'@'localhost';
FLUSH PRIVILEGES;

# Выйдите
EXIT;
```

### Сохраните данные:
```
Database Name: qloapps_db
Database User: qloapps_user
Database Password: strong_password_here
Database Host: localhost
```

---

## Шаг 5: Установка QloApps

### Установка прав доступа к файлам:

```bash
# Установите правильного владельца (замените www-data на вашего веб-пользователя)
sudo chown -R www-data:www-data /var/www/html

# Установите права на директории
find /var/www/html -type d -exec chmod 755 {} \;

# Установите права на файлы
find /var/www/html -type f -exec chmod 644 {} \;

# Особые права для записываемых директорий
chmod 777 config
chmod 777 cache
chmod 777 log
chmod 777 img
chmod 777 mails
chmod 777 modules
chmod 777 themes/hotel-reservation-theme/cache
chmod 777 translations
chmod 777 upload
chmod 777 download
chmod 777 admin/autoupgrade
chmod 777 admin/backups
chmod 777 admin/import
chmod 777 admin/export
```

### Запуск установщика:

1. **Откройте браузер** и перейдите по адресу:
   ```
   http://your-domain.com/install/
   ```

2. **Следуйте инструкциям установщика**:

   **Шаг 1 - Выбор языка:**
   - Выберите язык интерфейса

   **Шаг 2 - Лицензионное соглашение:**
   - Примите условия лицензии (OSL 3.0)

   **Шаг 3 - Совместимость системы:**
   - Система проверит требования
   - Убедитесь, что все пункты зеленые ✅

   **Шаг 4 - Информация о магазине:**
   ```
   Название отеля: Ваше название
   Деятельность: Hotel
   Страна: Russia (или ваша страна)
   Имя: Ваше имя
   Фамилия: Ваша фамилия
   Email: admin@your-domain.com
   Пароль: Сильный пароль
   ```

   **Шаг 5 - Конфигурация базы данных:**
   ```
   Database server address: localhost
   Database name: qloapps_db
   Database login: qloapps_user
   Database password: strong_password_here
   Tables prefix: ps_ (оставьте по умолчанию)
   ```

   **Шаг 6 - Установка:**
   - Дождитесь завершения установки

3. **После установки**:
   - Сохраните данные для входа
   - Удалите папку установки:
   ```bash
   rm -rf install/
   rm -rf install-dev/
   ```

---

## Шаг 6: Настройка безопасности

### 1. Переименуйте папку администратора:

```bash
# На сервере
cd /var/www/html
mv admin admin_secretname123

# Обновите константу в config/defines.inc.php
# (будет сделано автоматически установщиком)
```

### 2. Настройте .htaccess для дополнительной защиты:

Создайте/обновите файл `.htaccess` в корне:

```apache
# Защита от некоторых эксплоитов
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_METHOD} ^(HEAD|TRACE|DELETE|TRACK|DEBUG) [NC]
    RewriteRule ^(.*)$ - [F,L]
</IfModule>

# Защита файлов конфигурации
<FilesMatch "\.(htaccess|htpasswd|ini|log|sh|inc|bak|swp)$">
    Order Allow,Deny
    Deny from all
</FilesMatch>

# Защита от SQL инъекций через URL
<IfModule mod_rewrite.c>
    RewriteCond %{QUERY_STRING} [a-zA-Z0-9_]=http:// [OR]
    RewriteCond %{QUERY_STRING} [a-zA-Z0-9_]=(\.\.//?)+ [OR]
    RewriteCond %{QUERY_STRING} [a-zA-Z0-9_]=/([a-z0-9_.]//?)+ [NC]
    RewriteRule .* - [F]
</IfModule>
```

### 3. Настройте config/settings.inc.php:

После установки отредактируйте `config/settings.inc.php`:

```php
// В production режиме отключите debug
define('_PS_MODE_DEV_', false);

// Отключите отображение ошибок
define('_PS_DEBUG_SQL_', false);
define('_PS_DEBUG_PROFILING_', false);
```

### 4. Установите правильные права (финальные):

```bash
# После установки ограничьте права
chmod 644 config/settings.inc.php
chmod 755 config

# Для безопасности
chmod 644 .htaccess
chmod 644 robots.txt
```

---

## Шаг 7: SSL сертификат

### Получение бесплатного SSL (Let's Encrypt):

#### Вариант A: Через панель управления хостингом
- Большинство панелей (cPanel, ISPmanager, Plesk) имеют встроенную установку Let's Encrypt
- Перейдите в раздел SSL/TLS и активируйте сертификат

#### Вариант B: Через Certbot (для VPS/выделенного сервера):

```bash
# Установите Certbot (Ubuntu/Debian)
sudo apt update
sudo apt install certbot python3-certbot-apache

# Для Apache
sudo certbot --apache -d your-domain.com -d www.your-domain.com

# Для Nginx
sudo apt install python3-certbot-nginx
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Автоматическое обновление
sudo certbot renew --dry-run
```

### Настройка QloApps для работы с SSL:

1. Войдите в админ-панель: `https://your-domain.com/admin_secretname123`

2. Перейдите в:
   ```
   Настройки → Общие настройки → Включить SSL → Да
   Настройки → Общие настройки → Включить SSL на всех страницах → Да
   ```

3. Сохраните изменения

### Обновите файл .htaccess для перенаправления на HTTPS:

```apache
# В начало файла .htaccess добавьте:
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</IfModule>
```

---

## 🚀 Оптимизация производительности

### 1. Включите кэширование в QloApps:

В админ-панели:
```
Расширенные параметры → Производительность
→ Включить кэш ✅
→ Использовать CCC (Combine, Compress, Cache) ✅
→ Тип кэша: Файловая система (для начала)
```

### 2. Настройте OpCache (php.ini):

```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
```

### 3. Включите сжатие GZIP (Apache):

В `.htaccess`:
```apache
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/x-javascript
</IfModule>
```

### 4. Настройте кэш браузера:

В `.htaccess`:
```apache
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

### 5. Оптимизация базы данных:

```bash
# Оптимизация таблиц MySQL
mysqlcheck -o qloapps_db -u qloapps_user -p

# Или через SQL
mysql -u qloapps_user -p qloapps_db -e "OPTIMIZE TABLE ps_product, ps_category, ps_cart, ps_orders;"
```

---

## 💾 Резервное копирование

### Создание автоматического бэкапа:

#### Скрипт для резервного копирования:

Создайте файл `/home/your_user/backup_qloapps.sh`:

```bash
#!/bin/bash

# Настройки
SITE_PATH="/var/www/html"
BACKUP_PATH="/home/your_user/backups"
DB_NAME="qloapps_db"
DB_USER="qloapps_user"
DB_PASS="strong_password_here"
DATE=$(date +%Y%m%d_%H%M%S)

# Создайте директорию для бэкапов
mkdir -p $BACKUP_PATH

# Бэкап базы данных
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_PATH/db_backup_$DATE.sql.gz

# Бэкап файлов
tar -czf $BACKUP_PATH/files_backup_$DATE.tar.gz -C $SITE_PATH .

# Удаление старых бэкапов (старше 30 дней)
find $BACKUP_PATH -type f -mtime +30 -delete

echo "Backup completed: $DATE"
```

#### Настройка cron для автоматического бэкапа:

```bash
# Сделайте скрипт исполняемым
chmod +x /home/your_user/backup_qloapps.sh

# Добавьте в cron (ежедневно в 2:00 ночи)
crontab -e

# Добавьте строку:
0 2 * * * /home/your_user/backup_qloapps.sh >> /home/your_user/backup.log 2>&1
```

### Ручное резервное копирование:

```bash
# База данных
mysqldump -u qloapps_user -p qloapps_db > backup_$(date +%Y%m%d).sql

# Файлы
tar -czf backup_files_$(date +%Y%m%d).tar.gz /var/www/html
```

---

## 🔍 Решение проблем

### Проблема: Белый экран (White Screen of Death)

**Решение:**
```bash
# Включите отображение ошибок
echo "ini_set('display_errors', 1);" >> index.php
echo "error_reporting(E_ALL);" >> index.php

# Проверьте лог ошибок
tail -f /var/www/html/log/error.log
tail -f /var/log/apache2/error.log
```

### Проблема: 500 Internal Server Error

**Решение:**
```bash
# Проверьте .htaccess
mv .htaccess .htaccess.bak

# Проверьте права доступа
chmod 755 /var/www/html
chmod 644 /var/www/html/index.php

# Проверьте логи сервера
tail -f /var/log/apache2/error.log
```

### Проблема: Не загружаются изображения

**Решение:**
```bash
# Установите правильные права
chmod 777 img
chmod 777 upload

# Проверьте .htaccess в директории img
```

### Проблема: Медленная работа сайта

**Решение:**
1. Включите кэширование в админ-панели
2. Оптимизируйте базу данных
3. Включите CDN для статических файлов
4. Увеличьте memory_limit в php.ini

### Проблема: Не работает установщик

**Решение:**
```bash
# Удалите старые файлы конфигурации
rm -f config/settings.inc.php

# Дайте права на запись
chmod 777 config
chmod 777 cache
chmod 777 img
chmod 777 log
chmod 777 modules
```

---

## 📊 Проверочный список после установки

- [ ] Сайт доступен по домену
- [ ] SSL сертификат установлен и работает
- [ ] Админ-панель доступна и защищена
- [ ] Папка install удалена
- [ ] Папка admin переименована
- [ ] Права доступа к файлам настроены
- [ ] База данных создана и подключена
- [ ] Резервное копирование настроено
- [ ] Email уведомления работают
- [ ] Платежные методы настроены
- [ ] Тестовое бронирование выполнено успешно

---

## 📞 Полезные ссылки

- **Официальная документация**: https://docs.qloapps.com
- **Форум поддержки**: https://forums.qloapps.com
- **Демо**: https://demo.qloapps.com
- **Плагины**: https://qloapps.com/addons/

---

## ✅ Готово!

После выполнения всех шагов ваш сайт QloApps будет успешно развернут и готов к работе!

Для дальнейшей настройки:
1. Загрузите фотографии вашего отеля
2. Настройте номера и типы комнат
3. Установите платежные методы
4. Настройте email уведомления
5. Настройте SEO параметры

**Удачи с вашим проектом! 🎉**

