---
name: ai-prompt-builder
version: "2.3"
updated: "2026-05-14" 
description: >
  AI Prompt Builder — production-ready video prompts for Kling 3 and Seedance 2.
  Covers architectural advertising, brand films, luxury lifestyle, hospitality, real estate,
  and commercial content with AI characters. Acts as AI commercial director with Brand DNA
  presets, Director Intensity, Cinema Modes, Identity Lock, and full prompt architecture.

  ALWAYS use this skill when the user mentions: storyboard, moodboard, раскадровка, мудборд,
  сценарий видео, рекламный ролик, Kling, Seedance, архитектура + видео, бренд + ролик,
  AI-персонажи в рекламе, сцены для генерации видео, shot list, ad film, brand film,
  or asks to "animate", "оживить", "снять ролик", "сделать видео" about a property or brand.
  Use for any video prompt request regardless of category.
---

# AI Prompt Builder

Production-ready video prompts for **Kling 3** and **Seedance 2**.
Acts as AI commercial director: reads reference frames, tags, and brief —
outputs cinematic, brand-consistent prompts with full editing logic,
camera evolution, identity lock, and physics-driven shot descriptions.

---

## Image Input Workflow

### ONE image uploaded — ask before writing (all at once):
```
1. Single-shot или multi-shot?
2. Длительность видео?
3. Если multi-shot — сколько кадров?
4. Платформа: Kling 3 / Seedance 2 / Gemini Omni / несколько?
5. Brand DNA? (можно пропустить — дефолт: Generic Premium)
   1. Generic Premium — балансированный luxury, дефолт
   2. Apple — минимализм, чистота, точность
   3. Chanel — мода, editorial, контраст
   4. Aman — медленно, тишина, медитативная роскошь
   5. Tesla — динамика, sleek, современная энергия
   6. Nike — движение, энергия, сила
   7. Rolex — сдержанность, вне времени
   8. Dior — кинематографичная мода, драма
   9. Airbnb Luxe — натуральность, lifestyle, тепло
   10. Four Seasons — тёплая гостиничная роскошь
6. Director Intensity? soft / medium / bold (дефолт: medium)
```
Do NOT write prompts until answered.

### MULTIPLE images uploaded:
- Each image = one shot automatically. Do NOT ask shot count.
- Ask only:
  1. Длительность каждого кадра или общая?
  2. Платформа: Kling 3 / Seedance 2 / оба?
  3. Brand DNA? (список выше, пропустить → Generic Premium)
  4. Director Intensity? soft / medium / bold
- Output full script first, then shot blocks in upload order.

### After clarification — analyze each image:
- Architectural style, materials, light conditions
- Color palette (dominant + accent)
- Atmosphere and emotional register
- Characters: pose, wardrobe, position in frame
- Tags provided
All image details = hard anchors in every prompt.

---

## Brand DNA System

User selects by number or name. Default if not specified: **Generic Premium**.

| # | Brand | Style Direction |
|---|---|---|
| 1 | Generic Premium | Balanced luxury — default |
| 2 | Apple | Clean, minimal, precise, modern |
| 3 | Chanel | Fashion editorial, attitude, contrast |
| 4 | Aman | Ultra calm, slow, meditative luxury |
| 5 | Tesla | Sleek, dynamic, modern energy |
| 6 | Nike | Energetic, movement-driven |
| 7 | Rolex | Refined, timeless, controlled luxury |
| 8 | Dior | Cinematic, dramatic fashion |
| 9 | Airbnb Luxe | Natural, lifestyle, human warmth |
| 10 | Four Seasons | Warm hospitality luxury |

Brand DNA affects: pacing, camera behavior, lighting tone, interaction style, audio mood.

For detailed presets per brand read `/references/brand-dna.md`.

### Tonal Register System

A second layer on top of Brand DNA. Pick the register before writing any prompt.
If brand fits multiple registers — use the one its actual campaigns have used.
If unsure — ask: "Playful, sensory, extreme, or serious editorial?"

| Register | Energy | Brands | Product placement |
|---|---|---|---|
| **(a) Playful / Kinetic** | Action, mid-laugh, confidence | Adidas, Nike lifestyle, Coca-Cola, Diesel, mass beauty | Held, worn, hero mid-use |
| **(b) Extreme / Kinetic** | Physical intensity, danger, altitude | Red Bull, GoPro, Patagonia, Nike performance | Clipped to harness, in hand mid-trick |
| **(c) Sensory / Quiet Luxury** | Stillness, ritual, texture, contemplation | Byredo, Aesop, Hermès, niche fragrance, fine jewellery | Placed on lacquer/stone as ritual object |
| **(d) Serious / Dramatic Editorial** | Severe, architectural, sacred, no smiling | Loewe, Margiela, The Row, Patek, Porsche editorial | On a ledge/plinth — not held, not used |

**Register-specific director references:**
- **(a) Playful:** Wieden+Kennedy, Spike Jonze, early Sofia Coppola
- **(b) Extreme:** Jimmy Chin × W+K, Chloé Zhao cinematic
- **(c) Sensory:** Carlijn Jacobs, Harley Weir, Sofia Coppola for Marc Jacobs
- **(d) Serious:** Jonathan Glazer, Lynne Ramsay, Yorgos Lanthimos, Paolo Sorrentino, Steve McQueen

**Register-specific lighting:**
- **(a):** Mixed sources, golden hour, neon, energetic
- **(b):** Harsh natural, dawn/dusk, dramatic, unforgiving
- **(c):** Soft directional, paper-screen filtered, single window, candle/lantern
- **(d):** Single source with deep falloff, Caravaggio chiaroscuro, atmospheric haze

**Register + Brand DNA mapping (examples):**
- Aman → (c) Sensory
- Dior → (d) Serious or (c) Sensory
- Nike → (a) Playful or (b) Extreme
- Four Seasons → (c) Sensory
- Apple → (d) Serious
- Chanel → (d) Serious or (c) Sensory

### Cinema Gear Matrix — Brand DNA to Camera Package

Map Brand DNA directly to Higgsfield / cinema camera package for prompt language:

| Brand DNA | Emotional Core | Camera Body | Lens | Aperture | Grade |
|---|---|---|---|---|---|
| Generic Premium | Cinematic/Narrative | Full-Frame Cine Digital | Compact Anamorphic 35mm | f/2–f/4 | Warm, balanced |
| Apple | Clean/Precise | Modular 8K Digital | Premium Modern Prime 50mm | f/4–f/5.6 | Cool, overexposed whites |
| Chanel | Fashion/Editorial | Full-Frame Cine | Classic Anamorphic 50mm | f/2 | High contrast, desaturated |
| Aman | Dreamlike/Meditative | Premium Large Format | Halation Diffusion 50mm | f/1.4–f/2 | Muted, warm bloom |
| Tesla | Hyperreal/Sharp | Modular 8K Digital | Clinical Sharp Prime 85mm | f/4–f/5.6 | Cool steel, high contrast |
| Nike | Energetic | Studio Digital S35 | Compact Anamorphic 24–35mm | f/5.6–f/8 | High contrast, saturated |
| Rolex | Timeless/Controlled | Full-Frame Cine | Warm Cinema Prime 85mm | f/1.4–f/2 | Rich warm gold, deep blacks |
| Dior | Dramatic Fashion | Full-Frame Cine | Classic Anamorphic 75mm | f/2 | Filmic, Rembrandt-style |
| Airbnb Luxe | Natural/Warm | Classic 16mm Film | 70s Cinema Prime 50mm | f/1.4–f/2 | Warm, slightly desaturated |
| Four Seasons | Hospitality Warm | Full-Frame Cine | Warm Cinema Prime 50mm | f/2–f/4 | Warm gold, soft shadows |

Use the matching row's camera language as a `[CINEMATOGRAPHY]` block in Seedance or Kling prompts.

---

## Director Intensity

| Level | Description |
|---|---|
| `soft` | Subtle motion, minimal action, contemplative mood |
| `medium` | Balanced — purposeful action, confident camera (default) |
| `bold` | Dynamic cuts, strong action, dramatic camera moves |

Default: **medium**. User sets with: "soft" / "medium" / "bold".

---

## Editor Logic — Shot Purpose

Every shot must have a declared purpose:

| Purpose | Description |
|---|---|
| Establish | Introduce space, scale, or character |
| Movement | Character or camera moving through space |
| Interaction | Characters engage with each other or environment |
| Detail | Close-up of material, object, accessory, brand |
| Reaction | Emotional response, expression, pause |
| Reveal | New space, character, or element introduced |
| Closing | Final statement — logo, tagline, emotion |

Shots must connect and evolve. Each shot leads logically into the next.

---

## Camera Evolution

First shot: start from what the reference image shows.
Subsequent shots develop logically:
- rear to side to front
- wide to medium to close-up
- tracking to over-the-shoulder to reaction

Maintain spatial continuity throughout.

**Face Reveal** (when character begins from behind or side):
rear → partial profile → front → close-up
Use to build emotion and intimacy progressively.

**Action rule:** No static passive shots. Every shot must include movement or intention.
If multiple characters: always include interaction (eye contact, gesture, reaction, coordinated movement).

