# Tarsier Lesson Syntax Spec

Version 1.0 | 2026-03-19

Reference document for writing all Tarsier lesson content. Every lesson JSON must follow one of the three structures defined here.

---

## Core Principles

- One session per lesson. The session IS the lesson.
- Chapter progress replaces per-lesson progress rings (e.g. 7/10 lessons complete).
- Max 3 new vocabulary words per teaching lesson.
- Every new word must appear in at least 2 cards before it shows up in a quiz.
- Quiz cards should feel like a real situation, not a vocab drill.
- Teach cards: one idea per card, max 2 sentences for `body`.
- One `alam_mo_ba_inline` per lesson max (optional).
- Progressive substitution: Tagalog words appear only after being explicitly taught. Untaught words stay in English.

---

## Three Lesson Types

### 1. Teaching Lesson (8-12 cards)

The standard lesson. Introduces 1-3 new words/concepts.

**Card sequence:**

| Position | Card Type | Purpose |
|----------|-----------|---------|
| 1 | teach (hook) | One sentence framing why this matters or connecting to prior knowledge |
| 2 | teach | Introduce word/concept A with example |
| 3 | teach | Introduce word/concept B with example (or deepen A) |
| 4 | quiz | Test A or B |
| 5 | teach | Introduce word/concept C, or show A+B used together |
| 6 | quiz | Test the new combination |
| 7 | teach (optional) | One more concept or a natural conversation example |
| 8 | quiz | Sentence build or contextual choice combining everything from this lesson |

**Rules:**
- Hook card sets context. No quiz content, no vocabulary. Just "here's why you want to know this."
- Teach-quiz-teach-quiz rhythm. Never stack more than 3 teach cards without a quiz.
- Final quiz should be the hardest (sentence_build or contextual multiple_choice).
- `character` field on quiz cards grounds the scenario (lola, pare, boss, stranger, bunso).

**JSON structure:**

```json
{
  "_meta": {
    "schema_version": "0.7",
    "last_updated": "YYYY-MM-DD",
    "notes": ""
  },
  "lesson_id": "NNN",
  "title": "Lesson Title",
  "subtitle": "Short description",
  "chapter_id": "chNN",
  "chapter_title": "Chapter Name",
  "position_in_chapter": N,
  "difficulty": "beginner",
  "lesson_type": "teaching",
  "total_sessions": 1,
  "sessions": [
    {
      "session_id": "NNN_s1",
      "session_number": 1,
      "title": "Session Title",
      "cards": []
    }
  ],
  "vocabulary": [],
  "wrong_answer_tracking": {
    "behaviour": "Wrong answers go to back of current session queue. User must get ALL questions right to complete. Cannot finish lesson with outstanding wrong answers.",
    "track_wrong_count": true,
    "wrong_count_usage": "Feed to Gemini system prompt for AI Practice."
  },
  "completion_reward": {
    "xp": 15,
    "alam_mo_ba": []
  },
  "gamification": {
    "xp_per_lesson": 15,
    "hearts_per_wrong_answer": 1,
    "streak_eligible": true,
    "replay": {
      "allowed": true,
      "xp_on_replay": 0
    }
  }
}
```

---

### 2. Review Lesson (6-10 cards)

Appears every 2-3 teaching lessons. Reinforces recent material.

**Card sequence:**

| Position | Card Type | Purpose |
|----------|-----------|---------|
| 1-N | quiz | Mixed types (multiple_choice, fill_in_blank, sentence_build), pulling from previous 2-3 lessons |

**Rules:**
- All quiz cards. No teach cards.
- Mixed quiz types. Shuffled order.
- Pulls vocabulary and scenarios from the 2-3 teaching lessons immediately before it.
- Uses the same `character` cast but in new scenarios.
- Completion reward Alam Mo Ba still fires.

