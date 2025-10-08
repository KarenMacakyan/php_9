# QloApps - Система бронирования отелей

![QloApps](https://forums.qloapps.com/assets/uploads/system/site-logo.png)

## 📝 Описание

QloApps - это бесплатная open-source платформа для запуска собственного сайта бронирования отелей. Система предназначена для использования в гостиничном бизнесе и позволяет принимать и управлять бронированиями онлайн.

От небольших независимых отелей до крупных гостиничных сетей - QloApps является комплексным решением для всех потребностей вашего гостиничного бизнеса.

## ✨ Возможности

- 🏨 Управление отелями и номерами
- 📅 Онлайн бронирование в реальном времени
- 💳 Интеграция платежных систем
- 🌍 Многоязычность
- 📧 Email уведомления
- 📊 Панель аналитики
- 🎨 Настраиваемый дизайн
- 📱 Адаптивный интерфейс

## 🔧 Системные требования

### Веб-сервер:
- Apache 1.3, Apache 2.x, Nginx или Microsoft IIS

### PHP:
- **Версия**: PHP 8.1+ до PHP 8.4
- **Обязательные расширения**: PDO_MySQL, cURL, OpenSSL, SOAP, GD, SimpleXML, DOM, Zip, Phar

### Настройки PHP (php.ini):
```ini
memory_limit = 128M (минимум)
upload_max_filesize = 100M
max_execution_time = 500
allow_url_fopen = On
```

### База данных:
- MySQL 5.7+ до 8.4
- MariaDB 10.3+

## 📦 Установка

### Способ 1: Ручная установка

1. **Загрузите проект на сервер**
```bash
git clone https://github.com/KarenMacakyan/php_9.git
cd php_9
```

2. **Установите права доступа**
```bash
chmod +x set_permissions.sh
sudo ./set_permissions.sh
```

3. **Создайте базу данных MySQL**
```sql
CREATE DATABASE qloapps_db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'qloapps_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON qloapps_db.* TO 'qloapps_user'@'localhost';
FLUSH PRIVILEGES;
```

4. **Откройте браузер и запустите установщик**
```
http://your-domain.com/install/
```

### Способ 2: Автоматическая подготовка для деплоя

```bash
# Подготовка файлов для загрузки на хостинг
chmod +x deploy_prepare.sh
./deploy_prepare.sh
```

### Способ 3: Автоматическая настройка сервера (Ubuntu/Debian)

```bash
# Настройка сервера с нуля (требуются права root)
chmod +x server_setup.sh
sudo ./server_setup.sh
```

## 🚀 Развертывание на хостинге

### Рекомендуемые хостинг-провайдеры:

#### Для России:
- **Timeweb** - поддержка PHP 8.x, бесплатный SSL
- **Beget** - отличная поддержка
- **REG.RU** - надежный хостинг
- **RU-CENTER** - стабильная работа

#### Международные:
- **DigitalOcean** (VPS) - от $5/месяц
- **Vultr** (VPS) - гибкие тарифы
- **Hostinger** - недорогой shared хостинг

### Пошаговое руководство по развертыванию:

📖 **Подробное руководство**: [DEPLOYMENT_GUIDE_RU.md](DEPLOYMENT_GUIDE_RU.md)

## 🔒 Безопасность

После установки обязательно:

1. ✅ Удалите папку `install/`
2. ✅ Переименуйте папку `admin/` в случайное имя
3. ✅ Установите SSL сертификат
4. ✅ Настройте регулярное резервное копирование
5. ✅ Ограничьте права доступа к файлам

```bash
# Удаление установщика
rm -rf install/

# Переименование админ-панели
mv admin admin_secretname123

# Резервное копирование
chmod +x backup_qloapps.sh
./backup_qloapps.sh
```

## 📊 Резервное копирование

Настройте автоматическое резервное копирование:

```bash
# Ручное создание бэкапа
./backup_qloapps.sh

# Автоматическое резервное копирование (cron)
# Добавьте в crontab:
0 2 * * * /path/to/backup_qloapps.sh >> /path/to/backup.log 2>&1
```

## 🛠️ Полезные скрипты

В проекте включены вспомогательные скрипты:

- `deploy_prepare.sh` - подготовка к развертыванию
- `server_setup.sh` - автоматическая настройка сервера
- `set_permissions.sh` - установка прав доступа
- `backup_qloapps.sh` - резервное копирование

## 📚 Документация

- 📖 [Официальная документация](https://docs.qloapps.com)
- 🎯 [Демо-версия](https://demo.qloapps.com)
- 💬 [Форум поддержки](https://forums.qloapps.com)
- 🔌 [Плагины и расширения](https://qloapps.com/addons/)

## 🔗 Полезные ссылки

- **Официальный сайт**: https://www.qloapps.com
- **GitHub**: https://github.com/webkul/hotelcommerce
- **Документация**: https://docs.qloapps.com

## 📝 Лицензия

QloApps распространяется под лицензией OSL-3.0 (Open Software License 3.0)

## 🤝 Поддержка

Если у вас возникли вопросы:

- 📧 Email: support@qloapps.com
- 💬 Форум: https://forums.qloapps.com
- 📱 Telegram: (создайте группу поддержки)

## 🌟 Автор

Создано с ❤️ командой [Webkul](https://webkul.com)

Адаптировано для развертывания: Karen Macakyan

---

## ⚙️ Настройка после установки

1. **Загрузите фотографии отеля**
2. **Настройте типы номеров и цены**
3. **Установите платежные методы**
4. **Настройте email уведомления**
5. **Оптимизируйте SEO параметры**
6. **Подключите Google Analytics**

## 🎨 Кастомизация

Тема находится в:
```
themes/hotel-reservation-theme/
```

Для изменения дизайна редактируйте файлы в этой директории.

## 🐛 Решение проблем

### Белый экран (500 ошибка)
```bash
# Проверьте логи
tail -f log/error.log
tail -f /var/log/apache2/error.log
```

### Не загружаются изображения
```bash
chmod 777 img
chmod 777 upload
```

### Медленная работа
- Включите кэширование в админ-панели
- Оптимизируйте базу данных
- Используйте CDN

---

**Удачи с вашим проектом! 🎉**