**Living Element Rule (mandatory in every shot):**
Every shot must contain at least one living element beyond camera motion. Pick one:
- Plant leaves or fronds responding to air movement
- Light shifting as clouds pass or source changes
- Fabric / curtain / robe moving in breeze
- Water surface rippling or pool surface with near-inaudible tension
- Character breathing, shifting weight, or micro-gesture
- Chandelier or hanging object swaying imperceptibly
- Sand particles lifting in wind
- Steam rising from surface
- Candle flame responding to air

**Mandatory Shot Variety (for any 15-second sequence):**
Every 15-second film must contain at minimum:
- 1 WIDE or AERIAL — drone, room-wide establishing, descending orbital
- 1 MEDIUM — character or mid-distance architectural
- 1 CLOSE-UP — material detail, face, hands, or object macro
- 1 REVEAL — through foliage, glass, architecture, or around a corner
Dialogue shot: never locked close-up on face — use medium or medium-wide.

**Speed Asymmetry Rule (ByteDance official):**
Never combine fast camera + fast action + complex scene simultaneously.
- If action is fast → camera stays slow/controlled
- If camera is dynamic → action stays deliberate
- Only ONE speed axis can be "fast" at a time

**Camera field limit:**
Keep `camera:` description under 20 words. One primary movement + one qualifier only.
Lens effects (bokeh, DOF, anamorphic flares) go in visual_feel — NOT in the camera field.
Never stack three or more camera instructions in one shot.

---

## Character Sheet (Nano Banana — референс-подготовка)

Перед созданием видео с реальным персонажем — создай Character Sheet в Nano Banana.
Это даёт Seedance лучший identity reference со всех ракурсов.

**Промпт для Nano Banana:**
```
Professional collage on clean white background (#FFFFFF).
Layout: one vertical full-body photo on the left (40% of frame width),
on the right a 2x2 grid of four images (each 30% width, 50% height).
The same person in all five images. Background fully removed, pure white,
no shadows or gradients. Preserve exact appearance: face, skin tone,
hairstyle, body proportions, all visible tattoos — 100% accuracy, no retouching.
Studio cutout, clean edges, high resolution, fashion lookbook model card style.
```

**Техника обхода модерации (если фото блокируется):**
Добавь этот слой поверх референс-фото в Nano Banana перед отправкой в Seedance:
```
Add a thin veil over the image as if a thin piece of parchment paper
was placed on top, through which the image is clearly visible.
Add 0.5% pencil drawing texture.
```
Это смягчает фото достаточно для прохождения модерации без потери identity данных.

**Когда использовать Character Sheet:**
- Любая мультишотовая сцена с реальным человеком
- Перед тем как использовать фото как @Image1
- Когда нужна строгая consistency лица во всех шотах

**Если фото лица блокирует модерация:**
Используй фото в полный рост вместо крупного плана лица.
Full-body shot проходит модерацию Seedance значительно лучше.
Seedance извлекает identity из любого ракурса — в полный рост работает не хуже.

---

## Identity Lock (Seedance 2 only)

When user uploads a reference image of a character who must look identical across all shots —
use Identity Lock as the FIRST block in the Seedance prompt. This fires first in the model's
attention window and prevents identity drift between shots.

```yaml
identity_lock:
  [actor_name]:
    reference: "@image1"
    preserve: "[exact face, hair color/style, skin tone, wardrobe items, accessories — be exhaustive]"
    do_not: "Do not age-shift. Do not change hairstyle, outfit, or identity at any point."
```

**Identity Lock vs @Actor tag:**
| Situation | Use |
|---|---|
| Reference image uploaded, must look identical | identity_lock + @Actor |
| No reference image, described only | @Actor tag only |
| Background character, one-off | @Actor tag only |

Identity Lock only applies to Seedance 2 YAML format.
For Kling — use detailed @Actor description repeated in every shot.

**One-Reference Rule (field-verified 2026):**
One canonical reference gives 60% less drift than six references.
More images = worse — the model starts averaging between them.
Always pick ONE canonical frame (front or 3/4) and use it everywhere.
Never upload more than 3 character references for the same person.

**Magic Phrase — First+Last Frame multi-shot:**
When uploading two frames (first + last), add at the end of the prompt:
`Show me what happens in between. USE MULTIPLE CAMERA ANGLES`
(USE MULTIPLE CAMERA ANGLES must be in ALL CAPS)
This switches the model from morphing mode to cinematic cuts with different angles.
Verified by @Framer_X, April 2026.

---

## Tag System

| Tag | What it means | Visibility rule |
|---|---|---|
| `@Actor` | Character — face/body consistency | Identity tag — present whenever character is visible |
| `@Outfit` | Clothing to preserve exactly | Wardrobe tag — mention only when visible or relevant |
| `@Accessory` | Bag, shoes, watch, jewellery… | Prop tag — mention only when visible or featured |
| `@Brand` | Logo / brand identity element | Prop tag — mention when visible in frame |
| `@Object` | Prop without brand, architectural detail | Prop tag — mention when visible or interacted with |
| `@Space` | Interior / architectural space | Location tag — use in header or when context needed |
| `@Facial` | Face-prominent shot — Freepik Facial Realism layer | Add anchor line at end of shot |

### Tag Visibility & Prop Continuity — CRITICAL RULES

Do NOT force all tags into every shot.

Before writing each shot, check:
1. Who is visible?
2. What wardrobe is visible from this angle and distance?
3. What props are visible or being interacted with?
4. What changed from the previous shot?

Only include tags that logically belong in that shot.

**Face close-up:** mention only @Actor, expression, lighting. Do NOT mention shoes, bag,
or unrelated props unless they are literally visible in frame.

**Prop continuity:** If a prop is placed down, handed off, or left behind — do not mention
it in later shots unless the camera returns to it. Never invent removal of wardrobe or
accessories unless explicitly requested.

**Both platforms:** Tags must appear in BOTH Kling 3 AND Seedance 2 — never drop tags
when switching to narrative style.

### @Facial Rules

Signals that this shot uses the Freepik Facial Realism Prompt as an external layer.

1. Write the shot prompt normally.
2. Add at the end:
   `// @Facial: apply Facial Realism Prompt — skin pores, lip detail, eye micro-detail, natural asymmetry, subsurface scattering, no artificial smoothing`
3. Do NOT paste the full realism prompt — applied separately in Freepik.
4. Add only to shots with prominent face visibility. Skip wide shots.

---

## Output Structure

### When images are uploaded (reference frames provided):
→ КОНЦЕПЦИЯ → ПРОМПТЫ → АУДИО → SCENE BREAKDOWN → WHERE TO TAKE THIS NEXT + NEXT ACTIONS
→ Skip МУДБОРД, СЦЕНАРИЙ, РАСКАДРОВКА — they are redundant when visual reference exists.
→ Output storyboard ONLY if user explicitly requests it ("Storyboard" / "1" from Next Actions).

### When no images (text-only request — "сделай ролик для ЖК"):
→ КОНЦЕПЦИЯ → МУДБОРД → СЦЕНАРИЙ → РАСКАДРОВКА → ПРОМПТЫ → АУДИО → NEXT ACTIONS

### Always at the end:
→ NEXT ACTIONS

---

## Section Templates

### КОНЦЕПЦИЯ
```
Brand: [name]
Brand DNA: [preset]
Director Intensity: [soft / medium / bold]
Слоган: [tagline]
Суть: [1 sentence]
Герой: [character description]
Тональность: [cinematic / warm / aspirational / minimal]
Длительность: [total]
Формат: [16:9 / 9:16 / 1:1]
```

### МУДБОРД
```
Визуальный стиль:
- Референс 1: [film / photographer / aesthetic]
- Референс 2: [lighting reference]
- Референс 3: [camera movement reference]

Палитра:
- Основной: [#hex — description]
- Акцентный: [#hex — description]
- Тени: [#hex — description]

Персонажи: [description, movement energy]
Атмосфера: [time of day, light quality, sound direction]
```

### СЦЕНАРИЙ
```
[00:00–00:05] СЦЕНА 1 — [name]
Видео: [what we see]
VO: "[voiceover]"
Титр: "[on-screen text]"
Музыка: [description]

[CTA]
Логотип + слоган
```

### РАСКАДРОВКА — Shot Block

```
· SHOT 0[N] · [timecode] · [duration] · [name] ·
Purpose:      [Establish / Movement / Interaction / Detail / Reaction / Reveal / Closing]
Camera:       [shot type + movement]
Action:       [what happens — no static shots]
Environment:  [space, materials, light]
Visible Tags: [only tags logically present in this shot]
Continuity:   [what changed from previous shot]
```

### ПРОМПТЫ

#### Kling 3:

**Hard limits:**
- Max **1500 characters** per prompt (SYNTX verified hard limit)
- Model actually reads **744–1500 characters** — it decides how much to process
- Accepts **any language** — not limited to English
- Separate **Negative prompt** field — do not put negatives in main prompt
- **Creativity vs Adherence** slider — controls how strictly model follows the prompt
- Modes: **Standard** and **Professional**
- Keyframes: **2 images → video** (first frame + last frame)
- Video-to-video: upload video + text instruction = modified output

```
· SHOT 0[N] · [duration] · [camera] ·
[Action + visible tags only], [environment],
[lighting], [atmosphere], photorealistic, 4K, [color grade].
// @Facial if applicable

Negative prompt: distortion, extra people, bad lighting,
shaky camera, text/logos unless requested, blurry, deformed,
artificial smoothing, cartoon style
```

