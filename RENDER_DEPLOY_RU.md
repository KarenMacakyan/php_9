# 🎨 Развертывание QloApps на Render.com

## Что такое Render?

**Render.com** - современная платформа для деплоя, как Vercel/Railway, но с поддержкой PHP!

**Преимущества**:
- ✅ **Бесплатный тариф** навсегда
- ✅ Деплой прямо из **GitHub**
- ✅ Поддержка **PHP 8.x**
- ✅ Встроенная **MySQL база данных**
- ✅ Бесплатный **SSL сертификат**
- ✅ Автоматические деплои при push
- ✅ Docker поддержка

**Ограничения бесплатного тарифа**:
- ⚠️ Сервисы "засыпают" после 15 минут неактивности
- ⚠️ Первый запрос после сна - медленный (холодный старт ~30 сек)
- ⚠️ 750 часов/месяц бесплатно (достаточно для тестирования)

---

## 🚀 Быстрый старт

### Шаг 1: Подготовка (уже сделано!)

Файлы `render.yaml` и `Dockerfile` уже созданы в проекте ✅

### Шаг 2: Регистрация на Render

1. **Откройте**: https://render.com
2. **Нажмите**: "Get Started" или "Sign Up"
3. **Войдите через GitHub**:
   - Авторизуйте Render доступ к вашим репозиториям

### Шаг 3: Создание Web Service

#### Автоматический способ (через render.yaml):

1. **В Render Dashboard нажмите**: "New +"
2. **Выберите**: "Blueprint"
3. **Подключите репозиторий**: `KarenMacakyan/php_9`
4. **Render автоматически**:
   - Обнаружит `render.yaml`
   - Создаст Web Service
   - Создаст MySQL базу данных
   - Настроит переменные окружения

#### Ручной способ:

1. **New +** → **Web Service**
2. **Connect Repository**: выберите `KarenMacakyan/php_9`
3. **Настройки**:
   ```
   Name: qloapps
   Environment: Docker
   Branch: main
   Dockerfile Path: ./Dockerfile
   Plan: Free
   ```
4. **Create Web Service**

### Шаг 4: Добавление MySQL базы данных

1. **New +** → **MySQL**
2. **Настройки**:
   ```
   Name: qloapps-db
   Database: qloapps
   User: qloapps_user
   Plan: Free
   ```
3. **Create Database**

### Шаг 5: Настройка переменных окружения

1. **Откройте Web Service** (qloapps)
2. **Environment** → **Add Environment Variable**
3. **Добавьте переменные** из MySQL:

Откройте MySQL сервис → **Connect** → скопируйте данные:

```
DB_HOST=<Internal Database URL>
DB_PORT=3306
DB_NAME=qloapps
DB_USER=qloapps_user
DB_PASSWORD=<password>
```

Или используйте одну переменную:
```
DATABASE_URL=mysql://qloapps_user:password@host:3306/qloapps
```

### Шаг 6: Деплой

1. **Render автоматически задеплоит** после настройки
2. **Или вручную**: Manual Deploy → Deploy latest commit
3. **Дождитесь завершения** (3-5 минут первый раз)

### Шаг 7: Получите URL

1. **После деплоя** в верхней части страницы будет URL:
   ```
   https://qloapps-xxxx.onrender.com
   ```
2. **Откройте установщик**:
   ```
   https://qloapps-xxxx.onrender.com/install/
   ```

### Шаг 8: Установка QloApps

1. Откройте `/install/`
2. Выберите язык
3. При настройке БД используйте данные из Шага 5
4. Завершите установку

---

## 📊 Сравнение платформ

| Платформа | PHP Support | MySQL | Бесплатно | GitHub Deploy | Холодный старт |
|-----------|-------------|-------|-----------|---------------|----------------|
| **Render** | ✅ Да | ✅ Да | ✅ 750ч/мес | ✅ Да | ⚠️ 30 сек |
| **Railway** | ✅ Да | ✅ Да | ✅ $5/мес | ✅ Да | ⚡ Нет |
| **Vercel** | ❌ Нет | ❌ Нет | ✅ Да | ✅ Да | - |
| **Fly.io** | ✅ Да | ⚠️ PostgreSQL | ✅ Лимиты | ✅ Да | ⚡ Нет |

---

## 💡 Советы по использованию

### Избежать засыпания сервиса:

#### 1. UptimeRobot (Бесплатный мониторинг)
```
Сайт: https://uptimerobot.com
Настройка: Ping каждые 5 минут
Результат: Сервис не заснёт
```

#### 2. Cron-job.org
```
Сайт: https://cron-job.org
Настройка: HTTP запрос каждые 10 минут
```

### Оптимизация Docker образа:

В `Dockerfile` уже оптимизировано:
- ✅ Multi-stage build не нужен (простое PHP приложение)
- ✅ Кэширование слоев
- ✅ Минимальный размер

---

## 🔧 Решение проблем

### Проблема: "Build failed"

**Проверьте Dockerfile**:
```bash
# Локально протестируйте
docker build -t qloapps .
docker run -p 8080:80 qloapps
```

### Проблема: "Database connection failed"

**Решение**:
1. Проверьте Environment Variables
2. Используйте Internal Database URL (не External)
3. Убедитесь что MySQL сервис запущен

### Проблема: "500 Internal Server Error"

**Проверьте логи**:
- Render Dashboard → Logs
- Ищите PHP ошибки

---

## 🆙 Апгрейд на платный план

**Если нужна постоянная работа без засыпания**:

**Starter Plan** - $7/месяц:
- ✅ Без засыпания
- ✅ Больше ресурсов
- ✅ Приоритетная поддержка

---

## 🔄 Автоматические обновления

После настройки каждый `git push` автоматически деплоится:

```bash
# На вашем компьютере
git add .
git commit -m "Update QloApps"
git push

# Render автоматически задеплоит
```

---

## 📝 Файлы конфигурации

### render.yaml
Автоматически создаёт:
- Web Service
- MySQL Database
- Переменные окружения

### Dockerfile
Настраивает:
- PHP 8.2 с Apache
- Все необходимые расширения
- Права доступа к файлам
- PHP конфигурацию

---

## 🌐 Кастомный домен

1. **Settings** → **Custom Domain**
2. **Add Custom Domain**: введите ваш домен
3. **Настройте DNS** (Render покажет инструкции):
   ```
   Type: CNAME
   Name: @
   Value: your-app.onrender.com
   ```

---

## ✅ Контрольный список

- [ ] Аккаунт Render создан
- [ ] Репозиторий подключен
- [ ] Web Service создан
- [ ] MySQL база добавлена
- [ ] Переменные окружения настроены
- [ ] Приложение задеплоено
- [ ] QloApps установлен
- [ ] Папка install удалена
- [ ] SSL работает

---

## 🔗 Полезные ссылки

- 🎨 **Render Dashboard**: https://dashboard.render.com
- 📚 **Render Docs**: https://render.com/docs
- 💬 **Community**: https://community.render.com
- 📦 **GitHub**: https://github.com/KarenMacakyan/php_9

---

## ❓ FAQ

### Q: Бесплатно навсегда?
**A**: Да, 750 часов/месяц бесплатно (достаточно для 1 проекта)

### Q: Что такое "холодный старт"?
**A**: После 15 мин неактивности сервис засыпает. Первый запрос его будит (~30 сек).

### Q: Как избежать засыпания?
**A**: Используйте UptimeRobot для пинга каждые 5 минут (бесплатно).

### Q: Можно для production?
**A**: Для небольших проектов - да. Для больших - лучше платный план ($7/мес).

---

**Render - отличная альтернатива Railway! Попробуйте! 🚀**