**JSON differences from teaching:**
- `"lesson_type": "review"`
- `"xp_per_lesson": 20` (slightly more XP as reward for reviewing)
- No `vocabulary` array (references prior lessons' vocab)

---

### 3. Chapter Review (8-14 cards)

Last lesson in every chapter. Optional but rewarded. Covers everything in the chapter.

**Card sequence:**

| Position | Card Type | Purpose |
|----------|-----------|---------|
| 1 | teach (connection) | Shows how concepts from different lessons connect (e.g. "Notice how po works with kumusta AND salamat") |
| 2-5 | quiz | Mixed types covering early chapter material |
| 6 | teach (connection, optional) | Another cross-lesson insight |
| 7-12 | quiz | Mixed types covering mid-to-late chapter material, increasing difficulty |
| 13-14 | quiz | Hardest questions, sentence_build or multi-concept scenarios |

**Rules:**
- 1-2 teach cards that are connection cards (not new content, just showing patterns across lessons).
- Quiz cards pull from ALL teaching lessons in the chapter.
- Final 2-3 quizzes should combine concepts from different lessons.
- Higher XP reward.
- Labelled "Chapter Review" on the roadmap (with halo-halo image).

**JSON differences from teaching:**
- `"lesson_type": "chapter_review"`
- `"xp_per_lesson": 30`
- Position is always last in chapter

---

## Card Type Reference

### Teach Card

```json
{
  "card_id": "NNN_s1_cN",
  "type": "teach",
  "body": "One idea. Max 2 sentences.",
  "highlight": "Optional bold/large text above body",
  "example": {
    "casual": "Casual version",
    "with_po": "Respectful version",
    "note": "Brief context"
  },
  "alam_mo_ba_inline": {
    "term": "Term",
    "fact": "One sentence fun fact.",
    "emoji": "relevant emoji"
  }
}
```

- `highlight`: optional. Use for the key word/phrase being introduced.
- `example`: optional. Multiple formats allowed (casual/with_po, context/sentence/translation, or freeform).
- `alam_mo_ba_inline`: optional. Max 1 per lesson.

### Character Intro Card

```json
{
  "card_id": "NNN_s1_intro_NAME",
  "type": "character_intro",
  "character": "character_key",
  "text": "Meet [name]! One sentence about who they are.",
  "fun_fact": "One sentence cultural context."
}
```

- Use sparingly. Only when a character first appears in the curriculum.

### Connection Card (Chapter Review only)

```json
{
  "card_id": "NNN_s1_conn_N",
  "type": "teach",
  "subtype": "connection",
  "body": "Insight connecting concepts across lessons.",
  "highlight": "Optional"
}
```

### Quiz: Multiple Choice

```json
{
  "card_id": "NNN_s1_qN",
  "type": "quiz",
  "quiz_type": "multiple_choice",
  "character": "character_key",
  "source_text": "What the character says to set the scene.",
  "prompt": "Optional clarifying question if source_text alone is ambiguous.",
  "options": ["A", "B", "C", "D"],
  "correct_answer": 0,
  "explanation": "Why this answer is right. One sentence.",
  "shuffle_options": true
}
```

- `character`: who is speaking/setting the scene (lola, lolo, pare, mare, bunso, tita, boss, stranger).
- `source_text`: the in-scene dialogue. Written as if the character is talking to the user.
- `correct_answer`: 0-indexed position BEFORE shuffling.
- Always 4 options.

### Quiz: Fill in Blank

```json
{
  "card_id": "NNN_s1_qN",
  "type": "quiz",
  "quiz_type": "fill_in_blank",
  "character": "character_key",
  "source_text": "Scene-setting line from character.",
  "prompt": "What the user needs to type.",
  "correct_answers": ["Answer", "answer", "alternate"],
  "explanation": "Why. One sentence."
}
```

- `correct_answers`: array of all acceptable answers (case variations, alternate spellings).

### Quiz: Sentence Build

```json
{
  "card_id": "NNN_s1_qN",
  "type": "quiz",
  "quiz_type": "sentence_build",
  "character": "character_key",
  "prompt": "Context for the sentence.",
  "source_text": "What the character said (to reply to).",
  "correct_order": ["Word", "order", "here"],
  "distractors": ["wrong", "words"],
  "explanation": "Why this order. One sentence."
}
```

- `correct_order`: the words in correct sequence. User taps pills to build.
- `distractors`: 2-3 extra words that don't belong.

---

## Vocabulary Array

Top-level array listing all new words introduced in the lesson.

```json
"vocabulary": [
  {
    "word": "kumusta",
    "meaning": "how are you",
    "pronunciation": "koo-MOOS-tah",
    "type": "greeting"
  }
]
```

- `type`: word, phrase, particle, greeting, expression, etc.
- Only words FIRST TAUGHT in this lesson. Don't re-list words from prior lessons.
- Empty array for review and chapter review lessons.

---

## Completion Reward

```json
"completion_reward": {
  "xp": 15,
  "alam_mo_ba": [
    "Fun fact 1.",
    "Fun fact 2.",
    "Fun fact 3."
  ]
}
```

- Teaching lessons: 15 XP, 3-5 fun facts (1 shown randomly).
- Review lessons: 20 XP, 2-3 fun facts.
- Chapter Review: 30 XP, 3-5 fun facts.

---

## Chapter 1: Hello

Words per chapter displayed on chapter page (AirLearn-style).

| # | Lesson ID | Title | Type | New Words | Cumulative |
|---|-----------|-------|------|-----------|------------|
| 0 | 000 | The Abakada | teaching (intro) | 0 | 0 |
| 1 | 001 | How Are You? | teaching | 3 (kumusta, mabuti, ikaw) | 3 |
| 2 | 002 | Good Morning! | teaching | 3 (magandang, umaga, gabi) | 6 |
| 3 | 003 | Po | teaching | 2 (po, sige) | 8 |
| 4 | 004 | Review | review | 0 | 8 |
| 5 | 005 | Opo, Yes, No | teaching | 3 (opo, oo, hindi) | 11 |
| 6 | 006 | Salamat | teaching | 3 (salamat, walang anuman, pasensya) | 14 |
| 7 | 007 | Review | review | 0 | 14 |
| 8 | 008 | Me and You | teaching | 3 (ako, ikaw/ka, siya) | 17 |
| 9 | 009 | Us and Them | teaching | 3 (kami/tayo, kayo, sila) | 20 |
| 10 | 010 | Chapter Review | chapter_review | 0 | 20 |

**Chapter 1 summary: 10 lessons, ~20 words**

Note: Lesson 000 (The Abakada) is Chapter 0 / Introduction, shown after onboarding completes. The chapter page for Chapter 1 starts at lesson 001.

---

## Naming Conventions

- Lesson IDs: three-digit zero-padded (000, 001, 002...).
- Session IDs: `{lesson_id}_s1` (always s1 since total_sessions is always 1 now).
- Card IDs: `{lesson_id}_s1_c{N}` for teach cards, `{lesson_id}_s1_q{N}` for quiz cards.
- Character intro cards: `{lesson_id}_s1_intro_{character_key}`.
- Connection cards: `{lesson_id}_s1_conn_{N}`.
- Files: `lesson_{NNN}.json` (e.g. `lesson_001.json`).