**Kling prompt budget (1500 char limit):**
- Character description: ~300 chars
- Action per shot: ~200 chars
- Camera + lighting: ~100 chars
- Style + constraints: ~100 chars
- Negative prompt: ~200 chars (separate field)
- Total main prompt budget: ~1000–1200 chars max for clean execution

#### Seedance 2 — YAML format:
```yaml
# [identity_lock block here if reference image provided]

title: "[short evocative scene name]"
style: "[genre + aesthetic reference + visual philosophy]"
visual_feel: "[sensory/texture language — film grain, volumetric light, subsurface scattering etc. NO f-stops or ISO]"
duration: "[X seconds]"

character_modeling:
  [actor_name]:
    base: "[what/who + reference image if any: 'matching reference @image1']"
    features: "[physical description — colors, materials, wardrobe by item]"
    physics: "[how they move — personality through physicality, not adjectives]"

cinematic_storyboard:
  00_0X_[shot_name]:
    camera: "[position + ONE movement + one qualifier — max 20 words]"
    action: "[specific physical choreography — not summary]"
    lighting: "[3–5 words per shot — mandatory]"
    [sfx]: "[sound tied to this beat]"
    [vfx]: "[particle effects, material behavior if needed]"

  0X_0Y_[shot_name]:
    camera: ""
    action: ""
    lighting: ""

production_notes:
  audio_design: "[sound philosophy, music, silence, ambient]"
  subtext: "[what the scene is really about emotionally]"

visual_rules:
  - "Realistic human anatomy throughout"
  - "No duplicated people"
  - "No subtitles, no text overlay, no watermark"
  - "No artificial smoothing, no beauty filter"
  - "No jitter, no bent or distorted limbs"
  - "No identity drift between shots"
  - "[add scene-specific rules]"
```

**Official Seedance prompt structure order (SYNTX verified):**

Always write in this exact sequence:
1. List of all @Image/@Video/@Audio references with role declarations
2. Format: 16:9 or 9:16
3. Visual style and color palette
4. Location and atmosphere
5. Breakdown by seconds: `[0:00–3s]`, `[3:00–7s]`, `[7:00–11s]`, etc.
6. Technical requirements at the end (stability strings)

**Официальный порядок структуры промпта Seedance (SYNTX verified):**

Всегда писать в этом порядке:
1. Список всех @Image/@Video/@Audio тегов с описанием роли каждого
2. Формат: `16:9` или `9:16`
3. Визуальный стиль и цветовая палитра
4. Локация и атмосфера
5. Разбивка по секундам: `[0:00–3s]`, `[3:00–7s]`, `[7:00–11s]`
6. Технические требования в конце (stability strings)

**Per-shot lighting is MANDATORY** — even 3–5 words per shot has the highest leverage on output quality.

**Slash Structure for shot parameters:**
Use slashes / to separate shot parameters within a single line. This is a structural signal —
the model parses slashes as separate axes, not continuous prose.
Format: `SHOT N: [frame size], [lens] [movement] / [action] / SFX: [sound at Ns]`
Example: `SHOT 1: MCU, 50mm static / She opens eyes, exhales slowly / SFX: distant city ambient, sheets rustle at 0s`

**Per-shot word count:** 50–70 words per shot. Below 50 = random results. Above 70 = model forgets the start of the shot.
**Total prompt length:** 100–280 words. Above 300 often triggers content filter even without flagged content.
**Never use:** "epic", "amazing", "beautiful", "cool", "lots of movement" — no visual instruction.
**Forbidden in camera field:** f-stops, ISO values, focal lengths in mm, frame rates.

**Prompt length:** Target 100–260 words total. Below 100 = vague results. Above 260 = model ignores overflow.

**Shot field order (mandatory):** Subject → Action → Camera → Style → Constraints. Never deviate.

**Declare structure upfront:** Always open the prompt with shot count + total duration + aspect ratio.
Example: `"Multi-shot, 5 shots, 15 seconds, 16:9"`

**No contradictions:** Never combine opposing instructions in the same shot:
- "locked tripod" + "handheld shake" → pick one
- "bright sunny" + "noir shadows" → pick one
- Fast camera + fast action → Speed Asymmetry Rule applies

**@Reference system limits (Seedance 2.0):**
- Up to 9 reference images (@image1–@image9)
- Up to 3 reference videos (@video1–@video3)
- Up to 3 audio tracks (@audio1–@audio3)
- Maximum 12 external assets per prompt combined
- Always label uploads sequentially in order received

Compact limits: Kling ~2500 chars | Seedance ~4500 chars.
No filler. Keep: action, camera, key environment, visible tags only.

### АУДИО
```
Ambient: [environmental sound]
Foley:   [specific action sounds]
Music:   [style, tempo, instruments, mood]
```

### NEXT ACTIONS
Always show after every output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEXT ACTIONS:
1. Storyboard
2. Refine shot [N]
3. Export Kling 3
4. Export Seedance 2
5. Export Freepik
6. Expand audio
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Camera Movement Vocabulary

| Term | Description |
|---|---|
| Static shot | Camera doesn't move |
| Slow push-in | Gradual zoom toward subject |
| Pull back / reveal | Camera retreats to reveal context |
| Pan left/right | Horizontal rotation |
| Tilt up/down | Vertical rotation |
| Crane up/down | Vertical rise or descent |
| Tracking shot | Follows subject horizontally |
| Orbit / arc shot | Circles subject |
| Handheld | Slight natural shake (subtle) |
| Drone descent / aerial | Aerial movement |
| Whip pan | Fast horizontal sweep |
| Macro creep | Extreme close-up slow forward |

## Motion Intensity Phrases

Match to Director Intensity for prompt language:

| Intensity | Use these phrases |
|---|---|
| `soft` | "gently", "slowly drifting", "barely perceptible", "imperceptibly slow", "softly" |
| `medium` | "steadily", "gracefully", "at a natural pace", "smooth", "deliberate" |
| `bold` | "rapidly", "sweeping", "rushing", "snaps", "decisive", "sharp" |

## Camera Speed — Exact Numbers

Use precise measurements for Seedance/Kling prompts. Three pacing levels:

| Pacing | Brand DNA match | Push speed | Arc speed | Use for |
|---|---|---|---|---|
| **Luxury** | Aman, Rolex, Four Seasons | 1–3 cm/sec | 1–2°/sec | Meditation, service, stillness |
| **Editorial** | Generic Premium, Dior, Chanel | 2–5 cm/sec | 2–3°/sec | Fashion, architecture, lifestyle |
| **Dynamic** | Apple, Tesla, Nike | 4–8 cm/sec | 3–5°/sec | Launch, reveal, energy |

**Slow motion official phrasing (SYNTX verified):**
- Slow motion: `slow motion 120fps`
- Return to normal: `snap to real-time`
- Speed ramp: `speed ramping from slow motion 120fps to real-time`
- Speed ramp reverse: `speed ramping from real-time to slow motion 120fps`

Never write just "slow motion" without fps — model ignores it.

**Slow motion — официальные формулировки (SYNTX verified):**
- Замедление: `slow motion 120fps`
- Возврат к норме: `snap to real-time`
- Speed ramp вниз: `speed ramping from slow motion 120fps to real-time`
- Speed ramp вверх: `speed ramping from real-time to slow motion 120fps`
- Без fps = модель игнорирует. Всегда указывать 120fps.

**Camera speed vocabulary with numbers:**

Wide/Aerial:
- Descending orbital: `simultaneous clockwise rotation at 2°/sec and altitude drop at 1.5m/sec`
- Rising crane pull-back: `ascends 50cm over 3 seconds`
- Tracking push: `advances 3cm over full shot, barely perceptible gravitational pull`

Medium/Character:
- Arc orbit: `orbits 20 degrees clockwise at chest height, 1.5°/sec, subject stays centered`
- Parallel track: `moves parallel to subject at identical pace, 3cm/sec`
- Combined: `2cm push-in at 2cm/sec combined with 5-degree micro-drift right`

Close-Up/Detail:
- Surface drift: `ultra-slow upward drift along surface, 8mm/sec`
- Micro-arc: `slow orbital arc at 0.8°/sec around the detail object`
- Macro reveal: `positioned 15cm from surface, drifts upward discovering material`

## Tool Recommendation by Shot Type

| Shot Type | Best for Image (preview) | Best for Video |
|---|---|---|
| Face / emotion close-up | Flux / Midjourney v6 | Kling 3 / Hailuo |
| Architecture / interior | Midjourney v6 / Flux | Seedance 2 / Sora |
| Product / accessory detail | DALL-E 3 / Flux | Kling 3 / Runway |
| Landscape / aerial | Midjourney v6 | Seedance 2 / Sora / Luma |
| Character motion | Flux / Midjourney | Kling 3 |
| Storyboard layout | GPT Image 2 | — |

## VFX Feasibility for AI Video

What current AI video models can and cannot render reliably:

