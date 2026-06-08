import os
import re
import logging
import base64
import httpx
import anthropic

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    Application,
    CommandHandler,
    MessageHandler,
    CallbackQueryHandler,
    ContextTypes,
    filters,
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ENV VARS
TELEGRAM_TOKEN = os.environ["TELEGRAM_TOKEN"]
ANTHROPIC_KEY = os.environ["ANTHROPIC_API_KEY"]
ALLOWED_USER_ID = int(os.environ.get("ALLOWED_USER_ID", "0"))

# LOAD SKILLS
def load_skill(filename):
    path = os.path.join(os.path.dirname(__file__), filename)
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

SKILL_PRO = load_skill("SKILL.md")
SKILL_LITE = load_skill("SKILL_LITE.md")

SYSTEM_PRO = (
    "Ty AI kommerchesky direktor i prompt-inzhener dlya AI video generatsii.\n"
    "Vsegda otvechay na russkom yazyke. "
    "Prompty dlya Kling/Seedance/GPT Image pishi tolko na angliyskom.\n"
    "Sleduy vsem pravilam iz SKILL fayла strogo.\n\n"
    "VAZhNO - formatirovanie dlya Telegram:\n"
    "- NE ispolzuy ## ### zagolovki\n"
    "- Vmesto ## Zagolovok pishi: *Zagolovok* (zhirny cherez zvezdochki)\n"
    "- Ispolzuy *zhirny* dlya nazvaniy sektsiy\n"
    "- Ispolzuy obychnye defisy - dlya spiskov\n"
    "- Razdelyay sektsii pustoy strokoy\n\n"
    "{skill}"
)

SYSTEM_LITE = SYSTEM_PRO

MAX_HISTORY = 20


def get_mode(context):
    return context.user_data.get("mode", "pro")


def get_system(context):
    skill = SKILL_PRO if get_mode(context) == "pro" else SKILL_LITE
    template = SYSTEM_PRO if get_mode(context) == "pro" else SYSTEM_LITE
    return template.format(skill=skill)


def get_history(context):
    return context.user_data.setdefault("history", [])


def add_to_history(context, role, content):
    history = get_history(context)
    history.append({"role": role, "content": content})
    while len(history) > MAX_HISTORY:
        history.pop(0)


def is_allowed(user_id):
    return ALLOWED_USER_ID == 0 or user_id == ALLOWED_USER_ID


def mode_badge(mode):
    return "PRO" if mode == "pro" else "LITE"


def clean_for_telegram(text):
    text = re.sub(r"^#{1,3}\s+(.+)$", r"*\1*", text, flags=re.MULTILINE)
    text = re.sub(r"^-{3,}$", r"─────────────────", text, flags=re.MULTILINE)
    return text


async def call_claude(context, user_content):
    client = anthropic.Anthropic(api_key=ANTHROPIC_KEY)
    add_to_history(context, "user", user_content)

    response = client.messages.create(
        model="claude-sonnet-4-5",
        max_tokens=4096,
        system=get_system(context),
        messages=get_history(context),
    )
    reply = response.content[0].text
    add_to_history(context, "assistant", reply)
    return reply


async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        await update.message.reply_text("Access denied.")
        return

    keyboard = [
        [
            InlineKeyboardButton("PRO - Polny rezhim", callback_data="mode_pro"),
            InlineKeyboardButton("LITE - Bystry rezhim", callback_data="mode_lite"),
        ]
    ]
    markup = InlineKeyboardMarkup(keyboard)
    await update.message.reply_text(
        "*AI Prompt Builder*\n\nVyberi rezhim raboty:",
        parse_mode="Markdown",
        reply_markup=markup,
    )


async def mode_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    mode = "pro" if query.data == "mode_pro" else "lite"
    context.user_data["mode"] = mode
    context.user_data["history"] = []

    badge = mode_badge(mode)
    if mode == "pro":
        desc = "Polny SKILL - vse pravila, formaty, arkhivy znany.\nLuchshee kachestvo promptov."
    else:
        desc = "Szhatyy SKILL - osnovnye pravila bez primerov.\nBystree, deshevle."

    await query.edit_message_text(
        f"*{badge} aktiven*\n\n{desc}\n\nOtprav foto ili opishi stsenu - nachnyom.",
        parse_mode="Markdown",
    )


async def switch_mode(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return
    cmd = update.message.text.lower().strip("/")
    mode = "pro" if cmd == "pro" else "lite"
    context.user_data["mode"] = mode
    context.user_data["history"] = []
    await update.message.reply_text(
        f"*{mode_badge(mode)} aktiven.* Istoriya sbroshena.",
        parse_mode="Markdown",
    )


async def clear(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return
    context.user_data["history"] = []
    await update.message.reply_text("Istoriya ochishchena. Nachinaem zanovo.")


async def status(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return
    mode = get_mode(context)
    history_len = len(get_history(context))
    await update.message.reply_text(
        f"*Rezhim:* {mode_badge(mode)}\n*Soobshcheniy v istorii:* {history_len}/{MAX_HISTORY}",
        parse_mode="Markdown",
    )


async def handle_text(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return

    await update.message.chat.send_action("typing")

    try:
        reply = await call_claude(context, update.message.text)
        reply = clean_for_telegram(reply)
        if len(reply) > 4000:
            for chunk in [reply[i : i + 4000] for i in range(0, len(reply), 4000)]:
                await update.message.reply_text(chunk)
        else:
            await update.message.reply_text(reply)
    except Exception as e:
        logger.error(f"Claude error: {e}")
        await update.message.reply_text(f"Oshibka: {e}")


async def handle_photo(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if not is_allowed(update.effective_user.id):
        return

    await update.message.chat.send_action("typing")

    try:
        photo = update.message.photo[-1]
        file = await context.bot.get_file(photo.file_id)

        async with httpx.AsyncClient() as client:
            resp = await client.get(file.file_path)
            image_bytes = resp.content

        image_b64 = base64.standard_b64encode(image_bytes).decode("utf-8")
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
                "text": caption if caption else "Zagruzhen referens-kadr. Zadaj utochnyayushchie voprosy po workflow.",
            },
        ]

        reply = await call_claude(context, user_content)
        reply = clean_for_telegram(reply)

        if len(reply) > 4000:
            for chunk in [reply[i : i + 4000] for i in range(0, len(reply), 4000)]:
                await update.message.reply_text(chunk)
        else:
            await update.message.reply_text(reply)

    except Exception as e:
        logger.error(f"Photo error: {e}")
        await update.message.reply_text(f"Oshibka pri obrabotke foto: {e}")


def main():
    app = Application.builder().token(TELEGRAM_TOKEN).build()

    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("pro", switch_mode))
    app.add_handler(CommandHandler("lite", switch_mode))
    app.add_handler(CommandHandler("clear", clear))
    app.add_handler(CommandHandler("status", status))
    app.add_handler(CallbackQueryHandler(mode_callback, pattern="^mode_"))
    app.add_handler(MessageHandler(filters.PHOTO, handle_photo))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text))

    logger.info("Bot started")
    app.run_polling(drop_pending_updates=True)


if __name__ == "__main__":
    main()
