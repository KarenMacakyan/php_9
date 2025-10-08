#!/bin/bash

# Скрипт резервного копирования QloApps
# Использование: ./backup_qloapps.sh

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "  Резервное копирование QloApps"
echo "========================================="
echo ""

# Настройки (измените под свои параметры)
SITE_PATH="/var/www/html"
BACKUP_PATH="/home/$(whoami)/backups"
DB_NAME="qloapps_db"
DB_USER="qloapps_user"
DB_PASS=""
DB_HOST="localhost"

# Дата для имени бэкапа
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="qloapps_backup_${DATE}"

# Проверка существования директории сайта
if [ ! -d "$SITE_PATH" ]; then
    echo -e "${RED}Ошибка: Директория $SITE_PATH не найдена${NC}"
    exit 1
fi

# Создание директории для бэкапов
mkdir -p "$BACKUP_PATH"

# Если пароль не указан, запросить его
if [ -z "$DB_PASS" ]; then
    echo -e "${YELLOW}Введите параметры базы данных:${NC}"
    read -p "Имя базы данных [$DB_NAME]: " input_db_name
    DB_NAME=${input_db_name:-$DB_NAME}
    
    read -p "Пользователь БД [$DB_USER]: " input_db_user
    DB_USER=${input_db_user:-$DB_USER}
    
    read -sp "Пароль БД: " DB_PASS
    echo ""
fi

echo ""
echo -e "${YELLOW}Создание резервной копии...${NC}"

# 1. Бэкап базы данных
echo -e "${YELLOW}[1/3] Резервное копирование базы данных...${NC}"
if mysqldump -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" 2>/dev/null | gzip > "$BACKUP_PATH/${BACKUP_NAME}_database.sql.gz"; then
    DB_SIZE=$(du -h "$BACKUP_PATH/${BACKUP_NAME}_database.sql.gz" | cut -f1)
    echo -e "${GREEN}  ✅ База данных сохранена ($DB_SIZE)${NC}"
else
    echo -e "${RED}  ❌ Ошибка при создании бэкапа базы данных${NC}"
    exit 1
fi

# 2. Бэкап файлов
echo -e "${YELLOW}[2/3] Резервное копирование файлов...${NC}"
if tar -czf "$BACKUP_PATH/${BACKUP_NAME}_files.tar.gz" \
    --exclude='cache/smarty/cache/*' \
    --exclude='cache/smarty/compile/*' \
    --exclude='*.log' \
    -C "$SITE_PATH" . 2>/dev/null; then
    FILES_SIZE=$(du -h "$BACKUP_PATH/${BACKUP_NAME}_files.tar.gz" | cut -f1)
    echo -e "${GREEN}  ✅ Файлы сохранены ($FILES_SIZE)${NC}"
else
    echo -e "${RED}  ❌ Ошибка при создании бэкапа файлов${NC}"
    exit 1
fi

# 3. Создание полного архива (опционально)
echo -e "${YELLOW}[3/3] Создание полного архива...${NC}"
cd "$BACKUP_PATH" || exit
tar -czf "${BACKUP_NAME}_full.tar.gz" \
    "${BACKUP_NAME}_database.sql.gz" \
    "${BACKUP_NAME}_files.tar.gz" 2>/dev/null

FULL_SIZE=$(du -h "$BACKUP_PATH/${BACKUP_NAME}_full.tar.gz" | cut -f1)
echo -e "${GREEN}  ✅ Полный архив создан ($FULL_SIZE)${NC}"

# Создание файла с информацией о бэкапе
cat > "$BACKUP_PATH/${BACKUP_NAME}_info.txt" << EOF
QloApps Backup Information
==========================
Дата создания: $(date +"%Y-%m-%d %H:%M:%S")
Версия QloApps: $(cat $SITE_PATH/install/install_version.php 2>/dev/null | grep _PS_INSTALL_VERSION_ | cut -d "'" -f 4)