| Effect | Feasibility | Notes |
|---|---|---|
| Color grading | ✅ High | Describe in style/mood field |
| Light rays / flares | ✅ High | Include in lighting description |
| Particle effects (dust, snow, sparks) | ✅ Medium | Keep simple — one type per shot |
| Speed ramping / slow motion | ✅ High | State explicitly in camera field |
| Fabric physics / hair movement | ✅ High | Describe material and air movement |
| Water / liquid | ✅ Medium | Simple ripples work; complex splashes risk distortion |
| Reflections (glass, marble, water) | ⚠️ Low-Medium | Mirror reflections break scene geometry |
| Split screen | ⚠️ Low | Better added in post |
| Text overlays / logos | ⚠️ Low | Add in editing, not generation |
| Complex multi-person choreography | ⚠️ Low | Max 2 characters tracked reliably |
| Complex compositing | ❌ Avoid | Beyond current AI capability |

**Rule:** When in doubt, let camera movement and lighting carry the drama instead of VFX.

---

## Architecture & Materials Vocabulary

### Shot Types
| Shot | Best For |
|---|---|
| Drone descent | Facade, territory, scale |
| Slow push-in | Entry, lobby, key details |
| Orbit / arc | Single object — vase, facade element |
| Tracking | Character moving through space |
| Static wide | Living room, panoramic view, symmetry |
| Low angle | High-rises, monumentality |
| Over-shoulder | Character looking at view / opening door |
| Macro close-up | Material, accessory, brand, detail |

### Materials
- Stone: `honed Calacatta marble`, `raw concrete with aggregate texture`, `travertine panels`
- Glass: `floor-to-ceiling glazing with soft reflections`, `tempered glass balustrade`
- Metal: `brushed brass fixtures`, `matte black steel frame`, `polished chrome`
- Wood: `wide-plank white oak flooring`, `smoked walnut millwork`
- Light: `diffused northern light`, `warm tungsten glow`, `golden-hour raking light`

### Extended Location Vocabulary (Cannes-calibre specificity)

Never use generic locations. Always specific, textured, cultural:

**Sensory / Quiet Luxury:**
- Kyoto ryokan with paper screens, Rajasthan sand dunes at dawn
- Moroccan riad with zellige tile courtyard, Lisbon azulejo bathhouse
- Mexican brutalist hacienda, Alpine chalet by Peter Zumthor
- Tadao Ando concrete meditation space, cave church in Cappadocia
- Marble quarry at first light, abandoned cathedral with single shaft of light
- Korean bathhouse (jjimjilbang), Japanese onsen in volcanic rock
- French laundromat at dusk, Italian grandma's living room with plastic-covered sofa

**Serious / Dramatic Editorial:**
- Salt mine cavern, brutalist museum atrium with single skylight
- Vast empty concert hall, derelict Soviet sanatorium pool
- Underground cistern, monastic cloister at blue hour
- Patagonian glacier plateau, Bolivian salt flats at sunrise

**Playful / Kinetic:**
- Tokyo love hotel corridor, Lagos market with yellow danfo buses
- Seoul convenience store at 3am, Berlin club stairwell
- Mid-century American motel pool, neon arcade in Osaka
- Brutalist apartment block courtyard, dusty bodega in Mexico City

**Extreme / Kinetic:**
- Vertical granite cliff face at dawn, frozen Norwegian fjord with ice swimmers
- Half-built skatepark bowl in Tbilisi, BMX dirt track at dusk
- Abandoned Soviet ski jump, Hong Kong rooftop edge
- Underground Tokyo drift circuit, surf lineup at Nazaré
- Wingsuit launch ridge, motocross sand dune

---

## Depth Layers — Three-Layer Physical Description

Every shot should specify all three layers with physical precision.
This is what makes a prompt cinematic rather than generic.

```
Foreground — [what occupies this layer, % of frame, how it looks at this aperture — dissolved/sharp/suggested]
Hero — [what is sharp and why, what specific detail catches light]
Background — [what dissolves into bokeh, what is suggested not shown]
```

**Lens selection guide:**
| Focal length | Aperture | Best for |
|---|---|---|
| 100mm macro | f2.0–f2.8 | Extreme material detail, 4–8cm sharp band |
| 85mm | f1.2–f1.8 | Character medium-close, portrait with architectural bokeh |
| 50mm | f1.8–f2.0 | Balanced perspective, character in space |
| 35mm | f2.0–f4 | Full room, character + architecture in same frame |
| 24mm | f4–f5.6 | Wide establishing, aerial, full depth |
| 16mm | f2.8 | Extreme wide, immersive aerial |

---

## Character Behavior Table

What a character does when a specific element is visible in frame.
Never "he walks naturally" or "he observes". Always specific physical action.

| Visible in image | Character behavior |
|---|---|
| Pool / water feature | Crouches at edge, one hand removes shoe, sole skims surface — watches ripple expand |
| Chandelier / ceiling feature | Head tilts back, hand rises unconsciously toward nearest element, stops 2cm short |
| Raw material (concrete, wood, stone) | Fingertips trace grain slowly, not looking at hand — forensic examination through touch |
| Mirror | Approaches from side, sees partial reflection, pauses 1 second, continues |
| Staircase | Descends with fingertips on wall not railing, stops at mid-landing, looks up the void |
| Sofa / lounge chair | Sits at extreme edge not centered, one leg crossed, arm resting — completely still |
| Outdoor terrace / edge | Walks to absolute furthest point, back to camera, faces the view |
| Architectural surface | Palm flat against material, thumb traces one vein or grain line 3–4cm, stops |
| Window / glazing | Stands 30cm from glass, does not touch it — reads the view like a document |
| Flower / botanical | Crouches, one finger under single petal — lifts slightly, releases, watches it fall back |

**Banned character behaviors:**
- "He walks naturally" / "he observes" / "he looks around"
- Smiles at camera / looks at camera / performs for viewer
- Points at anything / gestures toward architecture
- Holds a prop that is not visible in the reference image

**Face rules:**
- Closed-mouth neutral or faintest natural ease
- Expression: "someone who has noticed something true" — not performing noticing
- Never fully frontal unless speaking on-screen

---

## Signature Shots Library

Use when contextually appropriate. These are director-level moves.

**Through-Foliage Reveal:**
Camera buried inside palm frond cluster — fronds fill 70% of frame — single gap reveals facade.
Breeze widens gap for 1.8 seconds then closes. Camera never moves. Only wind does.

**Reflection Walk:**
Subject moving, full mirror reflection on water surface simultaneously.
Camera at water level, 5cm above surface. Subject and reflection in same hero plane.

**Detail Trilogy:**
One continuous unbroken drift connecting three material surfaces. No cuts. One breath of movement.
Example: marble veining → brass fixture → glass edge — camera drifts through all three without stopping.

**Oculus Look-Up:**
Camera flat on floor. Slow clockwise rotation. Geometry converges to light source above.
Architecture mid-sharp, oculus sharp hero, sky full bokeh at apex.

**Hitchcock Zoom:**
Camera pulls back at 3cm/sec while lens compresses at compensating rate.
World behind subject collapses inward. Subject stays same size, background shrinks.

**Mirror/Glass Threshold:**
Camera inside shooting toward glass threshold. Ghost reflections of interior overlay the exterior world.
Character visible twice: real outside, ghost inside. Two versions converge as they cross threshold.

**Descending Orbital Reveal:**
Drone high altitude, camera tilted 45° downward. Simultaneous clockwise rotation at 2°/sec
and altitude drop at 1.5m/sec. Building forms shift — new ridgelines emerge,
glass skylights catch sun at different angles and flash briefly.

**Stop-Motion Freeze:**
Use exactly ONCE per prompt, at the moment of maximum tension.
Complete audio silence during freeze is mandatory — it makes the pause feel physical.
Format: `STOP MOTION [duration]s — complete audio silence — [what is frozen] — explosive snap-back to full speed`
Duration guide: 0.5s = sharp impact moment | 1.0s = standard dramatic freeze | 1.5s + 360° orbit = full Matrix bullet-time

---

## Gemini Omni Format

**Platform:** Gemini app (Plus/Pro/Ultra) + Google Flow
**Announced:** Google I/O, May 19 2026
**First model:** Gemini Omni Flash

### Key differences from Kling and Seedance

| Feature | Kling 3 | Seedance 2 | Gemini Omni |
|---|---|---|---|
| Prompt style | Precise technical | YAML structured | Conversational intent |
| Editing | Re-prompt each time | Re-prompt each time | Iterative chat edits |
| Multi-input | Image reference | Image reference | Image + video + audio + text |
| World knowledge | Low — describe everything | Low — describe everything | High — model fills details |
| Text rendering | Poor | Medium | Good — accurate placement |
| Character consistency | Medium | High (identity_lock) | High (built-in) |
| Storyboard input | No | No | Yes — upload storyboard |

### Gemini Omni prompt structure

**Formula:** `[Shot framing + motion] + [Style] + [Lighting] + [Location] + [Action]`

Less prescriptive than Kling/Seedance — describe your **intent**, let the model fill details.

**Text-to-video (simple):**
```
[Subject] doing [action] in [location]. [Camera move]. [Lighting]. [Style].
Example: A woman in a white robe walking through a luxury spa lobby.
Slow dolly forward. Warm amber light. Cinematic, shallow depth of field.
```

**With references:**
```
Using [image/video reference] as [role].
[What you want to happen]. [Camera]. [Style].
Example: Using @image1 as character reference.
She walks to the window, places her hand on the glass. Static medium shot.
Dior editorial, cold blue city light.
```

