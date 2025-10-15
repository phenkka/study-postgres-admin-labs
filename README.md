## Запуск проекта с Docker

Для запуска проекта выполните следующие шаги:

### 1. Создайте файл `.env`

Создайте файл `.env` в той же директории, где находится `docker-compose.yml`, и добавьте в него следующие переменные:

```env
# Настройки PostgreSQL
POSTGRES_DB=your_database_name
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_password
POSTGRES_HOST=your_host
POSTGRES_PORT=your_port

# Настройки pgAdmin
PGADMIN_DEFAULT_EMAIL=your_email@example.com
PGADMIN_DEFAULT_PASSWORD=your_pgadmin_password
```

Важно:

Последние две строки (PGADMIN_DEFAULT_EMAIL и PGADMIN_DEFAULT_PASSWORD) используются для входа в веб-интерфейс pgAdmin по адресу http://localhost:5050/.
Первые пять строк нужны для подключения к серверу PostgreSQL внутри pgAdmin. (для поднятия контейнеров я использовал приложение Docker Desktop, придется скачать с официального сайта)

### 2. Поднимите контейнеры

Находясь в директории с docker-compose.yml, выполните команду:

```docker-compose up --build```

### 3. Проверка

Если контейнеры поднялись без ошибок, проект готов к работе и можно приступать к выполнению заданий.
