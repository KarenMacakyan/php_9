#!/bin/bash

# Скрипт для установки правильных прав доступа к файлам QloApps
# Использование: sudo ./set_permissions.sh [путь к QloApps]

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Определение пути к QloApps
if [ -n "$1" ]; then
    QLOAPPS_PATH="$1"
else
    QLOAPPS_PATH="/var/www/html"
fi

# Проверка существования директории
if [ ! -d "$QLOAPPS_PATH" ]; then
    echo -e "${RED}Ошибка: Директория $QLOAPPS_PATH не найдена${NC}"
    exit 1
fi

# Проверка наличия конфигурационного файла QloApps
if [ ! -f "$QLOAPPS_PATH/config/config.inc.php" ]; then
    echo -e "${RED}Ошибка: Это не директория QloApps${NC}"
    exit 1
fi

echo "========================================="
echo "  Установка прав доступа для QloApps"
echo "========================================="
echo ""
echo -e "${YELLOW}Путь к QloApps: ${QLOAPPS_PATH}${NC}"
echo ""

# Определение пользователя веб-сервера
WEB_USER="www-data"
if [ -f /etc/redhat-release ]; then
    WEB_USER="apache"
fi

# Проверка существования пользователя
if ! id "$WEB_USER" &>/dev/null; then
    echo -e "${RED}Пользователь $WEB_USER не найден${NC}"
    echo "Введите имя пользователя веб-сервера:"
    read WEB_USER
fi

echo -e "${YELLOW}Пользователь веб-сервера: ${WEB_USER}${NC}"
echo ""

# Установка владельца
echo -e "${YELLOW}Установка владельца файлов...${NC}"
chown -R $WEB_USER:$WEB_USER "$QLOAPPS_PATH"

# Установка прав на директории (755)
echo -e "${YELLOW}Установка прав на директории (755)...${NC}"
find "$QLOAPPS_PATH" -type d -exec chmod 755 {} \;

# Установка прав на файлы (644)
echo -e "${YELLOW}Установка прав на файлы (644)...${NC}"
find "$QLOAPPS_PATH" -type f -exec chmod 644 {} \;

# Установка специальных прав для записываемых директорий (777)
echo -e "${YELLOW}Установка прав для записываемых директорий (777)...${NC}"

WRITABLE_DIRS=(
    "config"
    "cache"
    "cache/cachefs"
    "cache/purifier"
    "cache/push"
    "cache/sandbox"
    "cache/smarty/cache"
    "cache/smarty/compile"
    "cache/tcpdf"
    "log"
    "img"
    "img/p"
    "img/c"
    "img/cms"
    "img/co"
    "img/genders"
    "img/l"
    "img/m"
    "img/os"
    "img/s"
    "img/scenes"
    "img/st"
    "img/su"
    "img/t"
    "img/tmp"
    "mails"
    "modules"
    "themes/hotel-reservation-theme/cache"
    "translations"
    "upload"
    "download"
    "admin/autoupgrade"
    "admin/backups"
    "admin/import"
    "admin/export"
)

for dir in "${WRITABLE_DIRS[@]}"; do
    if [ -d "$QLOAPPS_PATH/$dir" ]; then
        chmod 777 "$QLOAPPS_PATH/$dir"
        echo -e "  ✅ $dir"
    else
        # Создать директорию если не существует
        mkdir -p "$QLOAPPS_PATH/$dir"
        chmod 777 "$QLOAPPS_PATH/$dir"
        chown $WEB_USER:$WEB_USER "$QLOAPPS_PATH/$dir"
        echo -e "  ✅ $dir ${YELLOW}(создана)${NC}"
    fi
done

# Защита конфигурационных файлов
echo ""
echo -e "${YELLOW}Защита конфигурационных файлов...${NC}"

if [ -f "$QLOAPPS_PATH/config/settings.inc.php" ]; then
    chmod 644 "$QLOAPPS_PATH/config/settings.inc.php"
    echo -e "  ✅ config/settings.inc.php (644)"
fi

if [ -f "$QLOAPPS_PATH/.htaccess" ]; then
    chmod 644 "$QLOAPPS_PATH/.htaccess"
    echo -e "  ✅ .htaccess (644)"
fi

if [ -f "$QLOAPPS_PATH/robots.txt" ]; then
    chmod 644 "$QLOAPPS_PATH/robots.txt"
    echo -e "  ✅ robots.txt (644)"
fi

# Установка прав на index.php файлы
echo ""
echo -e "${YELLOW}Установка прав на index.php файлы...${NC}"
find "$QLOAPPS_PATH" -name "index.php" -exec chmod 644 {} \;
echo -e "  ✅ Все index.php файлы"

# Проверка и вывод итоговой информации
echo ""
echo -e "${GREEN}========================================="
echo -e "  Установка прав завершена!"
echo -e "=========================================${NC}"
echo ""
echo -e "${GREEN}Итоговая информация:${NC}"
echo -e "  Владелец: ${WEB_USER}:${WEB_USER}"
echo -e "  Права на директории: 755"
echo -e "  Права на файлы: 644"
echo -e "  Права на записываемые директории: 777"
echo ""

# Проверка критичных директорий
echo -e "${YELLOW}Проверка критичных директорий:${NC}"

check_dir() {
    local dir=$1
    if [ -d "$QLOAPPS_PATH/$dir" ] && [ -w "$QLOAPPS_PATH/$dir" ]; then
        echo -e "  ✅ $dir - доступна для записи"
    else
        echo -e "  ❌ $dir - НЕ доступна для записи"
    fi
}

check_dir "cache"
check_dir "log"
check_dir "img"
check_dir "modules"
check_dir "config"

echo ""
echo -e "${YELLOW}Рекомендации по безопасности:${NC}"
echo "  1. После установки QloApps измените права на config/ на 755:"
echo "     chmod 755 $QLOAPPS_PATH/config"
echo ""
echo "  2. После установки измените права на settings.inc.php на 444:"
echo "     chmod 444 $QLOAPPS_PATH/config/settings.inc.php"
echo ""
echo "  3. Удалите папку install после установки:"
echo "     rm -rf $QLOAPPS_PATH/install"
echo ""
echo "  4. Переименуйте папку admin для безопасности"
echo ""