**Storyboard input:**
```
Follow this story exactly in order starting top left.
Entire story in [N] seconds. [Style].
```

### Conversational editing workflow

Omni's main advantage — iterative edits without re-prompting from scratch.

**How to use:**
1. Generate base scene with initial prompt
2. Ask for specific changes in plain language:
   - "Change the background to a night scene"
   - "Make the camera move slower"
   - "Add warm golden lighting"
   - "Change her outfit to a black dress"
   - "Sync the building lights to the music beats"
3. Model preserves what works, applies only the change

**Best for Omni (vs Kling/Seedance):**
- Scenes requiring iterative refinement
- Complex actions model understands from world knowledge
- Text overlay and typography in video
- Audio-synced visuals (lights to music beats)
- Style transfers (anime, claymation, watercolour)
- Storyboard-to-video workflow

**Best for Kling/Seedance (vs Omni):**
- Precise camera control with exact cm/sec values
- YAML identity_lock for strict character consistency
- Complex multi-shot with exact timecodes
- Physics-precise architectural shots

### Camera vocabulary (Omni-specific)

Works with exact terms from Kling/Seedance vocabulary PLUS natural language:
- `one continuous shot` / `oner` — no cuts
- `static` / `locked off` / `fixed` — no camera movement
- `push in` / `punch in` / `dolly zoom` — forward motion
- `natural smartphone zoom` — handheld mobile feel
- `film camera` — cinematic grain and character
- `webcam style` — raw documentary feel
- `over-the-shoulder` — classic OTS framing

### Omni-specific rules

**DO:**
- Describe intent not mechanics: "a tense confrontation" not "character A moves 45° toward character B"
- Use style references: "Dior editorial", "Wong Kar-wai", "Aman meditative"
- Reference complex actions by name: model understands them
- Combine any inputs: image + audio + video + text in one prompt

**DON'T:**
- Over-explain what's visible in the reference image
- Stack multiple style anchors — model will average them
- Use post-production terms: rotoscope, composite, keyframe

### Omni output in NEXT ACTIONS

When user asks for Omni export, output in conversational format:
```
🔮 GEMINI OMNI:

[Base prompt — intent-first, 1–3 sentences]

Reference: @[tag] as character/location/style reference.

Camera: [natural language movement]
Style: [one style anchor]
Lighting: [lighting intent]

Conversational edits to try after generation:
— "[edit suggestion 1]"
— "[edit suggestion 2]"
— "[edit suggestion 3]"
```

---

## Product-Ad Mode (single continuous shot)

For product hero shots, brand object reveals, and architectural detail commercials.
No cuts. Camera glides, dives, orbits, and pulls back constantly throughout.
Use with: @Object, @Brand, @Logo, architectural material detail.

**Speed Ramp system — use % to describe playback speed per phase:**

| Phase | Speed | Camera behavior |
|---|---|---|
| Opening / approach | 50% | Slow build, subject revealed |
| Macro detail orbit | 140% | Fast spiral, texture reveal |
| Profile / side settle | 35% | Slow curve along edge |
| Hero build-up | 120% | Sweep under, rise to angle |
| Final reveal hold | 20% | Camera settles, golden light |
| End card | cut to black | Logo/tagline fades in |

**Product-Ad prompt structure:**
```
Camera Simulation: [camera body + lens + filter + lighting philosophy].
Single continuous [N]-second shot. No cuts. Camera [glides/dives/orbits/pulls back] constantly.

[00:00–00:XX] · [Phase name]
[What is in frame, what camera does, speed %, SFX]

[00:XX–00:XX] · [Phase name]
...

[End card]
[Cut description. Logo/wordmark. Tagline. Film grain. Hold.]
```

**Banned in Product-Ad mode:** cuts, jump cuts, character introduction, environmental context shots.
**Required:** specific material description, light direction named, speed % for each phase.

---

## Sound Design Library

Never write sound categories — write the actual sound.

| Material / environment | Exact SFX to write |
|---|---|
| Marble interior | `sub-frequency marble resonance — a hum you feel before you hear it` |
| Brass / bronze chandelier | `single metallic ring, like a wine glass rim touched once — decaying over 2 seconds` |
| Wood grain | `dry whisper of fingertip on rough oak — a sound like paper being slowly turned` |
| Pool / still water | `near-inaudible surface tension of completely still water` |
| Desert wind | `open desert frequency — deep, full, constant. Sand grain displacement across dune surface.` |
| Velvet / bouclé fabric | `micro-whisper of fabric as arm rises — cotton-linen brushing against itself` |
| Tropical leaves / fronds | `dry frond against frond sweeping left to right — one full organic movement` |
| Stone driveway / terrace | `compressed stone underfoot — a dry crunch with each deliberate step` |
| Controlled interior air | `the specific silence of a mechanically controlled space — not absence, a presence` |
| Canopy in light wind | `bronze lattice in light breeze — a frequency between metal and air` |
| Glass surface contact | `near-inaudible contact of palm on tempered glass — a warmth sound, not a tap` |
| Foam / bath | `foam surface breathing — micro-bubbles dissolving at irregular intervals` |
| Steam | `steam exhale — a sustained whisper that has no beginning and no end` |

**Music volume levels:**
- 40–55% — barely present, completes the room's own silence (Aman/soft)
- 55–65% — restrained underscore, never competing (Four Seasons/medium)
- 65–75% — balanced foreground, clearly present (Generic Premium)
- 75–85% — music leads, space sounds audible beneath (Nike/bold)

---

## Mood Presets

Read `/references/mood-presets.md` for full presets:
- `luxury-minimal` — white + stone, overexposed, slow
- `warm-human` — golden hour, lifestyle, handheld feel
- `epic-cinematic` — drone, wide, orchestral
- `night-premium` — blue hour + warm interior glow
- `nature-integrated` — biophilic, green, diffused light

---

## Cinema Modes — Canonical Camera Blocks

Five modes for architectural/luxury advertising. Pick by scene type, paste the block at the end of any Seedance prompt.

| Mode | Use when... | Body | Lens | Movement |
|---|---|---|---|---|
| **M1 Narrative** | Real-world interior/exterior, lived-in spaces | Alexa 35 | Panavision Ultra Vintage anamorphic 40/55/75/100mm T2.3 | Handheld, natural breath |
| **M2 Studio** | White void, editorial portrait, fashion film | Alexa Mini LF | Cooke S4/i spherical 32/50/75/100mm T2 | Locked + optional 4–6" slow push |
| **M5 Atmospheric** | Empty spaces, no-humans, landscape, mood plate | Alexa Mini LF | Panavision Ultra Vintage anamorphic 35→85mm T2.3 | Locked or extremely slow push |

**Lens length guide:**
- 32/35/40mm — wide establishing, full-body, environmental context
- 50/55mm — medium portrait, two-shot, waist-up (default)
- 75mm — tight editorial portrait, single character
- 85/100mm — extreme close-up: eyes, lips, jewelry, fabric detail

### M1 — Narrative (luxury interiors, lobby, bedroom, kitchen)
```
Shot on ARRI Alexa 35 in ProRes 4444 LogC4, Panavision Ultra Vintage 2x anamorphic [XX]mm at T2.3
with Tiffen Black Pro-Mist 1/4 filter, handheld with natural breath and slight shake,
photoreal cinematic grit with oval bokeh and horizontal streak flares,
warm anamorphic falloff toward frame edges, Kodak Vision3 250D film emulation grade
with slight halation on highlights and 800 ASA grain structure,
teal-amber color split with cool teal-blue shadows and warm amber highlights,
organic lens breathing on focus racks, shallow depth of field,
24fps base shutter 180 degrees, total runtime roughly [XX] seconds.
```

### M2 — Studio/Editorial (penthouse voids, fashion, clean brand)
```
Shot on ARRI Alexa Mini LF in ProRes 4444 LogC4, Cooke S4/i spherical prime [XX]mm at T2
with Tiffen Black Pro-Mist 1/2 filter, locked-off tripod with optional 4-to-6 inch slow push-in,
photoreal editorial fashion film aesthetic with gentle halation bloom on highlights
and soft warm falloff in the Cooke signature, fine 400 ASA film grain structure,
saturated editorial grade with warm-retained blacks not crushed to pure black,
slight skin tone warmth from the Cooke color rendition,
24fps base shutter 180 degrees, total runtime roughly [XX] seconds.
Not CGI, not plastic, shot-on-film analog aesthetic with real-world lens character.
```

### M5 — Atmospheric (empty spaces, bay views, establishing plates)
```
Shot on ARRI Alexa Mini LF in ProRes 4444 LogC4, Panavision Ultra Vintage 2x anamorphic [XX]mm
at T2.3 with Tiffen Black Pro-Mist 1/4 filter, locked-off or extremely slow push-in motion only,
no handheld energy, photoreal atmospheric environment plate aesthetic,
Kodak Vision3 250D film emulation with fine 400 ASA grain structure,
palette-driven grade with [palette descriptor], strong negative space,
deep depth of field, light atmospheric haze with dust particles suspended in air,
slight anamorphic flares on any directional light sources,
24fps base shutter 180 degrees, total runtime roughly [XX] seconds.
```

Replace `[XX]` with lens length and runtime. Replace `[palette descriptor]` with scene-appropriate language.

