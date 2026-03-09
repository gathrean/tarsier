# Tarsier — Running Research & Strategy Notes

> **Last updated:** 2026-03-08  
> **Purpose:** Living document compiling all research, decisions, and open questions for Tarsier app development.

---

## 1. Market Landscape (iOS, as of early 2026)

### Competitor Summary Table

| App | Rating | Ratings | Price/mo | AI | Tagalog-only | Key weakness |
|-----|--------|---------|----------|-----|-------------|--------------|
| Rosetta Stone | 4.8 | ~235K | $10.50–15.99 | TruAccent speech | No (24 langs) | Overly formal, American-context photos |
| AirLearn | 4.8 | ~30K | Subscription | AI tutor + speech | No (29+ langs) | AI-generated art, Tagalog course new/shallow |
| Turong Wika | 4.8 | ~336 | Free–$11.99 | No | Yes | Tiny user base, no audio in some lessons |
| Mondly | 4.7 | ~30K | $4–9.99 | AR/VR/chatbot | No (41 langs) | Shallow Tagalog, minimal grammar |
| Pimsleur | 4.7 | ~24K | $14.95–20.95 | Voice Coach | No (51 langs) | Only 2 levels for Tagalog, formal register |
| Ling | 4.6 | ~13K | $14.99 | Chatbot/speech | No (70+ langs) | Translation errors, no grammar tips |
| Drops | ~4.6 | Moderate | $13 | No | No (45+ langs) | Zero grammar, zero conversation, 10hr cooldown |
| FilipinoPod101 | ~4.3 | Low (iOS) | $8–23 | No | Yes | Confusing UX, aggressive upselling |

### The Duolingo Void
- Tagalog is NOT on Duolingo. Duolingo discontinued its volunteer Incubator program that might have produced one.
- Duolingo offers Klingon and High Valyrian but not Tagalog — a talking point for marketing.
- Every competitor explicitly markets as a "Duolingo alternative for Tagalog."
- AirLearn recently added Tagalog (their changelog mentions it alongside Vietnamese, Telugu, Finnish).

---

## 2. What Users Hate (Recurring Complaints)

1. **Translation/content errors** — Native speakers flag inaccurate translations across Ling, Simply Learn, Drops. Words in wrong tense, unnatural phrasing.
2. **No grammar explanations** — The #1 gap. Tagalog's verb focus system, affixation, ang/ng/sa case markers are poorly taught everywhere. Users report needing to Google basic concepts like case markers.
3. **Overly formal language** — Rosetta Stone teaches "kapatid na babae" but never "ate." Apps teach textbook Tagalog that sounds unnatural to native speakers.
4. **Aggressive monetisation** — Users need 3-4 apps at $10-20/month each to cover all skills. Drops' 10-hour cooldown is universally hated.
5. **Insufficient depth** — Pimsleur has only 2 levels for Tagalog. Rosetta Stone after 30+ hours hadn't taught "know," "understand," or "help."

---

## 3. What Users Want

- Comprehensive grammar instruction built for Tagalog's verb focus system
- Word-by-word sentence breakdowns showing root words, affixes, and meaning
- Colloquial Taglish — not textbook formality
- Cultural context (po/opo, ate/kuya, social dynamics)
- Gamification (streaks, XP, leaderboards, daily challenges)
- Spaced repetition that adapts to weaknesses
- AI conversational practice for real scenarios
- Native speaker audio
- Short stories, role-play scenarios (ordering food, meeting family, palengke market)
- A comprehensive free tier (Duolingo-level generosity)
- One subscription covering all skills (not 3-4 separate apps)

---

## 4. Target Audience

### Primary: Heritage Learners (Filipino Diaspora)
- Filipino-Americans, Filipino-Canadians, Filipino-Australians, Filipino-British
- The universal phrase: "I understand it, but I can't speak it."
- Motivation is emotional: shame, identity, family reconnection
- They are passive bilinguals — comprehension exists, productive fluency doesn't
- Need to ACTIVATE passive knowledge, not learn from zero
- Filipino immigrant parents were told to speak only English to children
- 4.4 million Filipino-Americans in the U.S.
- TikTok is accelerating demand: #filipinoamerican has 21.4M+ posts
- "Bebot" trend (Feb 2026) celebrating Filipina identity went global
- 150% increase in cultural education program participation since 2015

### Secondary: Foreigners with Filipino Partners
- Practical conversational Taglish for family gatherings
- Expressing respect to elders (po/opo)
- Understanding family conversations
- Less interested in formal grammar, more in functional participation

