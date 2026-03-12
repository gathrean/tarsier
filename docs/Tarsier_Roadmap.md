# Tarsier Lesson Roadmap

> **Last updated:** 2026-03-11  
> **Status:** Approved by Ean  
> **Structure:** Two-level hierarchy. Chapters → Lessons. Each lesson has 5 sessions internally (progress ring). Roadmap shows lessons as circles in rows of 1-2.

---

## Versioning

- **v1.0** — App Store launch. Chapters 1-10 (32 lessons). Full app: hearts, XP, streaks, AI practice, AdMob, Superwall, RevenueCat.
- **v1.1, v1.2** — Bug fixes, onboarding iteration, analytics-driven tweaks.
- **v2.0** — Content expansion: Tanong, Hugis ng Salita, Kultura.
- **v3.0** — Content expansion: Kalye, Trabaho, Kwento.
- **v4.0** — Content expansion: Malalim, Baybayin.

Users never see version numbers. The roadmap just grows. No "coming soon" placeholders. It ends where the content ends.

---

## Minimum Viable Launch (v1.0 App Store submission)

Ship when Chapters 1-3 are fully written and QA'd (Magalang, Taglish, Kain = 10 lessons). Everything else:
- Roadmap shows all v1.0 chapters but locks content past what's written
- Keep writing lessons 11-32 while app is in review and post-launch
- Real user data from first 10 lessons informs how remaining 22 are written

---

## Onboarding Flow (Mau's Playbook)

The user should complete their first lesson BEFORE seeing the home screen. Onboarding IS the first lesson.

