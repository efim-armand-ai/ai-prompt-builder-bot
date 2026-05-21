# AI Prompt Builder Bot — Инструкция по запуску

## Шаг 1 — Получи Telegram Bot Token

1. Открой Telegram → найди @BotFather
2. Напиши `/newbot`
3. Придумай имя: `AI Prompt Builder`
4. Придумай username: `ai_prompt_builder_bot` (или любой свободный)
5. Скопируй токен вида `7123456789:AAF...`

## Шаг 2 — Получи Anthropic API Key

1. Открой **console.anthropic.com**
2. Settings → API Keys → Create Key
3. Скопируй ключ вида `sk-ant-...`
4. Пополни баланс — минимум $5

## Шаг 3 — Узнай свой Telegram User ID

1. Найди в Telegram бота @userinfobot
2. Напиши ему `/start`
3. Он ответит твой ID вида `123456789`

## Шаг 4 — Деплой на Railway

1. Зайди на **railway.app** → Sign up with GitHub
2. New Project → Deploy from GitHub repo
   (или: New Project → Empty Project)
3. Если Empty Project:
   - Add Service → GitHub Repo
   - Загрузи все файлы из папки `bot/` + оба SKILL файла в один репозиторий
4. В проекте Railway → Variables → добавь три переменные:

```
TELEGRAM_TOKEN    = 7123456789:AAF...твой токен...
ANTHROPIC_API_KEY = sk-ant-...твой ключ...
ALLOWED_USER_ID   = 123456789  (твой Telegram ID)
```

5. Railway автоматически деплоит → через 1-2 минуты бот онлайн

## Структура файлов в репозитории

```
/
├── bot.py
├── requirements.txt
├── railway.toml
├── SKILL.md       ← полная версия
└── SKILL_LITE.md  ← lite версия
```

## Команды бота

| Команда | Действие |
|---|---|
| `/start` | Показать кнопки выбора режима |
| `/pro` | Переключить на PRO режим |
| `/lite` | Переключить на LITE режим |
| `/clear` | Очистить историю чата |
| `/status` | Показать текущий режим и длину истории |

## Обновление SKILL

Когда выходит новая версия SKILL.md:
1. Замени файл `SKILL.md` в репозитории
2. Railway автоматически передеплоит (или нажми Redeploy вручную)
3. Готово — бот сразу работает с новой версией

## Стоимость

- Railway: бесплатный tier 500 часов/месяц (хватит на личное использование)
- Anthropic API: ~$0.003-0.01 за сообщение в PRO, ~$0.001-0.003 в LITE
- При 50 сообщениях в день: ~$5-15 в месяц

## Если что-то не работает

1. Railway → твой проект → Deployments → смотри логи
2. Частые ошибки:
   - `TELEGRAM_TOKEN invalid` — проверь токен, нет лишних пробелов
   - `AuthenticationError` — проверь Anthropic API key и баланс
   - `Forbidden` — бот заблокирован, напиши ему /start первым