База данных:
  - Имя: $DB_NAME
  - Пользователь: $DB_USER
  - Хост: $DB_HOST
  - Размер бэкапа: $DB_SIZE

Файлы:
  - Путь: $SITE_PATH
  - Размер бэкапа: $FILES_SIZE

Полный архив:
  - Размер: $FULL_SIZE

Файлы бэкапа:
  - ${BACKUP_NAME}_database.sql.gz
  - ${BACKUP_NAME}_files.tar.gz
  - ${BACKUP_NAME}_full.tar.gz
  - ${BACKUP_NAME}_info.txt

Восстановление:
  1. База данных:
     gunzip < ${BACKUP_NAME}_database.sql.gz | mysql -u $DB_USER -p $DB_NAME
  
  2. Файлы:
     tar -xzf ${BACKUP_NAME}_files.tar.gz -C /path/to/restore/
EOF

echo ""
echo -e "${GREEN}========================================="
echo -e "  Резервное копирование завершено!"
echo -e "=========================================${NC}"
echo ""
echo -e "${GREEN}Созданные файлы:${NC}"
echo -e "  📦 База данных: ${YELLOW}${BACKUP_NAME}_database.sql.gz${NC} ($DB_SIZE)"
echo -e "  📦 Файлы: ${YELLOW}${BACKUP_NAME}_files.tar.gz${NC} ($FILES_SIZE)"
echo -e "  📦 Полный архив: ${YELLOW}${BACKUP_NAME}_full.tar.gz${NC} ($FULL_SIZE)"
echo -e "  📄 Информация: ${YELLOW}${BACKUP_NAME}_info.txt${NC}"
echo ""
echo -e "${GREEN}Расположение: ${YELLOW}$BACKUP_PATH${NC}"
echo ""

# Очистка старых бэкапов (старше 30 дней)
echo -e "${YELLOW}Очистка старых бэкапов (старше 30 дней)...${NC}"
OLD_BACKUPS=$(find "$BACKUP_PATH" -name "qloapps_backup_*" -type f -mtime +30 2>/dev/null | wc -l)
if [ "$OLD_BACKUPS" -gt 0 ]; then
    find "$BACKUP_PATH" -name "qloapps_backup_*" -type f -mtime +30 -delete 2>/dev/null
    echo -e "${GREEN}  ✅ Удалено $OLD_BACKUPS старых файлов${NC}"
else
    echo -e "${GREEN}  ✅ Старых бэкапов не найдено${NC}"
fi

echo ""
echo -e "${YELLOW}Команды для восстановления:${NC}"
echo ""
echo -e "${YELLOW}База данных:${NC}"
echo "  gunzip < $BACKUP_PATH/${BACKUP_NAME}_database.sql.gz | mysql -u $DB_USER -p $DB_NAME"
echo ""
echo -e "${YELLOW}Файлы:${NC}"
echo "  tar -xzf $BACKUP_PATH/${BACKUP_NAME}_files.tar.gz -C $SITE_PATH"
echo ""

# Опция для загрузки бэкапа на удаленный сервер (опционально)
echo -e "${YELLOW}Хотите загрузить бэкап на удаленный сервер? (y/n)${NC}"
read -r UPLOAD_CHOICE

if [ "$UPLOAD_CHOICE" = "y" ] || [ "$UPLOAD_CHOICE" = "Y" ]; then
    read -p "Введите адрес удаленного сервера (user@host): " REMOTE_SERVER
    read -p "Введите путь на удаленном сервере: " REMOTE_PATH
    
    echo -e "${YELLOW}Загрузка бэкапа на удаленный сервер...${NC}"
    if scp "$BACKUP_PATH/${BACKUP_NAME}_full.tar.gz" "$REMOTE_SERVER:$REMOTE_PATH/"; then
        echo -e "${GREEN}  ✅ Бэкап успешно загружен на удаленный сервер${NC}"
    else
        echo -e "${RED}  ❌ Ошибка при загрузке на удаленный сервер${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Готово! Резервная копия создана успешно.${NC}"
echo ""