1. **Open app** → Tarsier mascot, "Learn Tagalog," Get Started button
2. **"How much Tagalog do you know?"** → three cards (None / Some — I understand but can't speak / Conversational)
3. **"Why are you learning?"** → pills (Connect with family / Cultural pride / Travel / Partner / Just curious)
4. **Straight into Po & Opo Session 1** → no home screen yet. User goes directly from motivation picker into the first teach card. They learn po, answer their first quiz, feel progress.
5. **Session 1 complete** → progress ring animates 0/5 → 1/5, Alam Mo Ba fun fact, +15 XP. User feels accomplished.
6. **NOW show the home screen** → roadmap appears with Po & Opo showing 1/5 progress. User sees the whole journey ahead. This is the "wow" moment.
7. **Paywall triggers on a natural gate** → NOT after session 1. Wait until AI Practice node (end of Chapter 1) or when hearts run out. User has experienced value before being asked for money.

**Target metric:** 10% download-to-trial conversion. Iterate onboarding until this is hit. Below 10%, don't spend on paid ads. Above 10%, start $20/day TikTok.

---

## Marketing Timeline

### Now (while building)
- Build in public on TikTok/Instagram Reels
- "I'm building the Tagalog Duolingo that Duolingo won't make"
- Pacquiao verb example as a standalone video (test the hook)
- "Did you know Filipinos count in three languages?" (Alam Mo Ba as content)
- Screen recordings of the app as dev journey content
- Post in r/Tagalog, r/languagelearning, r/Filipino

### Launch week (v1.0 on App Store)
- "It's live. Link in bio."
- Contact ScheDue survey respondents (9 emails, 12 Instagram handles)
- Rye reviews launch post for maximum impact

### Post-launch (organic grind)
- One platform (TikTok), one format, high volume
- **Reaction hook:** "Wait, you can turn Pacquiao into a VERB?!" + screen recording
- **Heritage hook:** "POV: you finally understand why your nanay says po"
- **Education hook:** Alam Mo Ba facts as standalone videos
- Target: 10k views/day → 200-300 downloads/day
- Once 10% conversion hit: $20/day TikTok ads, broad US targeting

---

## Recurring Lesson Elements

### Colour-Coding System
- New words/affixes highlighted on first appearance
- Affixes: **#6B5B9A** (functional ube purple)
- Root words: **#302B27** (tarsier dark)
- Subsequent appearances fade to normal text

### "Alam Mo Ba?" — Two Types
1. **Inline** (during lessons): contextual tooltip explaining Filipino-specific terms for non-Filipino users. Small ube-tinted row above Check/Continue button. Optional `emoji` field.
2. **Completion reward** (end of lesson): 1 random fun fact shown when progress ring fills. Different fact on replay. 3-5 facts per lesson.

### Taglish Reality Notes
- Every lesson includes natural Taglish variants
- Rule: affixes are always Tagalog, roots/nouns can be English
- Register awareness taught organically

### Quiz Types
1. **Multiple choice** — 4 options, shuffle on display
2. **Fill in blank** — text input, case-insensitive match
3. **Translate** — text input, multiple accepted answers
4. **Root pattern** — multiple choice testing affix understanding
5. **Word order** — drag/tap word pieces to build a sentence. Wrong = shake + rearrange.

### Session Structure
- Each lesson = 5 sessions, shown as a progress ring
- Each session = teach small → quiz → teach small → quiz (interleaved)
- Wrong answers go to back of current session queue
- User must get ALL right to complete session
- Wrong count tracked per question for Gemini AI practice prompting
- Replay allowed (0 XP)

---

## Roadmap Layout

```
MAGALANG — Respect & Greetings
  [Po & Opo]                              ← row of 1
  [Kumusta]  [Oo, Hindi, Salamat]         ← row of 2
  [Ako, Ikaw, Siya]                       ← row of 1
  (Practice)

TAGLISH — How Filipinos Actually Talk
  [The Mix]                               ← row of 1
  [Any Word Is a Verb]                    ← row of 1
  (Practice)

KAIN! — Food & Basic Verbs
  [Kain]                                  ← row of 1
  [Luto]  [Inom]                          ← row of 2
  [Gusto & Ayaw]                          ← row of 1
  (Practice)

PAMILYA — Family & Relationships
  [Nanay & Tatay]  [Lola & Lolo]          ← row of 2
  [Mahal]  [Tahanan]                      ← row of 2
  (Practice)

BILANG — Counting & Money
  [Filipino Numbers]                       ← row of 1
  [Money & Spanish Numbers]                ← row of 1
  (Practice)

ARAW-ARAW — Daily Routines
  [Umaga]                                 ← row of 1
  [Trabaho]  [Linis & Ayos]               ← row of 2
  [Pahinga]                               ← row of 1
  (Practice)

DAMDAMIN — Feelings & Descriptions
  [Masaya & Malungkot]                    ← row of 1
  [Maganda & Gwapo]  [Mainit & Malamig]   ← row of 2
  [Pagod & Gutom]                         ← row of 1
  (Practice)

LUGAR — Places & Getting Around
  [Saan]                                  ← row of 1
  [Punta]  [Palengke & Tindahan]          ← row of 2
  [Sakay]                                 ← row of 1
  (Practice)

ORAS — Time & Planning
  [Kahapon, Ngayon, Bukas]                ← row of 1
  [Plano]                                 ← row of 1
  (Practice)

SALITA — The Word Machine
  [Affixes Unlocked]                      ← row of 1
  [Build Any Word]                        ← row of 1
  (Practice)
```

**v1.0 total: 32 lessons across 10 chapters**

---

## Chapter Details

### Chapter 1: MAGALANG — Respect & Greetings (4 lessons)

**Lesson 1: Po & Opo** (row of 1)
- Session 1: What is po? Po in English, Taglish, Tagalog. Oo + po = opo.
- Session 2: Who to use po with. Elders, strangers, authority. Drop with friends, kids.
- Session 3: Po placement in sentences. Word order quiz type.
- Session 4: Mano po gesture. Hindi po, pasensya na po, sige po, siyempre. Pare/mare.
- Session 5: Review (all quiz, shuffled).
- Vocabulary: po, opo, hindi po, mano po, pasensya na po, sige, sige po, siyempre, pare, mare

**Lesson 2: Kumusta** (row of 2 with Lesson 3)
- Kumusta po?, magandang umaga/tanghali/hapon/gabi po
- "Kumain ka na ba?" as a greeting, not a literal question
- Casual vs respectful greetings
- Alam Mo Ba: kumusta from Spanish "¿Cómo está?"

**Lesson 3: Oo, Hindi, Salamat** (row of 2 with Lesson 2)
- Oo / opo, hindi / hindi po, salamat / salamat po / maraming salamat po
- Walang anuman (you're welcome)
- Sige as goodbye ("Sige, bye!")
- Alam Mo Ba: salamat may come from Arabic "salaam"

**Lesson 4: Ako, Ikaw, Siya** (row of 1)
- Personal pronouns: ako, ikaw/ka, siya (gender-neutral!)
- Plural: tayo, kami, kayo, sila
- Ko/mo/niya possessives
- Kayo as formal "you" (like French "vous"), kayo + po = very formal
- Alam Mo Ba: Tagalog has no gendered pronouns

### Chapter 2: TAGLISH — How Filipinos Actually Talk (2 lessons)

**Lesson 5: The Mix** (row of 1)
- Taglish is the default spoken language, not slang
- Code-switching examples: when English words replace Tagalog, when Tagalog grammar wraps English words
- The rule: affixes are always Tagalog, roots can be English
- "nag-cook ako ng adobo yesterday" is natural. "I nagluto ng adobo yesterday" is NOT.
- Register spectrum: pure Tagalog (formal/old), Taglish (normal), heavy English (conyo)
- Alam Mo Ba: class dimension of Taglish, "conyo" speech

**Lesson 6: Any Word Is a Verb** (row of 1)
- THE hook lesson. Concept only, not mechanical affix teaching.
- nag-shopping, na-traffic, nag-Netflix, nag-gym, nag-grocery
- pinacquiao, pine-friendzone, na-late
- Quiz: "Which of these is a real Taglish verb?" (all of them)
- Teaser: "The rest of this app teaches you exactly how this works."
- Alam Mo Ba: "This is why Duolingo hasn't added Tagalog. The grammar is too different from European languages for their template."

### Chapter 3: KAIN! — Food & Basic Verbs (4 lessons)

**Lesson 7: Kain** (row of 1)
- Root "kain" (eat), kumain (um- infix, first formal affix teach)
- "Kumain ka na ba?" deep dive with cultural weight
- pagkain (food, pag- prefix), masarap (delicious, ma- preview)
- Colour-coded affix breakdown: k[um]ain
- Alam Mo Ba: "Kanin (cooked rice) comes from the same root as kain. Eating IS rice."

**Lesson 8: Luto** (row of 2 with Lesson 9)
- Root "luto" (cook), magluto/nagluto (mag-/nag-, first proper teach)
- Filipino dish vocabulary: adobo, sinigang, tinola, kare-kare
- Taglish: "Si Nanay nag-cook ng sinigang"
- Alam Mo Ba: adobo from Spanish "adobar"

**Lesson 9: Inom** (row of 2 with Lesson 8)
- Root "inom" (drink), uminom (um- reinforced)
- inumin (beverage, -in suffix preview)
- kape, tubig, juice. Ordering at a carinderia.
- Counting preview: isa, dalawa, tatlo (ordering context)
- Alam Mo Ba: "Tindahan from Spanish 'tienda.' Baso from 'vaso.' Your kitchen is full of Spanish."

**Lesson 10: Gusto & Ayaw** (row of 1)
- Gusto ko (I want) / ayaw ko (I don't want)
- Combining with verbs: "Gusto kong kumain" / "Ayaw kong magluto"
- Po placement: "Gusto ko pong kumain" (po after ko, not at end)
- Alam Mo Ba: gusto from Spanish, pure Tagalog is "ibig" but nobody says it

### Chapter 4: PAMILYA — Family & Relationships (4 lessons)

**Lesson 11: Nanay & Tatay** (row of 2 with Lesson 12)
- Nanay/Tatay, kapatid, anak, asawa
- Ate/kuya/bunso beyond family (respect for anyone older)
- Age sensitivity: kuya/ate vs tito/tita, the grey zone
- Parents calling kids "Kuya" and "Ate" so siblings learn
- Alam Mo Ba: ate/kuya from Hokkien Chinese

**Lesson 12: Lola & Lolo** (row of 2 with Lesson 11)
- Lola/lolo, tita/tito, ninong/ninang
- Tito/tita for any older adult a generation above
- Mano po revisited in family gathering context
- Alam Mo Ba: tita/tito from Spanish "tia/tio"

**Lesson 13: Mahal** (row of 2 with Lesson 14)
- Root "mahal" = love AND expensive
- Mahal kita (I love you)
- i- prefix introduction: imahal (to love, directing the action)
- How Filipinos express affection (acts of service, "Kumain ka na ba?" IS love)
- Alam Mo Ba: "Mahal meaning both 'love' and 'expensive' isn't coincidence"

**Lesson 14: Tahanan** (row of 2 with Lesson 13)
- Root "bahay" (house) / "tahanan" (home)
- Household vocabulary: kusina, kwarto, banyo, bintana
- i- prefix reinforced: "Iluto mo ang adobo"
- pa- prefix introduction: "Paluto" (have someone cook for you)
- Alam Mo Ba: "Kusina = cocina, kwarto = cuarto, banyo = baño, bintana = ventana"

### Chapter 5: BILANG — Counting & Money (2 lessons)

**Lesson 15: Filipino Numbers** (row of 1)
- Filipino numbers 1-10: isa, dalawa, tatlo, apat, lima, anim, pito, walo, siyam, sampu
- 11-20 and round numbers (honest about the struggle past 10)
- Alam Mo Ba: "Ask any Filipino to count past 10 in Tagalog and watch them struggle"

**Lesson 16: Money & Spanish Numbers** (row of 1)
- Spanish numbers for money: bente, trenta, singkwenta, benchingko
- English for complex amounts: "one-twenty" not "isang daan at dalawampu"
- Filipino for coins and round hundreds: isa, lima, sampu, isang daan
- "Magkano po?" (how much?)
- Filipino time: alas-otso, alas-dose ng tanghali, alas tres y medya
- Alam Mo Ba: "Filipinos count in three languages depending on the situation"

### Chapter 6: ARAW-ARAW — Daily Routines (4 lessons)

**Lesson 17: Umaga** (row of 1)
- Morning routine: gising, ligo, bihis, kain
- mag- reinforced with new roots: magligo, magbihis
- Time vocabulary: umaga, tanghali, hapon, gabi
- Time-telling: alas-otso ng umaga, alas dose ng tanghali
- Alam Mo Ba: "Filipinos tell time in Spanish numbers with Filipino time-of-day words"

**Lesson 18: Trabaho** (row of 2 with Lesson 19)
- Root "trabaho" (work) / "aral" (study)
- mag-aral / nag-aral reinforced
- nag- with English roots: "nagta-trabaho," "nag-shopping" (callback to Taglish chapter)
- Alam Mo Ba: "Trabaho from Spanish 'trabajo.' Eskwela from 'escuela.'"

**Lesson 19: Linis & Ayos** (row of 2 with Lesson 18)
- Root "linis" (clean) / "ayos" (fix)
- -in suffix: linisin (clean THE THING)
- -an suffix: linisan (clean THE PLACE)
- Object-focus system introduction
- Alam Mo Ba: "-in and -an are the suffixes that make Tagalog genuinely different from English"

**Lesson 20: Pahinga** (row of 1)
- Root "pahinga" (rest) / "tulog" (sleep) / "laro" (play)
- pa- prefix reinforced: papahinga (about to rest)
- naka- prefix: nakatulog (fell asleep accidentally)
- "Nag-mall kami kahapon" (Taglish callback)
- Alam Mo Ba: "'Malling' is Filipino English. Also: nag-grocery, nag-gym, nag-Netflix."

### Chapter 7: DAMDAMIN — Feelings & Descriptions (4 lessons)

**Lesson 21: Masaya & Malungkot** (row of 1)
- ma- prefix for adjectives (formally taught, callback to "maganda" from Lesson 2)
- masaya/malungkot/magalit/matakot
- Root extraction: lungkot = sadness, takot = fear
- "Okay ka lang po?"
- Alam Mo Ba: "kilig, gigil, tampo — emotions English can't capture"

**Lesson 22: Maganda & Gwapo** (row of 2 with Lesson 23)
- maganda/gwapo/mabait/matalino
- Describing people respectfully with po
- napa- prefix: "Napangiti ako" (involuntary smile)
- Alam Mo Ba: "Gwapo from Spanish 'guapo'"

**Lesson 23: Mainit & Malamig** (row of 2 with Lesson 22)
- mainit/malamig/maulan/mahangin
- Same ma- pattern, root extraction reinforced
- Philippine seasons: tag-ulan (rainy), tag-init (dry/hot)
- Alam Mo Ba: "Tag- means 'season of.' Tag-gutom = season of hunger (slang for broke before payday)"

**Lesson 24: Pagod & Gutom** (row of 1)
- pagod/gutom/uhaw/antok
- Intensifiers: "Pagod na pagod na ako," "sobrang gutom," "grabe"
- These don't use ma- (exception to the pattern)
- Alam Mo Ba: "Grabe from Spanish 'grave' (serious). Evolved into a general intensifier."

### Chapter 8: LUGAR — Places & Getting Around (4 lessons)

**Lesson 25: Saan** (row of 1)
- saan/dito/diyan/doon, nasa, nasaan
- "Saan po ito?" (word order callback)
- Alam Mo Ba: "Tagalog has THREE words for 'there': dito (near me), diyan (near you), doon (far from both)"

**Lesson 26: Punta** (row of 2 with Lesson 27)
- Root "punta" / "lakad"
- pumunta/pupunta (um- reinforced), papunta (pa- directional)
- Pauwi (heading home), palabas (heading out)
- Alam Mo Ba: "'Lakad' means both 'walk' and 'errand.' 'May lakad ako' = 'I have somewhere to be.'"

**Lesson 27: Palengke & Tindahan** (row of 2 with Lesson 26)
- Market/store vocabulary, numbers for prices
- "Magkano po?" (callback to counting chapter)
- "Mura" (cheap) / "Mahal" (expensive — callback to Chapter 4 double meaning)
- "Tawad po" (discount please)
- Alam Mo Ba: "Palengke from Spanish 'palenque'"

**Lesson 28: Sakay** (row of 1)
- Jeepney/tricycle/bus/MRT vocabulary
- "Para po!" (the most iconic po usage)
- sakay/baba, "Bayad po" (passing money in a jeepney)
- Alam Mo Ba: "Jeepney comes from American military jeeps left after WWII"

### Chapter 9: ORAS — Time & Planning (2 lessons)

**Lesson 29: Kahapon, Ngayon, Bukas** (row of 1)
- Time markers and tense consolidation
- How tense prefixes map: nag- = kahapon, nag-_-_ = ngayon, mag- = bukas
- Tense table for all familiar roots
- Taglish tense: "Kahapon nag-cook ako, ngayon nagluluto ako, bukas mag-cook ulit ako"

**Lesson 30: Plano** (row of 1)
- "Tara!" (let's go), "Sama ka?" (wanna come?)
- "Pwede po ba...?" (asking permission politely)
- "Free ka ba this Saturday?" (Taglish scheduling)
- How Filipinos say no without saying no: "Sige, tignan ko," "Baka pwede next time"
- Alam Mo Ba: "Pwede from Spanish 'puede.' Sige from 'sigue.'"

### Chapter 10: SALITA — The Word Machine (2 lessons)

**Lesson 31: Affixes Unlocked** (row of 1)
- The formal framework for everything Taglish chapter teased
- Full affix table: mag-, nag-, um-, i-, pa-, -in, -an, ma-, naka-, napa-, pag-
- How to decode any unfamiliar Tagalog word: strip affix → find root → understand meaning
- This is the moment the system "clicks"

**Lesson 32: Build Any Word** (row of 1)
- Stacking affixes: pina- + luto = pinaluto (had someone cook, past tense)
- magpa- + luto = magpaluto (to have someone cook, future)
- Creative stacking: pinag-aralan (studied intensively), nakapagpapagaling (able to heal)
- Build-your-own-sentence exercise
- Heritage moment: "You now have the tools to understand words you've never studied. Next time you hear your lola speak, listen for the roots."

---

## Future Content (v2.0+)

### v2.0: TANONG, HUGIS NG SALITA, KULTURA

**TANONG — Questions & Conversations**
  [Ano, Sino, Bakit]                      ← row of 1
  [Paano & Kailan]  [Conversations]       ← row of 2
  (Practice)

**HUGIS NG SALITA — Sentence Shape**
  [Ang, Ng, Sa]                           ← row of 1
  [Focus System]                          ← row of 1
  [Connectors]                            ← row of 1
  (Practice)

**KULTURA — Culture & Social Rules**
  [Kuya, Ate, Tito, Tita]                ← row of 1
  [Filipino Time]  [Pakikisama]           ← row of 2
  [Fiestas & Holidays]                    ← row of 1
  (Practice)

### v3.0: KALYE, TRABAHO, KWENTO

**KALYE — Street Tagalog**
  [Slang & Shortcuts]                     ← row of 1
  [Text Speak]  [Beki Speak]              ← row of 2
  (Practice)

**TRABAHO — Professional Filipino**
  [Office Taglish]                        ← row of 1
  [Emails & Messages]  [Meetings]         ← row of 2
  (Practice)

**KWENTO — Storytelling**
  [Noong, Bigla, Kaya Naman]             ← row of 1
  [Proverbs & Sayings]                    ← row of 1
  [Jokes & Wordplay]                      ← row of 1
  (Practice)

### v4.0: MALALIM, BAYBAYIN

**MALALIM — Deep Tagalog**
  [Formal Register]                       ← row of 1
  [Regional Words]  [Poetry & Literature] ← row of 2
  (Practice)

**BAYBAYIN — The Ancient Script**
  [The 17 Characters]                     ← row of 1
  [Write Your Name]                       ← row of 1
  [Read & Write]                          ← row of 1
  (Practice)

---

## Affix Introduction Order (Organic)

| Lesson | Affix | Context | Type |
|--------|-------|---------|------|
| 2 (Kumusta) | ma- | "maganda" in greetings | Preview |
| 6 (Any Word Is a Verb) | nag-, na-, pine- | Taglish verbs | Concept only |
| 7 (Kain) | um- | "kumain" — eating | First proper teach |
| 7 (Kain) | pag- | "pagkain" — food as noun | Organic |
| 8 (Luto) | mag- / nag- | "magluto/nagluto" — cooking | First proper teach |
| 9 (Inom) | -in (noun) | "inumin" — beverage | Preview |
| 13 (Mahal) | i- | "imahal" — directing love | First proper teach |
| 14 (Tahanan) | pa- | "paluto" — causative | First proper teach |
| 19 (Linis & Ayos) | -in (verb) | "linisin" — clean the thing | First proper teach |
| 19 (Linis & Ayos) | -an | "linisan" — clean the place | First proper teach |
| 20 (Pahinga) | naka- | "nakatulog" — fell asleep | Organic |
| 21 (Masaya) | ma- (adj) | "masaya/malungkot" | First proper teach |
| 22 (Maganda) | napa- | "napangiti" — involuntary | Organic |
| 26 (Punta) | pa- (directional) | "pauwi" — heading home | Reinforcement |
| 29 (Kahapon) | Full tense table | Consolidation | Review |
| 31 (Affixes Unlocked) | All affixes | Complete framework | Formal teach |
| 32 (Build Any Word) | pina- / magpa- | Stacking affixes | Advanced teach |

---

## chapters.json Reference

```json
[
  {
    "chapter_id": "ch01",
    "title": "Magalang",
    "subtitle": "Respect & Greetings",
    "rows": [
      { "row": 1, "lessons": ["001"] },
      { "row": 2, "lessons": ["002", "003"] },
      { "row": 3, "lessons": ["004"] }
    ]
  },
  {
    "chapter_id": "ch02",
    "title": "Taglish",
    "subtitle": "How Filipinos Actually Talk",
    "rows": [
      { "row": 1, "lessons": ["005"] },
      { "row": 2, "lessons": ["006"] }
    ]
  },
  {
    "chapter_id": "ch03",
    "title": "Kain!",
    "subtitle": "Food & Basic Verbs",
    "rows": [
      { "row": 1, "lessons": ["007"] },
      { "row": 2, "lessons": ["008", "009"] },
      { "row": 3, "lessons": ["010"] }
    ]
  },
  {
    "chapter_id": "ch04",
    "title": "Pamilya",
    "subtitle": "Family & Relationships",
    "rows": [
      { "row": 1, "lessons": ["011", "012"] },
      { "row": 2, "lessons": ["013", "014"] }
    ]
  },
  {
    "chapter_id": "ch05",
    "title": "Bilang",
    "subtitle": "Counting & Money",
    "rows": [
      { "row": 1, "lessons": ["015"] },
      { "row": 2, "lessons": ["016"] }
    ]
  },
  {
    "chapter_id": "ch06",
    "title": "Araw-araw",
    "subtitle": "Daily Routines",
    "rows": [
      { "row": 1, "lessons": ["017"] },
      { "row": 2, "lessons": ["018", "019"] },
      { "row": 3, "lessons": ["020"] }
    ]
  },
  {
    "chapter_id": "ch07",
    "title": "Damdamin",
    "subtitle": "Feelings & Descriptions",
    "rows": [
      { "row": 1, "lessons": ["021"] },
      { "row": 2, "lessons": ["022", "023"] },
      { "row": 3, "lessons": ["024"] }
    ]
  },
  {
    "chapter_id": "ch08",
    "title": "Lugar",
    "subtitle": "Places & Getting Around",
    "rows": [
      { "row": 1, "lessons": ["025"] },
      { "row": 2, "lessons": ["026", "027"] },
      { "row": 3, "lessons": ["028"] }
    ]
  },
  {
    "chapter_id": "ch09",
    "title": "Oras",
    "subtitle": "Time & Planning",
    "rows": [
      { "row": 1, "lessons": ["029"] },
      { "row": 2, "lessons": ["030"] }
    ]
  },
  {
    "chapter_id": "ch10",
    "title": "Salita",
    "subtitle": "The Word Machine",
    "rows": [
      { "row": 1, "lessons": ["031"] },
      { "row": 2, "lessons": ["032"] }
    ]
  }
]
```