### Tertiary: Filipinos Improving Formal Tagalog
- Smaller segment, less emotionally urgent

---

## 5. Filipino Family Titles — Cultural Nuances (from Ean)

### Kuya/Ate (older brother/sister) — beyond family
- Used for ANY older person as a sign of respect and warmth — not just siblings
- Calling a street vendor "Kuya" or a coworker "Ate" is normal and expected
- Parents call their own eldest kids "Kuya" and "Ate" so younger siblings learn the titles early
- This is a sign of respect for anyone older — foundational Filipino social behaviour

### Tito/Tita (uncle/aunt) — generation gap
- Used for any older adult a generation above you (parents' age range)
- Also used for family friends of your parents, even if not blood-related

### The age sensitivity rule
- **Kuya/Ate** = someone older but in your approximate generation (few years to ~15 years older)
- **Tito/Tita** = someone clearly a generation older
- **The grey zone:** If you're in your 20s and call someone in their 30s "Tito" or "Tita," it can feel disrespectful — it implies they're a generation older. Especially sensitive for women who may not appreciate being aged up. Defaulting to "Kuya/Ate" is safer and friendlier.
- This is situational awareness that no app currently teaches.

### Bunso (youngest)
- Used for the youngest child in a family
- Can be used for the youngest in any group, though less common outside family

### Teaching implication for Tarsier
- This is Lesson 9-10 material: family vocabulary + the social rules for using titles outside family
- The age sensitivity rule is a "cultural context" slide — the kind of thing heritage learners need but textbooks never cover

---

## 5b. Filipino Counting System — Three Languages for Numbers

### The reality (confirmed by native speaker + Medium article)
Filipinos code-switch across THREE languages for numbers:
- **Filipino (1-10 and round hundreds/thousands):** isa, dalawa, tatlo... sampu, isang daan, isang libo
- **Spanish (common price denominations):** bente (20), trenta (30), singkwenta (50), benchingko (25 centavos)
- **English (complex/exact amounts):** "one-twenty," "one-oh-two" — anything where Filipino or Spanish has too many syllables

### Key insight
- Almost nobody uses full Filipino numbers past 10 in daily speech ("dalawampu't limang sentimo" is too many syllables)
- The code-switching rule: Filipinos pick whichever language has the fewest syllables for that number
- This is a running cultural joke — ask a Filipino to count past 10 in Tagalog and watch them struggle
- Time telling also uses Spanish: "alas-otso" (8 o'clock), "alas-singko" (5 o'clock)

### Teaching implication for Tarsier
- Counting gets its own chapter (Ch 4, Lessons 13-14) — honest about the three-language reality
- Don't pretend Filipino counting is the "correct" way — teach all three systems and when each is used
- Perfect "Alam Mo Ba?" territory — the counting system is inherently fun and surprising for learners

---

## 6. The Taglish Paradox

**Critical design decision for Tarsier:**

- Taglish (Tagalog-English code-switching) is the default spoken language in Metro Manila and urban Philippines.
- Native speakers themselves struggle with "pure" Tagalog — it sounds old-fashioned.
- Apps teach formal Tagalog, but real conversation is Taglish.
- Community-recommended approach: learn formal structure first, then integrate Taglish patterns.

**Ean's key insight (validated by native speaker experience):**
> In real Taglish, the affixes are ALWAYS Tagalog. The root can be English. "nag-cook" is natural. "I nagluto ng adobo yesterday" is NOT natural. Correct Taglish: "nag-cook ako ng adobo yesterday" OR "nagluto ako ng food yesterday."

This is a teachable rule AND Tarsier's marketing hook. No LLM gets this right without native QA.

**Class dimension:** Heavy English mixing ("conyo" speech) is associated with wealthy educated Manila youth. Too much English with less-educated speakers risks being perceived as "pasosyal" (pretentious). No current app teaches register navigation.

---

## 6. Tarsier's Differentiator: Etymology & Affix System

Every other app teaches "luto means cook" as an isolated flashcard. Tarsier teaches:
- **luto** = root (cook)
- **magluto** = to cook (mag- prefix)
- **nagluto** = cooked (nag- prefix, past tense)
- **iluto** = cook it (i- prefix)
- **paluto** = have someone cook it (pa- prefix)

One root word → five usable words. Woven into every lesson, not a separate feature.

**UI differentiator:** Colour-coded affix decomposition.
- Blue (#0038A8) for prefixes/infixes/suffixes
- Warm brown (#7B5B3A) for root words
- Visual breakdown: `[nag]` `[luto]` with colour separation

**The Pacquiao TikTok angle:** "In Tagalog you can turn ANY word into a verb. Watch: Pacquiao. Pinacquiao ko yung exam ko — I Pacquiao'd my exam." This is a 15-second hook for millions of views.

---

## 7. App Structure (AirLearn + HelloChinese Hybrid)

### Macro: HelloChinese-style grouped roadmap
- 30 lessons grouped into 9 chapters of 2-4 lessons each
- Chapters organised by theme with affixes introduced organically
- Visual roadmap with nodes — completing a chapter unlocks the next
- Each chapter ends with an AI practice session (gated)

**Curriculum reorder (2026-03-08):** Po/respect comes FIRST, not food verbs. Starting with po is zero-grammar-barrier, immediately usable (even in English: "I didn't eat yet po"), and signals the app understands Filipino culture. Affixes don't appear until Chapter 2. See `tarsier_roadmap_v0.1.md` for full structure.

### Micro: AirLearn-style slide flow within each lesson
1. Cultural context slide (swipeable card)
2. Etymology/affix teaching slides (2-3 cards, colour-coded breakdowns)
3. Vocabulary slides (each word = one card, with photo, pronunciation, Taglish variant)
4. Sentence breakdown slides (full sentence, tappable word-by-word breakdown)
5. Quiz (4-6 questions testing what was just taught — costs hearts)
6. Summary card (roots learned, affixes learned, cultural takeaway)

**Key principle:** Steps 1-4 are TEACHING. Step 5 is TESTING. User never faces a quiz about something not yet explained.

### Organic Affix Introduction (Design Decision, 2026-03-08)
Affixes are NOT taught in isolation. They're introduced naturally within themed lessons:
- When a new affix appears for the first time, it's colour-coded (blue for affix, brown for root)
- A brief 1-2 line explanation appears in context ("You'll see this pattern again — it means past tense")
- Subsequent lessons reinforce the affix with new root words
- No lesson is titled "the mag- lesson" — it's "the cooking lesson where you learn mag-"
- Affix complexity builds gradually across the 30-lesson curriculum

### "Alam Mo Ba?" (Did You Know?) Boxes (Design Decision, 2026-03-08)
- Appear whenever a Spanish or American borrowed word is used in Tagalog
- Short, fun, 1-2 sentence cultural/linguistic fact
- NOT quizzed — purely enrichment, adds textbook personality
- Example: "'Kumusta' comes from Spanish '¿Cómo está?' — 333 years of colonisation left hundreds of words in Tagalog."
- Example: "'Jeepney' comes from American military jeeps left after WWII."
- These are the moments that make the app feel like it was written by a Filipino, not a language template

---

## 8. Gamification & Monetisation

### Hearts/Energy System
- Free users: 5 hearts per day (Duolingo standard)
- Lose 1 heart per wrong quiz answer
- Hearts refill over time OR by watching rewarded ad
- Reviewing completed lessons (re-reading teaching slides) = no hearts needed
- Premium users: unlimited hearts

### Streaks
- Free for everyone — retention hook
- Daily streak tracking (local, SwiftData)

### AI Practice (End of Chapter)
- Free users: 1 session per chapter OR watch ad for another
- Premium users: unlimited
- Scoped to chapter's vocabulary and grammar only
- Gemini Flash, system prompt constrained to lesson content

### Pricing
- $4.99/month or $29.99/year (hero)
- RevenueCat + Superwall
- Soft cap: 30 AI messages/day (hidden, marketed as unlimited)

### Ads
- Rewarded ads only (watch to refill hearts, watch for extra AI practice)
- Language learners used to ad-supported models from Duolingo — high tolerance
- No banner ads, no interstitials

---

## 9. Baybayin

### The Opportunity
- No existing app combines Tagalog learning with Baybayin instruction.
- All current Baybayin apps (Learn Baybayin, BaybayinPlus Keyboard, Baybayin Pro) treat it as standalone.
- Only 17 characters + diacritics — genuinely learnable in a few hours.
- TikTok: 6.5 million posts under "Philippines Baybayin."
- Philippine House of Representatives passed HB 10657 mandating Baybayin in education curricula.
- Baybayin appears on Philippine banknotes, passports, government logos.
- Tattoo trend is massive — people want to verify correct translations before getting inked.

### Implementation Strategy
- Cultural enrichment module, not a core pillar.
- "Write Your Name in Baybayin" feature = organic social sharing on TikTok/Instagram.
- Future scope (not v0.1).

---

## 10. Regional Philippine Languages (Future Expansion)

| Language | Speakers | Best Available App | Gap Level |
|----------|----------|-------------------|-----------|
| Cebuano | 18.5–28M | Ling (launched June 2025) | Moderate |
| Ilocano | 7.7–10M | uTalk (basic phrasebook) | High |
| Hiligaynon | 7–9.3M | Speakin' Ilonggo (missionary-built) | Critical |
| Kapampangan | ~2.6M | None | Critical |
| Waray | 3.1–3.7M | None | Critical |
| Bicolano | ~2.5M | None | Critical |
| Pangasinan | ~1.5M | None | Critical |

- Google recently added Hiligaynon, Kapampangan, Waray, Bikol, Pangasinan to Google Translate.
- Duolingo offers zero Philippine languages.
- Same heritage learner emotional driver applies to all regional languages.
- Potential expansion path: "Tarsier — Learn Cebuano," "Tarsier — Learn Ilocano," etc.

---

## 11. Design Direction

### Visual Strategy: "Fun Textbook" Hybrid
- Real photos for vocabulary cards and cultural context (textbook feel)
- Flat vector Tarsier mascot and UI chrome (modern app feel)
- Photos from: Wikimedia Commons (CC BY-SA, requires attribution screen), Unsplash/Pexels (no attribution required), Philippine government media libraries

### Photo Licensing Summary
| Source | Licence | Commercial use | Attribution required | Notes |
|--------|---------|---------------|---------------------|-------|
| Wikimedia Commons | CC BY-SA / CC BY / Public Domain | Yes | Yes (CC BY/BY-SA) | Best Filipino cultural content. Keep credits screen in Settings. |
| Unsplash | Unsplash License | Yes | No (appreciated) | Good general imagery, less Filipino-specific. |
| Pexels | Pexels License | Yes | No | Similar to Unsplash. |
| Pixabay | Pixabay License | Yes | No | Custom licence since 2019, still commercial-OK. |
| PH Dept of Tourism | Varies / Public Domain | Check per image | Check per image | Worth investigating for authentic Filipino imagery. |

### Colour Palette (Ube Purple + Filipino Identity)
**Decision (2026-03-08):** Pivoted from Philippine flag blue to ube purple as hero colour. Ube is becoming THE colour associated with Filipino identity globally (the new matcha). No major language app uses purple. Duolingo=green, Babbel=orange, HelloChinese=red, AirLearn=blue. Ube purple is instantly ownable.

- **Brand purple (light/background):** #8778C3 — icon background, screen accents, light fills, marketing
- **Functional purple (buttons/UI):** #6B5B9A — primary buttons, nav bars, progress bars (passes 4.5:1 contrast on white text)
- **Gold/Amber:** #FCD116 — rewards, XP, streaks, celebration, tarsier eyes
- **Tarsier dark:** #302B27 — mascot body, dark text alternative, near-black
- **Alert/Correction:** #CE1126 (flag red) — wrong answers, heart loss
- **Correct:** #2ECC71 — correct answer feedback
- **Cream:** #FFF5E6 — card backgrounds, warm canvas
- **Warm white:** #FAFAF7 — screen backgrounds
- **Typography:** SF Rounded

### Affix Colour-Coding in Lessons (Updated)
- Affixes (prefixes, infixes, suffixes): #6B5B9A (functional purple)
- Root words: #302B27 (tarsier dark) with brown underline accent

### Affix Colour-Coding in Lessons
- Affixes (prefixes, infixes, suffixes): #6B5B9A (functional purple)
- Root words: #302B27 (tarsier dark)
- These colours appear in etymology slides and sentence breakdowns

---

## 12. HelloChinese & AirLearn Design Benchmarks

### HelloChinese (what to take)
- ~50 units, each with 3-4 lessons, topics grouped in sets of 8
- Linear progression with shortcuts to skip groups
- Each module 5-10 minutes with high exercise variety (18-25 exercise types)
- Cultural intro page before each topic
- Grammar words highlighted in gold, tappable for detailed explanations
- "Teacher Talk" podcast episodes explaining confusing grammar
- Entire core "Learn" course is free (premium adds stories, games, immersive content)
- 2,000+ native speaker videos
- Pronunciation-first approach (first unit = pinyin/tones before vocabulary)

### AirLearn (what to take)
- "Learn first, practice next" — grammar/vocabulary/cultural context as slides before any quiz
- Clean, minimalist UI ("no overblown gamification or cluttered screens")
- Bite-sized slides within lessons
- AI tutor for conversational practice with real-time correction
- Linear chapter progression (locked until previous chapter complete or tested out)
- Hearts system, weekly XP leagues, streaks

### AirLearn (what to skip)
- AI-generated art (users call it "lazy and cheap")
- Hearts system that blocks lesson access entirely (Tarsier: allow re-reading teaching slides without hearts)
- Teaching too many new words at once (users complain about this)

### HelloChinese (what to skip for v0.1)
- Character writing exercises (not relevant for Latin script Tagalog — but Baybayin tracing fits this slot later)
- "Test out of chapters" placement test (add later)
- Stories section (add in future version)
- Immersive video content (add when budget allows)

---

## 13. Mascot: Tarsier

### Current Direction (Updated 2026-03-08)
- **Style:** Simplified flat solid silhouette, thick-line, holding a pencil
- **Body:** Dark charcoal #302B27 — NOT brown, NOT black
- **Eyes:** Gold/amber #FCD116 with small dark pupil — the signature feature at any size
- **Pencil:** Ube purple #8778C3 body with cream/gold tip
- **Pose:** Bottom-left variant from ChatGPT explorations — sitting, curled tail, horizontal pencil
- **App icon composition:** Ube purple background → dark tarsier → gold eyes. Three layers, maximum contrast.
- **Key principle:** At 60px home screen size, it reads as "gold eyes on purple" — that's the entire visual identity
- **Next step:** Ean redraws in Figma with more pointed tarsier ears (vs cat ears), simplified paw shapes. Send to Rye for focused feedback.

### Filipino Animal Mascot Alternatives (researched)
- **Tarsier** — current pick, strongest option
- **Philippine mouse-deer (pilandok)** — tiny, sweet, less visually distinctive
- **Palawan otter** — playful, round face
- **Maya (Eurasian tree sparrow)** — deeply nostalgic for Filipinos, but SKIP (no birds — Duolingo owns that space)
- **Carabao (water buffalo)** — iconic but not "cute mascot" energy
- **Philippine eagle** — majestic but bird = Duolingo association

### Open question: other Filipino animals for supporting characters?
- Could introduce secondary characters in future versions (e.g., a pilandok as a quiz helper, a firefly/alitaptap for streak celebrations)

---

## 14. Account Creation

### Decision: No accounts in v0.1
- Per Mau's playbook: skip authentication, reduce friction, save costs
- Store everything on-device (SwiftData)
- Phone switching is a niche edge case
- Future scope: optional account for cross-device sync, leaderboards, social features
- If/when added: Apple Sign In + Google Sign In, no email/password

---

## 17. Open Questions

- [x] ~~Lesson 2: stay in food domain or jump?~~ → Resolved: Po/respect comes FIRST (Ch 1), food is Ch 2
- [x] ~~Exact chapter groupings for all 30 lessons~~ → See `tarsier_roadmap_v0.1.md`
- [x] ~~Affixes in isolation vs organic?~~ → Resolved: Organic introduction within themed lessons
- [ ] Baybayin module scope and timeline (v0.3? v0.5?)
- [ ] Rye involvement timeline for mascot creative direction
- [x] ~~SaaS landing page domain~~ → **tarsierlearn.com** available at CA$15/year on Namecheap. Best option. tarsier.com is for sale (GoDaddy, absurd price). tarsier.app is taken (offer only). tarsierapp.com is taken (offer only). Fallbacks: gathrean.com/tarsier for v0.1.
- [x] ~~Ad network~~ → **Google AdMob** for rewarded video ads. Broadest fill, best docs, Firebase analytics integration. Add mediation (AppLovin MAX) later when scaling.
- [ ] Singular.net for attribution (per Mau's stack) — worth the $0.05/conversion?
- [ ] PostHog vs. simpler analytics for v0.1
- [ ] Filipino mascot alternatives beyond tarsier for supporting characters
- [ ] Native speaker audio source — record yourself? Hire voice talent? TTS for v0.1?
- [ ] Photo curation: build a spreadsheet of Wikimedia Commons image URLs per lesson?

---

## 18. Related Documents

- `tarsier_roadmap_v0.1.md` — Full 30-lesson roadmap with chapter structure, affix progression, and "Alam Mo Ba?" notes
- `tarsier_lesson_001_v0.2.json` — Sample lesson JSON template (lesson 5 in new roadmap — was lesson 1 before po/respect reorder)
- `Tarsier_Context.md` — Original context doc (architecture, branding, naming decisions)
- `Tagalog_Learning_Apps__A_Fragmented_Market_With_Massive_Gaps.md` — Deep research report on competitive landscape