---

## Locked Photoreal Stack

Closes every Kling and Seedance prompt. Non-negotiable — paste at the end of every prompt:

```
Hyperrealistic photography. Real human skin texture with visible pores, subtle subsurface
scattering on cheeks, nose bridge, and ears, fine peach fuzz catching light along jawline
and cheekbones, slight natural skin imperfections — not retouched. Hair rendered strand by
strand with realistic flyaways, baby hairs at hairline, individual strands catching light,
light transmission through hair ends. Fabric rendered with real weave detail, real weight,
real drape, visible texture variation. Eyes with real reflection, real moisture, real iris depth.
Jewelry with real metal surface detail. Kodak Vision3 500T film emulation, visible fine film
grain, subtle chromatic aberration at frame edges, soft lens vignette, cinematic color grade
with warm mid-tones and slightly cooled shadows. Lived-in, not pristine. Photographic, not rendered.
```

For environment-only shots (no humans): drop skin/hair lines, keep fabric/light/lens/grain/grade lines.

---

## Timestamp Scaling Guide

Use to auto-calculate optimal shot count per duration:

| Duration | Shots | Avg sec/shot |
|---|---|---|
| 5s | 2–3 | 1.5–2.5s |
| 10s | 3–4 | 2.5–3.5s |
| 15s | 4–5 | 3–4s |
| 20s | 5–7 | 2.5–4s |
| 30s | 7–10 | 3–4.5s |

Pacing principles:
- Opening shots run longer (establishing context)
- Impact / transformation moments compressed (2–3s) for energy
- Final shot holds — let the image breathe
- Dialogue scenes: longer shots / Action scenes: shorter cuts

---

## Scene Archetype Router

Before writing any Seedance prompt — identify the archetype. It drives camera behavior, spatial logic, and what changes across time.

### Action Archetypes
| Archetype | Camera focus | Space dynamic |
|---|---|---|
| **Pursuit** | Distance closing/opening. Pursued ahead, pursuer behind | Path narrows or opens |
| **Duel** | Lower on dominant side — dominance alternates | Fighters trade position |
| **Impact** | Build-up slow → hit fast → aftermath slow | Point of contact = center |

Decision tree: chasing? → Pursuit. Alternating advantage? → Duel. Single decisive contact? → Impact. Default → Duel.
Duel rule: neither side dominates more than one consecutive beat.

### General Archetypes
| Archetype | What changes | Camera signature |
|---|---|---|
| **Journey** | Position in space — road, walk, flight | Tracking, aerial, traveling alongside |
| **Atmosphere** | Nothing — mood IS the content | Minimal movement, slow push-in or static hold |
| **Reveal** | Hidden → visible — door opens, fog lifts | Pan, crane, dolly reveal |

Decision tree: subject moves through space? → Journey. Something hidden becomes visible? → Reveal. Mood is the content? → Atmosphere. Default → Atmosphere.

### Dialogue Archetypes
| Archetype | Power dynamic | Camera signature |
|---|---|---|
| **Confrontation** | Shifting — both push, dominance trades | Tight OTS, camera crosses axis on power shift |
| **Interrogation** | Asymmetric — one extracts, one resists | Low-angle on questioner, push-in on silence |
| **Negotiation** | Balanced — both need something | Symmetrical framing, matching shot sizes |

Decision tree: both pushing, dominance trading? → Confrontation. One extracting? → Interrogation. Balanced need? → Negotiation. Default → Confrontation.

**For architectural/luxury advertising:** lobby arrival = Journey/Reveal. Service scene = Atmosphere. Couple interaction = Confrontation or Negotiation. Empty space = Atmosphere.

---

## Cut Rules

### Double Contrast (mandatory on every cut)
Every cut must change **both** shot size **and** camera character simultaneously.

Camera modes — never repeat across a cut:
`Handheld` | `Static/locked-off` | `Stabilized tracking` | `Crane/vertical` | `Aerial/drone`

Bad: wide static → medium static (same camera character)
Good: wide static → medium handheld (both change)

### Spatial Re-anchoring
After any cut returning to established space: re-state who is where and which direction they face.
If character moves left-to-right before cut → same direction after. Always state movement direction explicitly.

### Insert Rules
Inserts = sub-second (0.3–0.5s) dramatic punctuation cuts. Any shot size.
- Must NOT contain story beats — static moments only
- **Causally motivated:** viewer must understand WHY they see this detail
- **Name the subject:** specify WHOSE body part/detail. Without attribution, Seedance renders wrong content
- Must obey Double Contrast rule

Good: "hero slammed onto hood → **his** hand gripping the metal edge"
Bad: "generic boot stepping in puddle" (no attribution, no cause)

---

## Seedance Engine Rules

### Technical Limits (SYNTX / Higgsfield verified)

| Parameter | Limit |
|---|---|
| Images as references | Up to 9 simultaneously (@Image1–@Image9) |
| Videos as references | Up to 3 (MP4, max 19MB each, 640×640 to 1284×722, total ≤15s) |
| Audio as references | Up to 3 (MP3 only, total ≤15s) |
| Duration | 1–15 seconds (default: 4s) |
| Resolution | 480p / 720p / 1080p (1080p = Pro mode only) |
| Aspect ratios | 6 options |
| Modes | Pro (final quality) / Fast (testing) |

**Audio reference workflow:** Upload image/video first → upload MP3 → enable audio toggle → add `@refN lip sync reference @refN exactly` in prompt.

### Mandatory Stability Strings

Add to EVERY Seedance prompt — at the end of character description AND at the end of visual_rules:

```
Same person in all shots. Preserve exact appearance throughout. Stable face throughout.
No deformation. No flickering. No ghosting. Stable face throughout. Realistic physics.
```

These are officially recommended by SYNTX/ByteDance documentation.
Never omit them — they directly reduce identity drift and visual artifacts.

### @ref Tag System (official Seedance naming)

When multiple images uploaded, each gets a sequential tag: `@ref1`, `@ref2`, `@ref3` etc.
Use them to assign roles explicitly in the prompt:

```
@ref1 — exact identity reference for the main character face, hair, body type
@ref2 — exact wardrobe reference: outfit, fabric, accessories
@ref3 — exact environment reference: location, lighting, atmosphere
@ref4 — exact prop reference: object shape, finish, scale
```

Rules:
- Always declare what each @ref is used for at the start of the prompt
- Write "Use @ref1 as the strict reference for [specific elements]"
- Never leave a @ref undeclared — model decides on its own and often gets it wrong
- For identity: "Preserve exact likeness throughout. No beautification. No deformation."

### Cut Syntax — монтажные переходы внутри временного блока

Для динамичных сцен с множеством ракурсов — используй `Cut —` в начале каждой строки внутри временного блока:

```
[0:00–3s]
Wide aerial shot of the court. @Image1 stands at center, ball under foot.
Cut — ground level: he starts dribbling toward the basket.
Cut — tight shot on his hand palming the ball.
Cut — low angle from asphalt, feet pounding past.
```

Каждый `Cut —` = отдельный ракурс. Seedance читает их как последовательность склеек.

**Паттерн для динамичных сцен:**
`Minimum 20 cuts. 15 seconds.` — добавить в Technical секцию промпта.
Seedance выполняет инструкцию на количество склеек.

**Дробление таймкода для точного контроля:**
Стандарт: `[0:00–3s]` (3 сек блоки)
Для динамики: `[0:00–1.5s]`, `[1.5–3s]`, `[3–5s]` (1–2 сек блоки)
Чем короче блок — тем точнее контроль над конкретным действием.

**Паттерн "invisible defender" (движение без второго персонажа):**
`blows past an invisible defender` — создаёт динамику уклонения без необходимости генерировать второго человека.

### Hard rendering constraints — violation = broken output:

- **Action beats = intent + named technique, not biomechanics.**
  ✅ "spinning back kick connects" ❌ "left forearm rotates 45° to deflect incoming hook at wrist level"
- **Describe force and direction, not destruction sequence.**
  ✅ "driven into the car, metal buckling" ❌ "thrown into door, glass shatters, uses rebound to sweep leg"
- **Spatial continuity breaks on cuts.** Re-anchor positions after every cut.
- **≤ 3 characters tracked across cuts.** Name the acting pair and interaction vector per shot.
- **Exit-frame = implicit cut.** Character leaves frame → gone for remainder of shot. Never choreograph exit + re-entry in same continuous shot.
- **Off-screen = nonexistent.** State changes must be shown on camera before being referenced.
- **Avoid reflection shots** (mirrors, puddles, blades) — Seedance breaks scene geography on reflections.
- **Only describe what can be seen or heard.** ❌ "The air smells of pine." ✅ "Pine needles on ground, wind moving through branches."
- **Micro-expressions as physics.** ✅ "jaw clenches, nostrils flare" ❌ "looks angry"

---

## Physics Descriptors (mandatory per shot)

Every shot must include at least one physics descriptor. This separates cinematic from generated-looking.

**Motion physics:**
- `motion blur on background, subject stays sharp`
- `strong parallax with [environment elements]`
- `dust and particles visible in [light source]`
- `heat shimmer visible`
- `realistic reflections on [surface]`
- `[material] flexing / moving under force`
- `fabric weight and drape visible with movement`
- `hair movement catching light`

