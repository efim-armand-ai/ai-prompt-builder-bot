import os
import json
import logging
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    Application, CommandHandler, MessageHandler,
    CallbackQueryHandler, ContextTypes, filters
)
import anthropic
import base64
import httpx

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ── ENV VARS ──────────────────────────────────────────────
TELEGRAM_TOKEN = os.environ["TELEGRAM_TOKEN"]
ANTHROPIC_KEY   = os.environ["ANTHROPIC_API_KEY"]
ALLOWED_USER_ID = int(os.environ.get("ALLOWED_USER_ID", "0"))  # 0 = allow all

# ── LOAD SKILLS ───────────────────────────────────────────
def load_skill(filename: str) -> str:
    path = os.path.join(os.path.dirname(__file__), filename)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

SKILL_PRO  = load_skill("SKILL.md")
SKILL_LITE = load_skill("SKILL_LITE.md")

SYSTEM_BASE = """Ты AI коммерческий директор и промпт-инженер для AI видео генерации.
Всегда отвечай на русском языке. Промпты для Kling/Seedance/GPT Image пиши только на английском.
Следуй всем правилам из приложенного SKILL файла строго.

{skill}"""

# ── STATE PER USER ────────────────────────────────────────
# user_data keys: mode, history
MAX_HISTORY = 20  # max messages to keep in context

def get_mode(context: ContextTypes.DEFAULT_TYPE) -> str:
    return context.user_data.get("mode", "pro")

def get_system(context: ContextTypes.DEFAULT_TYPE) -> str:
    skill = SKILL_PRO if get_mode(context) == "pro" else SKILL_LITE
    return SYSTEM_BASE.format(skill=skill)

def get_history(context: ContextTypes.DEFAULT_TYPE) -> list:
    return context.user_data.setdefault("history", [])

def add_to_history(context, role: str, content):
    history = get_history(context)
    history.append({"role": role, "content": content})
    # trim oldest pairs keeping system intact
    while len(history) > MAX_HISTORY:
        history.pop(0)

# ── ANTHROPIC CALL ────────────────────────────────────────
async def call_claude(context: ContextTypes.DEFAULT_TYPE, user_content) -> str:
    client = anthropic.Anthropic(api_key=ANTHROPIC_KEY)
    add_to_history(context, "user", user_content)

    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=4096,
        system=get_system(context),
        messages=get_history(context),
    )
    reply = response.content[0].text
    add_to_history(context, "assistant", reply)
    return reply

# ── HELPERS ───────────────────────────────────────────────
def is_allowed(user_id: int) -> bool:
    return ALLOWED_USER_ID == 0 or user_id == ALLOWED_USER_ID

def mode_badge(mode: str) -> str:
    return "🔵 PRO" if mode == "pro" else "⚡ LITE"

# ── HANDLERS ──────────────────────────────────────────────
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        await update.message.reply_text("⛔ Доступ закрыт.")
        return

    keyboard = [
        [
            InlineKeyboardButton("🔵 PRO — Полный режим", callback_data="mode_pro"),
            InlineKeyboardButton("⚡ LITE — Быстрый режим", callback_data="mode_lite"),
        ]
    ]
    markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(
        "🎬 *AI Prompt Builder*\n\nВыбери режим работы:",
        parse_mode="Markdown",
        reply_markup=markup,
    )

async def mode_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    mode = "pro" if query.data == "mode_pro" else "lite"
    context.user_data["mode"] = mode
    context.user_data["history"] = []  # reset history on mode switch

    badge = mode_badge(mode)
    desc = (
        "Полный SKILL — все правила, форматы, архивы знаний.\nЛучшее качество промптов."
        if mode == "pro"
        else
        "Сжатый SKILL — основные правила без примеров.\nБыстрее, дешевле."
    )
    await query.edit_message_text(
        f"{badge} активен\n\n{desc}\n\nОтправь фото или опиши сцену — начнём.",
        parse_mode="Markdown",
    )

async def switch_mode(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Allow /pro and /lite commands"""
    if not is_allowed(update.effective_user.id):
        return
    cmd = update.message.text.lower().strip("/")
    mode = "pro" if cmd == "pro" else "lite"
    context.user_data["mode"] = mode
    context.user_data["history"] = []
    await update.message.reply_text(
        f"{mode_badge(mode)} активен. История сброшена.",
        parse_mode="Markdown",
    )

async def clear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return
    context.user_data["history"] = []
    await update.message.reply_text("🗑 История очищена. Начинаем заново.")

async def status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return
    mode = get_mode(context)
    history_len = len(get_history(context))
    await update.message.reply_text(
        f"*Режим:* {mode_badge(mode)}\n*Сообщений в истории:* {history_len}/{MAX_HISTORY}",
        parse_mode="Markdown",
    )

async def handle_text(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return

    user_text = update.message.text
    await update.message.chat.send_action("typing")

    try:
        reply = await call_claude(context, user_text)
        # Telegram max message length is 4096
        if len(reply) > 4000:
            for chunk in [reply[i:i+4000] for i in range(0, len(reply), 4000)]:
                await update.message.reply_text(chunk)
        else:
            await update.message.reply_text(reply)
    except Exception as e:
        logger.error(f"Claude error: {e}")
        await update.message.reply_text(f"⚠️ Ошибка: {e}")

async def handle_photo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return

    await update.message.chat.send_action("typing")

    try:
        # Get highest resolution photo
        photo = update.message.photo[-1]
        file = await context.bot.get_file(photo.file_id)

        # Download image bytes
        async with httpx.AsyncClient() as client:
            resp = await client.get(file.file_path)
            image_bytes = resp.content

        image_b64 = base64.standard_b64encode(image_bytes).decode("utf-8")

        # Build content with image + caption
        caption = update.message.caption or ""
        user_content = [
            {
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": "image/jpeg",
                    "data": image_b64,
                },
            },
            {
                "type": "text",
                "text": caption if caption else "Загружен референс-кадр. Задай уточняющие вопросы по workflow.",
            },
        ]

        reply = await call_claude(context, user_content)

        if len(reply) > 4000:
            for chunk in [reply[i:i+4000] for i in range(0, len(reply), 4000)]:
                await update.message.reply_text(chunk)
        else:
            await update.message.reply_text(reply)

    except Exception as e:
        logger.error(f"Photo error: {e}")
        await update.message.reply_text(f"⚠️ Ошибка при обработке фото: {e}")

# ── MAIN ──────────────────────────────────────────────────
def main():
    app = Application.builder().token(TELEGRAM_TOKEN).build()

    app.add_handler(CommandHandler("start",  start))
    app.add_handler(CommandHandler("pro",    switch_mode))
    app.add_handler(CommandHandler("lite",   switch_mode))
    app.add_handler(CommandHandler("clear",  clear))
    app.add_handler(CommandHandler("status", status))
    app.add_handler(CallbackQueryHandler(mode_callback, pattern="^mode_"))
    app.add_handler(MessageHandler(filters.PHOTO, handle_photo))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text))

    logger.info("Bot started")
    app.run_polling(drop_pending_updates=True)

if __name__ == "__main__":
    main()
