# Tarsier — Learn Tagalog | v0.1 MVP TODO

> **App Name:** Tarsier  
> **Tagline:** Tarsier — learn Tagalog  
> **Target:** 2-week build  
> **Stack:** SwiftUI, SwiftData, Gemini API, Superwall, RevenueCat  
> **Architecture:** Local-first, no auth, no backend  

---

## Project Setup

- [ ] Create new Xcode project: `Tarsier`
- [ ] Minimum deployment target: iOS 17.0
- [ ] Add SPM dependencies:
  - RevenueCat
  - Superwall
  - GoogleGenerativeAI (Gemini Swift SDK)
- [ ] Set up project folder structure:
  - `/Models`
  - `/Views`
  - `/ViewModels`
  - `/Services`
  - `/Resources` (lesson JSON files)
  - `/Theme`
- [ ] Configure app icon placeholder (tarsier mascot on Philippine blue #0038A8)
- [ ] Set up colour palette in asset catalogue:
  - `tarsierBlue` — #0038A8 (primary brand, Philippine flag blue)
  - `tarsierYellow` — #FCD116 (reward/celebration accent, Philippine flag yellow)
  - `tarsierRed` — #CE1126 (alert/correction accent, Philippine flag red)
  - `tarsierBrown` — #7B5B3A (mascot/warm accent)
  - `tarsierCream` — #FFF5E6 (soft backgrounds, card fills)
- [ ] Set up SF Rounded as the primary typeface (consistent with ScheDue approach)

---

## Data Models (SwiftData)

### UserProfile
- `id: UUID`
- `skillLevel: SkillLevel` (enum: beginner, intermediate, heritage)
- `currentLessonIndex: Int`
- `completedLessonIDs: [Int]`
- `currentStreak: Int`
- `longestStreak: Int`
- `lastCompletedDate: Date?`
- `createdAt: Date`

### SkillLevel Enum
- `beginner` — never studied Tagalog, starting from zero
- `intermediate` — knows basic phrases, wants to build structure
- `heritage` — understands spoken Tagalog, can't construct sentences or read

### LessonResult
- `id: UUID`
- `lessonID: Int`
- `score: Int` (number correct out of total quiz questions)
- `completedAt: Date`

---

## Lesson Data Structure (Bundled JSON)

### Lesson JSON Schema

Each lesson is a JSON file bundled with the app in `/Resources/Lessons/`. No API calls needed for core lessons.

```json
{
  "id": 1,
  "tier": "beginner",
  "topic": "Greetings & Politeness",
  "cultural_note": "Filipinos greet elders with 'po' and 'opo' — these aren't just formality, they signal respect and warmth. Skipping them with a lola or tito is like calling your boss 'dude'.",
  "etymology": {
    "focus": "The root word 'galang' (respect)",
    "explanation": "Magalang means respectful (mag- + galang). You'll see mag- turn roots into adjectives describing a person's quality. Galang → magalang. Ganda (beauty) → maganda. This pattern unlocks dozens of words.",
    "pattern": "mag- + root = adjective (describes a quality)",
    "examples": [
      {"root": "galang", "derived": "magalang", "meaning": "respectful"},
      {"root": "ganda", "derived": "maganda", "meaning": "beautiful"},
      {"root": "bait", "derived": "mabait", "meaning": "kind/good"}
    ]
  },
  "vocabulary": [
    {
      "tagalog": "Kumusta",
      "english": "How are you",
      "pronunciation": "koo-moo-STA",
      "example_sentence": "Kumusta ka na?",
      "example_translation": "How are you now?"
    }
  ],
  "sentences": [
    {
      "tagalog": "Kumusta po kayo?",
      "english": "How are you? (formal/respectful)",
      "breakdown": "Kumusta (how are you) + po (respect marker) + kayo (you, plural/formal)"
    }
  ],
  "quiz": [
    {
      "type": "multiple_choice",
      "question": "What does 'magalang' mean?",
      "options": ["beautiful", "respectful", "kind", "tall"],
      "correct_index": 1
    },
    {
      "type": "fill_in_blank",
      "question": "mag- + ganda = ___",
      "answer": "maganda",
      "hint": "It means beautiful"
    },
    {
      "type": "translate",
      "question": "How do you say 'How are you?' formally?",
      "answer": "Kumusta po kayo?",
      "accept_also": ["Kumusta po kayo", "kumusta po kayo"]
    },
    {
      "type": "root_pattern",
      "question": "If 'bait' means kindness, what does 'mabait' likely mean?",
      "options": ["unkind", "kind", "kindness itself", "to be kind to someone"],
      "correct_index": 1,
      "explanation": "ma- + root = having that quality. Mabait = kind."
    }
  ]
}
```

### Lesson Curriculum Overview (30 lessons, 3 tiers of 10)

**Beginner Tier (Lessons 1–10):**
1. Greetings & Politeness (po/opo, mano)
2. Introductions (Ako si..., Taga-... ako)
3. Numbers 1–20
4. Family Terms (nanay, tatay, kuya, ate, tito, tita, lola, lolo)
5. Common Verbs I — mag- prefix (magluto, maglinis, maglaro)
6. Food & Eating (kain tayo, kanin, ulam, meryenda)
7. Basic Adjectives — ma- prefix (maganda, mabait, malaki, maliit)
8. Question Words (ano, sino, saan, kailan, bakit, paano)
9. Time & Days (ngayon, bukas, kahapon, araw ng linggo)
10. Common Phrases & Filler Words (naman, ba, daw, kasi, pala)

**Intermediate Tier (Lessons 11–20):**
11. Verb Focus: -um- infix (kumain, umalis, tumakbo)
12. Verb Focus: nag-/nag-...-an past tense
13. Verb Focus: i- prefix (iluto, ibigay, itapon)
14. Directions & Places (kanan, kaliwa, doon, dito)
15. Shopping & Money (magkano, mahal, mura, bayad)
16. Feelings & Emotions (masaya, malungkot, galit, takot)
17. Verb Focus: pa- prefix (paluto, pasulat — causative)
18. Connectors & Sentence Building (pero, kaya, dahil, para)
19. Taglish in Practice (natural code-switching patterns)
20. Weather, Nature & Surroundings (ulan, araw, dagat, bundok)

**Heritage Tier (Lessons 21–30):**
21. Deep Affix Stacking (-in + -an, pag- + -in, pinag-)
22. Formal vs Casual Register
23. Regional Variations (common Bisaya/Ilokano loanwords)
24. Filipino Humour & Wordplay (puns, beki speak basics)
25. Expressing Complex Opinions (sa tingin ko, para sa akin)
26. Proverbs & Sayings (salawikain — kasabihan)
27. Storytelling Structure (noong, bigla, kaya naman)
28. Respectful Disagreement & Negotiation
29. Text/Chat Tagalog (po-less texting, abbreviations, jejemon history)
30. Idiomatic Expressions (tamad, pasaway, makulit, gigil, kilig)

> **NOTE:** Ean writes/QAs all 30 lessons. Use Gemini as co-author during content creation, but final review is manual. Focus on natural Taglish usage, not textbook formal Filipino.

---

## Views

### Onboarding Flow (3 screens max)
- [ ] **Screen 1 — Welcome:** Tarsier mascot + "Tarsier — learn Tagalog" + "Get Started" button
- [ ] **Screen 2 — Skill Level Picker:** Three cards — Beginner / Intermediate / Heritage Speaker. Each with a one-line description. Single select → saves to UserProfile.
- [ ] **Screen 3 — Motivation:** "Why are you learning Tagalog?" (optional, one-tap multi-select: reconnect with family, travel, partner is Filipino, general interest, other). Not gating — informational for future personalisation. → Navigates to home.

### Home Screen
- [ ] Top section: streak counter (flame icon + day count) + current lesson number
- [ ] Lesson list: vertical scroll of lesson cards, locked/unlocked state based on progress
- [ ] Each card shows: lesson number, topic title, completion checkmark if done
- [ ] Lessons unlock sequentially (complete lesson N to unlock N+1)
- [ ] "Practice with Tarsier" button (premium badge) — fixed at bottom or in tab bar

### Lesson View
- [ ] Cultural note card at top (collapsible, starts expanded)
- [ ] Etymology / affix breakdown section with the root → derived word examples
- [ ] Vocabulary cards (swipeable or scrollable, Tagalog front → tap to reveal English + pronunciation + example)
- [ ] Example sentences with word-by-word breakdown
- [ ] "Start Quiz" button at bottom

### Quiz View
- [ ] Progress bar at top (question X of Y)
- [ ] Supports 4 question types:
  - **Multiple choice** — 4 options, tap to select
  - **Fill in the blank** — text input field, soft-match on answer (case-insensitive, ignore accents)
  - **Translate** — text input, accept multiple valid answers from `accept_also` array
  - **Root pattern** — multiple choice but specifically tests affix understanding, shows explanation on answer
- [ ] Correct answer: green flash + brief explanation if available
- [ ] Incorrect answer: red flash + show correct answer + explanation
- [ ] End screen: score (X/Y correct), streak updated if ≥1 lesson completed today, "Continue" button returns to home

### Practice with Tarsier (Premium — AI Conversation Mode)
- [ ] Chat-style interface
- [ ] User types a situation or question in English (e.g., "How do I ask my tita if she's eaten yet?")
- [ ] Gemini API call with system prompt:
  ```
  You are Tarsier, a friendly Tagalog language tutor. The user is learning Tagalog.
  When they describe a situation or ask how to say something:
  1. Give the Tagalog phrase
  2. Give a pronunciation guide
  3. Break down the grammar (identify roots and affixes)
  4. Give a cultural context note if relevant
  5. Suggest a natural Taglish alternative if applicable
  Keep responses concise and warm. Use casual, encouraging tone.
  ```
- [ ] Response rendered as a styled card (not plain text)
- [ ] Conversation history persisted locally (SwiftData) per session
- [ ] Gated behind Superwall paywall

### Settings Screen
- [ ] Change skill level (resets lesson progress — confirm dialog)
- [ ] Manage subscription (opens RevenueCat management)
- [ ] Reset progress (confirm dialog)
- [ ] App version
- [ ] Privacy policy link
- [ ] Feedback/contact email

---

## Streak Logic

- [ ] Completing ≥1 lesson in a calendar day counts as an active streak day
- [ ] Streak increments if `lastCompletedDate` was yesterday or today
- [ ] Streak resets to 0 if `lastCompletedDate` was more than 1 day ago
- [ ] `longestStreak` updates whenever `currentStreak` exceeds it
- [ ] Streak display: flame icon + number on home screen
- [ ] Streak maintained check runs on app launch and on lesson completion

---

## Monetisation

- [ ] Add RevenueCat SDK — configure product IDs
- [ ] Add Superwall SDK — configure paywall
- [ ] Product offerings:
  - Monthly: $4.99/month
  - Annual: $29.99/year (hero, displayed as ~$2.49/month)
- [ ] Free tier includes: full 30-lesson curriculum, streak tracking, all quizzes
- [ ] Premium unlocks: "Practice with Tarsier" AI conversation mode
- [ ] Paywall trigger: when user taps "Practice with Tarsier" button
- [ ] Soft cap on AI conversations: 30 messages/day (hidden, marketed as unlimited)

---

## Gemini API Integration

- [ ] Only used for "Practice with Tarsier" premium feature
- [ ] Model: Gemini Flash (cost-efficient for conversational responses)
- [ ] API key stored in config (not hardcoded)
- [ ] System prompt defined in `/Services/TarsierAIService.swift`
- [ ] Response parsed and rendered as styled card in chat view
- [ ] Error handling: if API fails, show friendly "Tarsier is sleeping, try again" message
- [ ] Soft rate limit: 30 messages per calendar day per device (tracked in SwiftData)

---

## What's NOT in v0.1 (Parked for v0.2+)

- Speech recognition / pronunciation scoring
- Audio playback of vocabulary (text-to-speech or recorded)
- Leaderboards / social features
- XP / points system
- Hearts / lives mechanic
- Home screen widgets
- Push notifications (v0.2 priority — streak reminders)
- Tarsier mascot animations / emotional reactions
- Story mode / conversation-based lessons
- Spaced repetition review system
- Offline indicator for AI mode
- Multiple lesson formats (listening, speaking, matching)
- Onboarding tutorial walkthrough
- Share progress / social media sharing
- iPad-specific layout
- Accessibility (VoiceOver, Dynamic Type) — should be revisited before public launch

---

## Pre-Launch Content Work (Ean — not Claude Code)

- [ ] Write/QA all 30 lesson JSON files using Gemini as co-author
- [ ] Review every vocabulary word, example sentence, and quiz answer for natural Taglish
- [ ] Ensure etymology sections build progressively (mag- before nag- before -in before pa-)
- [ ] Test quiz answers — confirm all `accept_also` variations are reasonable
- [ ] Finalise mascot asset for app icon (Figma → SVG → Icon Composer)
- [ ] Set up RevenueCat project + Superwall project in dashboards
- [ ] Register App Store Connect entry for "Tarsier — Learn Tagalog"

---

## Ship Criteria

- [ ] User can complete onboarding and reach home screen
- [ ] User can progress through all 30 lessons sequentially
- [ ] Quiz scoring works correctly for all 4 question types
- [ ] Streak tracks and resets correctly across days
- [ ] Paywall appears when tapping "Practice with Tarsier"
- [ ] Premium AI conversation mode works end-to-end
- [ ] App icon and launch screen reflect Tarsier branding
- [ ] No crashes on iPhone 14/15/16 range
- [ ] App Store metadata ready (screenshots, description, keywords)