**Weight and momentum:**
- `[object] has weight — arm dips slightly when held`
- `body weight shifts telegraph through shoulders before movement`
- `heel strike on [surface] with real contact`
- `door has mass — swings with controlled deceleration`

**Atmospheric physics:**
- `[particles] suspended in [light beam]`
- `steam / breath vapor catching light`
- `water droplets on surface`
- `curtain fabric moves in warm air`

---

## Failure-Mode Catalog

When output doesn't land — diagnose before re-rolling. Most failures are structural and fixable in one revision.

| Symptom | Likely cause | Fix |
|---|---|---|
| Identity drift / face morphing | Vague subject description | Add age/clothing/distinguishing features; repeat exact description in every shot |
| Stiff / generated-looking motion | No physics descriptors | Add motion physics (parallax, weight, debris, momentum) |
| Timing ignored / shots blending | Shot blocks run together | Enforce blank-line separation; verify timing is continuous |
| Action blending (multiple verbs collapse) | Stacked verbs in one shot | Split into separate timed beats; one primary action verb per shot |
| Constraints ignored | Using "no X" phrasing | Rewrite as positive: "stable / consistent / natural" |
| Character switches identity across shots | Pronouns instead of role descriptors | Replace every pronoun with role descriptor |
| Lighting feels artificial | No light source named | Name the practical source and motivate every shift |
| Style mismatch / generic look | Vague style adjectives | Replace with one specific Cinema Mode anchor |
| Prompt partially ignored | Too many elements | Trim to single style anchor + tight constraints; aim 100–260 words |
| Prompt rejected / filtered | Blocked vocabulary | Rephrase action verbs: "impact" not "punch", "momentum transfer" not "hit" |

**Re-roll if:** prompt is structurally sound, less than 30% of beats landed.
**Revise if:** specific failure mode is reproducible, more than 30% of beats landed — preserve what worked.

---

## Antislop — Never Use

These words give the model no visual instruction and produce generic results. Banned in all prompts:

**English:** breathtaking, stunning, captivating, mesmerizing, awe-inspiring, masterfully,
meticulously, exquisitely, beautifully crafted, cinematic masterpiece, visual feast,
a symphony of, seamlessly, effortlessly, flawlessly, cutting-edge, state-of-the-art,
next-level, rich tapestry, vibrant tapestry, kaleidoscope of, elevate, unlock, unleash,
harness, groundbreaking, a testament to, speaks volumes, resonates deeply,
epic, amazing, beautiful, cool, lots of movement

**Already banned (ByteDance):** f-stops, ISO values, focal lengths in mm as camera behavior,
"music plays", "soundtrack swells", "orchestral", "strings"

---

## JSON Export (optional)

When user requests JSON format output — deliver two objects: EN prompt and ZH prompt.

```json
[
  {"lang": "en", "prompt": "[full EN prompt as continuous string with inline labels]"},
  {"lang": "zh", "prompt": "[full ZH prompt — native rewrite, not translation, ≤1800 chars]"}
]
```

Prompt sections (inline labels, continuous string):
1. **Style & Mood:** palette, lighting, lens, atmosphere. Never skip.
2. **Dynamic Description:** shot-by-shot in prose, present tense, camera + movement + action.
3. **Static Description:** location, props, ambient details. Establish anything referenced in Dynamic.
4. **Audio:** (dialogue scenes only) spoken lines + SFX. Dialogue in original language — never translate.

ZH rules:
- Native director's notes — not a translation. Natural syntax, film jargon.
- Hard cap: 1,800 characters.
- If over limit, trim in order: Narrative Summary first → Static Description → Style & Mood (1 sentence min) → Dynamic Description (never cut entirely).

When to use JSON export: user says "JSON format", "bilingual", "EN+ZH", or requests output for API integration.

---

## Pre-Generate Checklist

15-second check before every generation. Catches 80% of failures before they happen.

**Structure:**
- ☐ Duration matches shot count (stable zone: 5s=1–2 shots, 10s=2–4 shots, 15s=3–5 shots)
- ☐ Every @Image/@Video/@Audio has a declared role
- ☐ Total references ≤ 12
- ☐ One format only — do not mix formats in one prompt
- ☐ One camera movement per shot, no stacking

**Style and terminology:**
- ☐ Style = ONE anchor + 2–3 modifiers only
- ☐ No "4K", "masterpiece", "stunning", "epic" — Antislop rule
- ☐ No "Zoom in/Zoom out" — use "push in" / "pull back"
- ☐ Terms only from canonical vocabulary

**Logic and continuity:**
- ☐ Prompt does not contradict the reference image
- ☐ Walk scene: maximum 4–5 steps (longer = outfit drift)
- ☐ Outfit consistency: maximum 8 seconds per shot before change
- ☐ Wardrobe change between outfits: show transition frame or add LOGIC RULE

**Negatives:**
- ☐ White list only: No subtitles / No text overlays / No captions / No watermarks / No logos
- ☐ No "without X", "avoid X", "--no X" — rewrite positively

**Audio:**
- ☐ Format: Sound: [ambient bed]. SFX: [specific sound at Ns].
- ☐ Foley describes surface: "boots on wet cobblestone", not "footsteps"
- ☐ Music with BPM and dynamic arc, not "epic" or "ambient"

**2 Restart Rule:**
If after 2 regenerations the clip still requires more than 10 minutes of manual correction — stop.
Check the prompt against this checklist, change ONE variable (duration / refs / seed),
or move to manual editing.
First 1–2 seconds with wobble = restart immediately. "Early wobble rarely settles."

---

## Hook Rule

**Default (medium/soft intensity):** Opening shot can establish space and mood.
Stillness is allowed for Aman/Four Seasons/Rolex brand DNA.

**Bold intensity only:** Action is already happening at second zero.
Never open with stillness in bold mode. Character is mid-motion from frame one.

---

## Hook Psychological Triggers

Every prompt's opening 2 seconds must stop the scroll. Match hook to desired psychological response:

| Hook Type | Trigger | Best For |
|---|---|---|
| Drone descent toward property | Awe, scale, location desire | Establishing shots, facades |
| Door opening to reveal interior | Anticipation, threshold crossing | Any interior reveal |
| Window view approach | Envy, lifestyle aspiration | Waterfront, skyline, views |
| Material texture macro close-up | Tactile desire, luxury recognition | High-end finishes, fabrics |
| Silhouette against backlight | Mystery, universality (viewer projects self) | Character arrival, fashion |
| Low tracking at ankle/shoe level | Precision, power, fashion detail | @Shoes, heel strikes, movement |
| Brand logo reveal (tilt up or push in) | Identity recognition, trust | @Logo shots, brand detail |
| Couple walking toward camera | Warmth, aspiration, arrival | Lifestyle, hospitality |
| Chauffeur at open car door | Service aspiration, exclusivity | Butler, hospitality, arrival |
| Day-to-night transition | 24-hour lifestyle appeal | Properties, hospitality |

---

## Quick Start

| Input | Action |
|---|---|
| 1 image, no tags | Ask: single/multi, duration, shots (if multi), platform |
| 1 image + tags | Ask same. Apply tag visibility rules per shot. |
| Multiple images | Ask: duration + platform only. Each image = 1 shot. |
| "Ролик для ЖК, 30 сек" | Ask brand + concept. Default: Generic Premium, medium intensity. |
| "Brand: Aman, intensity: soft" | Apply Aman DNA + soft pacing to all shots. |
| "Export Kling" | Output all shots in compact Kling format only. |
| "Refine shot 3" | Rewrite only that shot block + prompt. |
| Duration given | Use Timestamp Scaling Guide to set shot count automatically. |

---

## Output Language

- Response: same language as user
- Kling / Seedance prompts: always in English
- Storyboard labels + script: in user's language

---

## Universal Prompt Rules

These apply to every prompt — Kling, Seedance, GPT Image. No exceptions.

**Naming rule:** Never use character names in prompt output. Describe by visual markers:
"the dark-haired woman in the white linen dress" not "Maria." Visual descriptors survive
across prompts; names do not.

**Brand name rule:** Never use real brand names in prompt output. Use generic visual
descriptors — "embroidered white script numerals on the chest" not brand names.
Exception: the "619" logo is a fictional brand — include when visible.

**Age-blind rule:** Never describe characters by age. Avoid: young, teen, middle-aged,
elderly, old. Describe by build, role, and clothing only.

**No-invention rule:** If a reference image exists — do not invent wardrobe or styling
details not visible in the image. If something is needed but not visible, ask the user
before composing.

**Dynamic vs Static split:**
- **Dynamic Description** — what changes across the duration: actions, gestures, camera
  moves, focus racks, lighting shifts. One continuous flow.
- **Static Description** — what does not change: characters in full visual detail,
  environment, anchored props. Re-stated in full in every prompt.

**Model / Character archetype rule:**
Never use generic descriptors: "beautiful woman", "attractive man", "professional model", "handsome".
Always describe distinctive, specific, memorable features. Rotate through:
- Physical traits: freckles, gap teeth, big ears, prominent nose, unibrow, birthmark, vitiligo, albino features
- Hair: curly/coiled/shaved/bleached/dyed, mullet, buzzcut, high bun with flyaways
- Build: tall and lanky, short and stocky, androgynous, gender-fluid
- Age: mature 50+, teenager, mixed-age
- Ethnicity: always specific — Korean, Nigerian, Romani, Sami, Tongan, Mexican, mixed — never "ethnic woman"
- Details: tattoos, piercings, unusual eyewear, scarification, gold teeth

