# 🚂 Развертывание QloApps на Railway

## Что такое Railway?

**Railway** - современная платформа для деплоя приложений с:
- ✅ Бесплатным тарифом ($5 кредитов/месяц)
- ✅ Автоматическим деплоем из GitHub
- ✅ Встроенной базой данных MySQL
- ✅ Бесплатным SSL сертификатом

## 📋 Требования

- ✅ GitHub аккаунт (уже есть)
- ✅ Railway аккаунт (создадим)
- ⚠️ Кредитная карта для верификации (можно без нее, но с ограничениями)

---

## 🚀 Пошаговая инструкция

### Шаг 1: Создание аккаунта Railway

1. **Откройте**: https://railway.app
2. **Нажмите**: "Start a New Project" или "Login"
3. **Войдите через GitHub**:
   - Нажмите "Login with GitHub"
   - Авторизуйте Railway доступ к GitHub

### Шаг 2: Создание нового проекта

1. **Нажмите**: "+ New Project"
2. **Выберите**: "Deploy from GitHub repo"
3. **Выберите репозиторий**: `KarenMacakyan/php_9`
4. **Нажмите**: "Deploy Now"

Railway начнет деплой, но пока **будет ошибка** (нет базы данных).

### Шаг 3: Добавление MySQL базы данных

1. **В проекте нажмите**: "+ New"
2. **Выберите**: "Database" → "Add MySQL"
3. Railway автоматически создаст MySQL базу данных
4. **Получите данные подключения**:
   - Откройте созданный MySQL сервис
   - Перейдите в "Variables"
   - Скопируйте:
     - `MYSQL_URL` (полный URL подключения)
     - `MYSQL_HOST`
     - `MYSQL_PORT`
     - `MYSQL_USER`
     - `MYSQL_PASSWORD`
     - `MYSQL_DATABASE`

### Шаг 4: Настройка переменных окружения

1. **Откройте сервис QloApps** (не MySQL)
2. **Перейдите**: Settings → Variables
3. **Добавьте переменные**:

```
DB_SERVER=<MYSQL_HOST из шага 3>
DB_PORT=<MYSQL_PORT из шага 3>
DB_NAME=<MYSQL_DATABASE из шага 3>
DB_USER=<MYSQL_USER из шага 3>
DB_PASSWORD=<MYSQL_PASSWORD из шага 3>
```

Или проще - добавьте одну переменную:
```
DATABASE_URL=<MYSQL_URL из шага 3>
```

### Шаг 5: Настройка домена

1. **В сервисе QloApps**: Settings → Networking
2. **Railway предоставит домен**: `your-app.up.railway.app`
3. **Или добавьте свой домен**:
   - Custom Domain → Add Domain
   - Введите ваш домен
   - Настройте DNS записи (Railway покажет инструкции)

### Шаг 6: Редеплой

1. **Нажмите**: "Deployments" → последний деплой → "⋮" → "Redeploy"
2. **Или**: Settings → "Redeploy"

Railway перезапустит приложение с новыми настройками.

### Шаг 7: Установка QloApps

1. **Откройте ваш домен**: `https://your-app.up.railway.app/install/`
2. **Следуйте инструкциям установщика**:
   - Выберите язык
   - Примите лицензию
   - Введите данные магазина
   - **База данных** (используйте данные из Шага 3):
     ```
     Database server: <MYSQL_HOST>
     Database name: <MYSQL_DATABASE>
     Database user: <MYSQL_USER>
     Database password: <MYSQL_PASSWORD>
     Database port: <MYSQL_PORT>
     ```
3. **Дождитесь завершения установки**

### Шаг 8: Безопасность (ВАЖНО!)

После установки **обязательно**:

1. **Удалите папку install**:
   - К сожалению, на Railway нет прямого доступа к файлам
   - **Решение**: Добавьте в `.gitignore` и сделайте новый деплой
   
   ```bash
   # На вашем компьютере
   echo "install/" >> .gitignore
   echo "install-dev/" >> .gitignore
   git add .gitignore
   git commit -m "Remove install folders for security"
   git push
   ```

2. **Переименуйте admin** (сложнее на Railway, лучше использовать .htaccess защиту)

---

## ⚙️ Альтернативный метод: Railway CLI

Если предпочитаете командную строку:

### 1. Установите Railway CLI
```bash
# macOS
brew install railway

# Windows
scoop install railway

# Linux/Mac (альтернатива)
sh -c "$(curl -sSL https://raw.githubusercontent.com/railwayapp/cli/master/install.sh)"
```

### 2. Войдите
```bash
railway login
```

### 3. Инициализируйте проект
```bash
cd /Users/macbook/Desktop/QloApps-develop
railway init
```

