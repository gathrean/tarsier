# Tarsier — Learn Tagalog | Roadmap v0.1 → v1.0

> **App Name:** Tarsier  
> **Tagline:** Tarsier — learn Tagalog  
> **Stack:** SwiftUI, SwiftData, Gemini API, Superwall, RevenueCat  
> **Architecture:** Local-first, no auth, no backend  

---

## v0.1 — Foundation

The app works end-to-end. App Store submission build.

- Project setup, colour palette (Philippine flag blue/yellow/red), SF Rounded typography
- SwiftData models: UserProfile, LessonResult
- Onboarding flow (3 screens: welcome → skill level picker → motivation)
- Home screen with streak counter + sequential lesson list
- 30 pre-generated lessons bundled as local JSON (QA'd by Ean)
- Lesson structure: cultural note → etymology/affix breakdown → vocabulary → example sentences → quiz
- Quiz engine: 4 question types (multiple choice, fill-in-blank, translate, root pattern)
- Streak tracking (local, daily, resets after 1 missed day)
- "Practice with Tarsier" — Gemini-powered conversational AI mode (premium)
- Monetisation: RevenueCat + Superwall, $4.99/month or $29.99/year
- Free tier = full 30-lesson curriculum. Premium = AI conversation mode.

---

## v0.2 — Retention

Keep users coming back. Notifications and streak protection.

- Push notifications (streak reminders, re-engagement nudges)
- Daily reminder scheduling (user picks their preferred time)
- Streak freeze mechanic (miss a day without losing streak — premium perk)
- Improved quiz feedback: show explanation on every answer, not just incorrect ones
- Lesson completion celebrations (simple animation or confetti moment)

---

## v0.3 — Audio & Pronunciation

Hear the language, not just read it.

- Text-to-speech playback on all vocabulary words and example sentences
- Tap any Tagalog word in a lesson to hear pronunciation
- Audio toggle in settings (on/off)
- Optional: recorded native speaker audio for high-frequency words (Ean or community-sourced)
- Pronunciation guide improvements in lesson JSON (stress markers, syllable breaks)

---

## v0.4 — Review & Spaced Repetition

Long-term retention, not just one-time completion.

- "Review" mode: resurfaces vocabulary and affix patterns from completed lessons
- Spaced repetition algorithm (words you got wrong appear more frequently)
- "Tough Words" collection: auto-populated from quiz mistakes
- Review streaks (separate from lesson streaks — bonus engagement loop)
- Progress stats: words learned, affixes mastered, lessons completed

---

## v0.5 — Content Expansion

Double the curriculum.

- Lessons 31–60
- Deeper affix stacking (pinag-, napag-, ipinag-)
- Conversational scenarios and dialogues
- Reading comprehension: short Tagalog paragraphs with comprehension questions
- Advanced heritage speaker content (formal writing, professional Tagalog)
- Content authored by Ean, Gemini as co-author, manual QA on every lesson

---

## v0.6 — Widgets & Glanceable Learning

Tarsier lives on your home screen.

- Home screen widgets: word of the day, streak counter, daily lesson reminder
- Lock screen widget: Tagalog phrase of the day
- Widget taps deep-link into the relevant lesson or review
- Passive discovery layer — users see Tarsier daily without opening the app

---

## v0.7 — Social & Sharing

Organic growth engine.

- Share progress cards (Instagram/TikTok-ready graphics: "I just learned 50 Tagalog words")
- Shareable quiz results ("I scored 5/5 on Tagalog affixes")
- Leaderboards (optional, friends-only)
- Invite-a-friend mechanic
- Referral incentive (e.g., 1 free week of premium for each referral)

---

## v0.8 — Conversation Mode Expansion

Premium experience gets deeper.

- Structured AI conversation scenarios:
  - "Order food at a carinderia"
  - "Introduce yourself to your partner's parents"
  - "Negotiate at a palengke"
  - "Comfort a homesick friend"
  - "Text your tita back properly"
- Gemini generates the scenario, user responds, AI evaluates and teaches
- Scenario difficulty scaling based on user's completed lessons
- Conversation history and favourites (save useful phrases from AI interactions)

---

## v0.9 — Ship Prep & Polish

Everything that needs to be right before going loud.

- Performance audit and optimisation
- Accessibility pass (VoiceOver, Dynamic Type, colour contrast)
- iPad-specific layout
- Onboarding refinements based on user feedback and analytics
- Analytics review: lesson drop-off rates, quiz difficulty calibration, paywall conversion
- App Store screenshot refresh
- App Store metadata polish (description, keywords, what's new)
- Bug sweep and stability pass

---

## v1.0 — Launch

Go loud.

- TikTok / Instagram content campaign (heritage reconnection angle)
- Rye involved in content strategy and creative direction
- Tarsier mascot fully polished (Figma, multiple poses/expressions)
- Product tight enough to survive the attention
- SaaS landing page (tarsierapp.com or similar)
- Organic distribution first, paid ads after 10% download-to-trial conversion

---

## Parked Ideas (Post v1.0)

- Speech recognition / pronunciation scoring
- Cebuano / Ilokano / Bisaya expansion packs
- Classroom mode (teachers assign lessons to students)
- Cultural immersion content (short videos, music, recipes tied to lessons)
- Tarsier mascot emotional reactions (happy when you get streaks, sad when you miss)
- Dark mode theming
- macOS companion app
- Apple Watch complication (streak + word of the day)