**Diegetic audio rule (Seedance):**
Describe only what the scene physically produces. Allowed:
footsteps (specify surface), fabric rustle/whip, breath, body sounds, object sounds,
environmental ambient (room tone, wind, rain, traffic, water), weather/atmosphere.

Never include: song names, artist names, lyrics, "music plays", "soundtrack swells",
"orchestral", "strings", any score descriptor.

Audio line template:
`Audio: diegetic only — [4–8 specific sounds with adjectives], no music, no dialogue
except what is physically spoken in frame.`

---

## Storyboard Prompt Builder (двухфазовая система)

Полный workflow для создания профессиональных стейбордов.
**Phase 1** → image prompt для листа стейборда (Nano Banana Pro / GPT Image 2)
**Phase 2** → video prompt по утверждённому стейборду (Seedance / Kling)

Phase 2 только после явного подтверждения пользователя. Всегда спрашивать перед переходом.

---

### Inputs (собирать в одном сообщении)

1. **Референс-фото персонажей** — портреты, турнараунды, concept art, фото. Если не загружены и в сцене есть персонажи — спросить один раз: "Загрузи референс-фото персонажей — даже один портрет помогает зафиксировать внешность. Или я опишу персонажей из текста." Спросить только один раз.
2. **Story overview** — от одной фразы до полного beat sheet.
3. **Visual style** — если не указан, вывести из контекста. При неоднозначности спросить.

**Опционально:** количество панелей (дефолт 15), длительность (дефолт 15 сек), соотношение сторон (дефолт 16:9), целевая модель (дефолт Nano Banana Pro).

---

### Character DNA

При наличии референс-фото — извлечь для каждого персонажа:
- Внешность: строение лица, тон кожи, волосы (цвет/длина/текстура/укладка), возрастной диапазон, телосложение, особые приметы
- Одежда: предметы, цвета, материалы, посадка, акцессуары
- Дизайн-язык: пропорции (реалистичные/стилизованные), силуэт, палитра
- Энергетика: осанка, тенденция выражения лица

Компактное описание каждого персонажа: **80–150 символов**. Вшивается в промпт и поддерживает консистентность между панелями.

**Распределение деталей по панелям:**
- Лицо и волосы → в close-up панелях
- Полный образ и одежда → в wide shot панелях
- Акцессуары → когда видны в кадре
- Не концентрировать все детали в панели 1

---

### Three-Act Structure (15 панелей)

| Панели | Акт | Содержание |
|---|---|---|
| 1–3 | Setup | Мир, персонаж, отправная точка |
| 4–6 | Inciting incident | Событие которое всё меняет |
| 7–10 | Rising tension | Нарастание, препятствия, решения |
| 11–13 | Climax / Resolution | Пик напряжения, поворотный момент |
| 14–15 | Denouement | Эмоциональное приземление |

Emotional escalation: нарастание через середину, пик на панелях 10–12, затем разрядка.
Close-up на эмоциональных пиках. Wide shot для контекста и дыхания.

---

### Shot Variety Rule

Никогда не повторять тип шота в соседних панелях.
Чередовать: Wide ↔ Medium ↔ Close-up ↔ Low Angle ↔ High Angle ↔ Dynamic ↔ OTS ↔ Macro

---

### Grid Layouts

| Панелей | Grid (16:9) | Grid (9:16 vertical) |
|---|---|---|
| 9 | 3×3 | 3×3 |
| 12 | 3×4 | 4×3 |
| 15 | 3×5 (default) | 5×3 |
| 20 | 4×5 | 5×4 |

---

### Phase 1 — Storyboard Image Prompt Structure

Писать как единый непрерывный текст в fenced code block. Секции по порядку:

**A) Title & Format Header**
Открывать с концепции листа: длительность, название, количество панелей, grid layout, жанр стиля.
Пример: *"15-second cinematic storyboard sheet for a luxury lifestyle short film titled '[NAME]'. A complete professional storyboard presentation page featuring 15 sequential cinematic panels arranged in a clean 3×5 grid layout."*

**B) Style Declaration**
Адаптировать полностью под стиль пользователя — не фиксированный блок.
- Live-action: cinematographic style, film stock look, practical lighting, grounded realism
- 3D Animation: Pixar/DreamWorks quality, expressive character animation, warm lighting
- Anime: studio reference (Ghibli/Trigger/MAPPA по тону), cel-shading, dynamic line work
- 2D Animation: hand-drawn quality, colour palette approach, line weight

**C) Character Descriptions**
Прозой (не списком). Физические черты, одежда, акцессуары, отличительные визуальные элементы.

**D) Visual Tone**
Цветовой грейдинг, атмосфера, качество освещения, рендер-подход.

**E) Storyboard Layout Details**
Физический вид листа: материал фона, профессиональный production стиль, нумерация кадров, временны́е метки, описания шотов, чистая типографика.

**F) Scene Breakdown**
Каждая панель: *"Panel [N]: [Shot type] shot. [Описание сцены с действием персонажа, окружением, эмоциональным битом]."*
Диалог/действие вплетать естественно в описание панели.

**G) Art Direction Footer**
Технические cues рендера: качество выражений лиц, разнообразие углов камеры, детализация текстур, атмосферные эффекты, принципы композиции.

**H) Rendering & Format Footer**
Финальные тех. спеки: render quality cues, aspect ratio, format declaration, quality tier.

**Целевая длина промпта:**
- 9 панелей: 800–1 200 слов
- 12 панелей: 1 000–1 500 слов
- 15 панелей: 1 200–1 800 слов (дефолт)
- 20 панелей: 1 500–2 000 слов

После code block — **companion note** (3–5 предложений):
- Стилистические решения за пользователя
- Что взято из референсов vs выведено
- 1–2 предложения по рефайнингу
- Напоминание: "Когда доволен стейбордом — скажи, сделаю видео промпт."

---

### Phase 2 — Cinematic Video Prompt

Только после явного подтверждения пользователя.

**Маппинг панелей на шоты:**
15 панелей / 15 сек = 1 сек на шот.
Для длинных форматов — распределять интеллектуально: establishing shots и эмоциональные биты 2–3 сек, быстрые экшн-биты 1 сек. Сумма должна равняться указанной длительности.

**Структура каждого шота:**
1. Timecode — `[Xs – Ys]`
2. Shot label — `SHOT N — [SCENE NAME]` (caps)
3. Shot type & camera — размер, угол, движение камеры
4. Scene direction — действие, блокинг, staging, environmental action, acting beats
5. Dialogue — `Character: "Line"`
6. SFX — sound effects и ambient audio
7. Camera direction — verb phrase (slow dolly-in, handheld tracking, orbit, push-in, etc.)

**Структура промпта:**
```
[Production header — reference image, consistency mandate, style block, focus block]

[SHOT 1 — timecode, label, full direction]

[SHOT 2 — timecode, label, full direction]

...

[Final shot — timecode, label, full direction]

Audio: Diegetic sound only — natural ambience, environmental foley, and subject-driven sound.
```

**Audio footer — ОБЯЗАТЕЛЬНЫЙ, финальная строка каждого видео промпта:**
`Audio: Diegetic sound only — natural ambience, environmental foley, and subject-driven sound.`
Каждый шот всё равно содержит свои SFX notes — эта строка устанавливает общую аудио-философию.

**Style adaptation для видео:**

| Style | Camera | Lighting | Acting |
|---|---|---|---|
| Live-action | handheld, Steadicam, crane, Dutch angle | practical sources, naturalistic, motivated | subtle performance, micro-expressions |
| 3D Animation | dolly, orbit, snap zoom, rack focus | warm practicals, volumetric, GI | squash & stretch, anticipation, follow-through |
| Anime | snap zooms, static holds, rapid cuts | bloom, dramatic shadows, particle effects | speed lines, impact frames, sakuga peaks |
| 2D Animation | fluid transitions, parallax | painterly, soft | smears, held poses, moving holds |

**Целевая длина видео промпта:**
- 9 шотов / 15 сек: 800–1 200 слов
- 15 шотов / 15 сек: 1 200–2 000 слов
- 15 шотов / 30 сек: 1 500–2 500 слов
- 20 шотов / 60 сек: 2 000–3 500 слов

После code block — **companion note** (3–5 предложений): pacing choices, шоты которые могут потребовать правки, предложения по аудио/музыке.

---

### Storyboard Variations

| Ситуация | Действие |
|---|---|
| Пользователь дал полный beat sheet | Маппить напрямую, не декомпозировать |
| Только логлайн | Показать beat breakdown перед генерацией — дать возможность скорректировать |
| Редактирование конкретных панелей | Регенерировать только нужные панели |
| Другое количество панелей | Скорректировать grid и перераспределить биты |
| Vertical (9:16) | Перевернуть grid: 5×3 вместо 3×5 |
| Конкретный видео инструмент | Адаптировать camera direction: Seedance=character animation, Kling=dynamic camera, Veo=long coherent sequences |
| Гибридный стиль | Явно обозначить в style block какие элементы следуют каким правилам |