### 4. Добавьте MySQL
```bash
railway add --plugin mysql
```

### 5. Задеплойте
```bash
railway up
```

### 6. Откройте приложение
```bash
railway open
```

---

## 💰 Бесплатный лимит Railway

**Hobby Plan (Бесплатно)**:
- ✅ $5 кредитов каждый месяц
- ✅ ~500 часов работы в месяц (для небольших проектов достаточно)
- ✅ 1 GB RAM
- ✅ 1 GB диск
- ❌ Требуется верификация карты (можно виртуальной)

**Как работают кредиты**:
- Приложение потребляет ~$0.01/час
- $5 = ~500 часов = 20 дней непрерывной работы
- Если проект спит (нет трафика) - не тратятся

**Совет**: Настройте автоматическое выключение:
- Settings → Sleep when inactive
- Приложение будет засыпать без активности

---

## 🔧 Решение проблем

### Проблема 1: "No version available for php"

**Решение**: Обновлен `composer.json` (уже исправлено)
```json
"require": {
    "php": "^8.1 || ^8.2"
}
```

### Проблема 2: "Database connection failed"

**Решение**: Проверьте переменные окружения
1. Railway → Service → Variables
2. Убедитесь что все переменные БД добавлены
3. Redeploy

### Проблема 3: "500 Internal Server Error"

**Решение**: Проверьте логи
```bash
# CLI
railway logs

# Или в Dashboard: Deployments → View Logs
```

### Проблема 4: "Application not starting"

**Решение**: Проверьте Procfile и nixpacks.toml (уже настроены)

---

## 📊 Мониторинг

**В Railway Dashboard**:
- **Metrics**: CPU, RAM, Network usage
- **Logs**: Реалтайм логи приложения
- **Deployments**: История деплоев

---

## 🔄 Автоматические обновления

Railway автоматически деплоит при каждом push в main:

```bash
# На вашем компьютере
git add .
git commit -m "Update QloApps"
git push

# Railway автоматически задеплоит изменения
```

---

## 💡 Советы по оптимизации

### 1. Включите кэширование
После установки в админке:
- Расширенные параметры → Производительность
- Включите все виды кэша

### 2. Настройте CDN
Для статических файлов используйте Cloudflare (бесплатно):
- https://www.cloudflare.com

### 3. Оптимизируйте изображения
- Используйте WebP формат
- Сжимайте изображения перед загрузкой

---

## 🆚 Railway vs Другие платформы

| Платформа | Цена | Простота | База данных | SSL |
|-----------|------|----------|-------------|-----|
| **Railway** | $5/мес (free) | ⭐⭐⭐⭐⭐ | ✅ Встроенная | ✅ Авто |
| **Heroku** | $7/мес | ⭐⭐⭐⭐ | ❌ Платно | ✅ Авто |
| **InfinityFree** | Бесплатно | ⭐⭐⭐⭐⭐ | ✅ MySQL | ✅ Да |
| **DigitalOcean** | $4/мес | ⭐⭐ | ❌ Настройка | ❌ Настройка |

---

## 📝 Контрольный список

После успешного развертывания:

- [ ] ✅ Railway проект создан
- [ ] ✅ MySQL база добавлена
- [ ] ✅ Переменные окружения настроены
- [ ] ✅ Домен настроен
- [ ] ✅ QloApps установлен
- [ ] ✅ Папка install удалена (через .gitignore)
- [ ] ✅ Админ-панель защищена
- [ ] ✅ SSL работает
- [ ] ✅ Резервное копирование настроено

---

## 🔗 Полезные ссылки

- 🚂 [Railway Dashboard](https://railway.app/dashboard)
- 📚 [Railway Docs](https://docs.railway.app/)
- 💬 [Railway Discord](https://discord.gg/railway)
- 🐛 [GitHub Issues](https://github.com/KarenMacakyan/php_9/issues)

---

## ❓ FAQ

### Q: Нужна ли кредитная карта?
**A**: Желательно для получения $5 кредитов. Можно использовать виртуальную карту.

### Q: Хватит ли $5 в месяц?
**A**: Для небольшого проекта (до 1000 посетителей/день) - да.

### Q: Как добавить больше ресурсов?
**A**: Перейдите на Pro план ($20/месяц) для unlimited ресурсов.

### Q: Можно ли использовать для production?
**A**: Да, но рекомендуется Pro план для критичных проектов.

---

**Готово! Теперь ваш QloApps работает на Railway! 🎉**

Если возникнут проблемы, смотрите логи:
```bash
railway logs
```

Или откройте issue на GitHub: https://github.com/KarenMacakyan/php_9/issues

