# Tarsier — Learn Tagalog | Claude Code Spec

> **Version:** v0.1 MVP  
> **Owner:** Ean (solo iOS dev)  
> **Stack:** SwiftUI, SwiftData, Gemini API (Flash), Superwall, RevenueCat, Google AdMob  
> **Target:** iOS 17+, iPhone only (no iPad layout for v0.1)

> **Reference docs (read these when you need context):**  
> - `docs/Tarsier_Roadmap.md` — 30-lesson curriculum, chapter structure, affix introduction order, "Alam Mo Ba?" content  
> - `docs/Tarsier_Research.md` — market research, competitor analysis, design decisions, audience insights  
> - `docs/Lessons/lesson_001_po.json` — Lesson 1 JSON schema (Po & Opo, Chapter 1)  
> - `docs/Claude/v0/v0.1-Foundation.md` — block-by-block build tasks for current phase

> **Repo structure:**
> ```
> tarsier/                    ← repo root (CLAUDE.md lives here)
> ├── CLAUDE.md
> ├── docs/
> │   ├── Claude/v0/          ← per-phase build tasks
> │   ├── Lessons/            ← lesson JSON files
> │   ├── Tarsier_Roadmap.md
> │   ├── Tarsier_Research.md
> │   └── Tarsier_v0.1_TODO.md
> ├── Tarsier/                ← Xcode project source
> ├── Tarsier.xcodeproj
> └── project.yml
> ```

---

## Context

Tarsier is a gamified Tagalog language learning app — think "Duolingo for Tagalog." The core differentiator is teaching Tagalog's affix/etymology system (how prefixes and suffixes transform root words) rather than isolated flashcards. Lessons follow a "teach first, test second" slide-based flow inspired by AirLearn and HelloChinese.

**This is NOT a generic quiz app.** The design must feel like a polished language learning app — warm, encouraging, culturally grounded in Filipino identity, with real photos mixed into a clean UI. Study HelloChinese and AirLearn's App Store screenshots for reference.

---

## Design System — DO NOT USE DEFAULT SWIFTUI STYLING

### The Problem to Solve
The previous build looked like default SwiftUI with system colours and stock components. Tarsier needs a custom design language. Every screen should feel intentionally designed — not assembled from SwiftUI defaults.

### Colour Palette (Ube Purple + Filipino Identity)

```swift
// Theme.swift or equivalent
enum TarsierColors {
    // Brand purples (two-shade system for accessibility)
    static let brandPurple = Color(hex: "#8778C3")      // Light/background purple. Icon bg, accents, light fills, marketing.
    static let functionalPurple = Color(hex: "#6B5B9A")  // Buttons, nav bars, progress bars. Passes WCAG contrast on white text.
    
    // Accent colours
    static let gold = Color(hex: "#FCD116")              // Rewards, streaks, XP, celebration, tarsier eyes.
    static let alertRed = Color(hex: "#CE1126")          // Corrections, streak freeze warnings, heart loss.
    static let correctGreen = Color(hex: "#2ECC71")      // Correct answer feedback.
    
    // Warm neutrals
    static let tarsierDark = Color(hex: "#302B27")       // Mascot body, dark text, near-black.
    static let cream = Color(hex: "#FFF5E6")             // Card backgrounds, soft canvas.
    static let warmWhite = Color(hex: "#FAFAF7")         // Screen background (NOT pure white).
    
    // Text
    static let textPrimary = Color(hex: "#1A1A1A")       // Main body text — near-black, not pure black.
    static let textSecondary = Color(hex: "#6B6B6B")     // Secondary labels, hints.
    static let textOnPurple = Color.white                // Text on functionalPurple backgrounds.
    
    // Functional
    static let heartRed = Color(hex: "#E74C3C")          // Heart icon colour.
    static let cardBorder = Color(hex: "#E8E4DF")        // Subtle warm border for cards.
}
```

### Typography — SF Rounded, NOT SF Pro

```swift
// Use SF Rounded throughout the entire app. This gives warmth and approachability.
// SF Pro is too clinical for a language learning app.

enum TarsierFonts {
    // Screen titles
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    // Section headers
    static func heading(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    // Body text
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    // Tagalog words displayed prominently
    static func tagalogWord(_ size: CGFloat = 24) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    // Small labels, hints, captions
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium, design: .rounded)
    }
}
```

### Spacing & Layout

```swift
enum TarsierSpacing {
    static let screenPadding: CGFloat = 20      // Horizontal padding on all screens
    static let cardPadding: CGFloat = 16        // Internal card padding
    static let cardCornerRadius: CGFloat = 16   // Rounded cards — NOT 8 or 10, use 16 for warmth
    static let buttonCornerRadius: CGFloat = 14 // Slightly smaller than cards
    static let itemSpacing: CGFloat = 12        // Between list items
    static let sectionSpacing: CGFloat = 24     // Between sections
}
```

### Card Style (used everywhere — lessons, vocabulary, quizzes)
```
- Background: cream (#FFF5E6) or white
- Corner radius: 16pt
- Border: 1pt, cardBorder (#E8E4DF)  — subtle, warm, NOT grey
- Shadow: very subtle (color: .black.opacity(0.04), radius: 8, y: 2)
- Internal padding: 16pt
- NO sharp corners anywhere in the app
```

### Buttons
```
Primary button:
- Background: functionalPurple (#6B5B9A)
- Text: white, SF Rounded semibold 17pt
- Corner radius: 14pt
- Height: 52pt minimum
- Full width within card or screen padding
- Pressed state: slightly darker blue, scale(0.98) animation

Secondary button:
- Background: transparent
- Border: 1.5pt functionalPurple
- Text: functionalPurple, SF Rounded semibold 16pt
- Same corner radius and height

Correct answer flash:
- Background: correctGreen with 0.15 opacity overlay
- Border: 2pt correctGreen
- Duration: 0.6s, ease-out

Wrong answer flash:
- Background: brandRed with 0.15 opacity overlay
- Border: 2pt brandRed
- Shake animation (horizontal, 3 cycles, 0.4s)
```

### Progress Bar (appears at top of every lesson)
```
- Track: cardBorder colour, 6pt height, full-width rounded capsule
- Fill: functionalPurple, animated (0.3s ease-in-out) as user advances slides
- Shows current slide / total slides
```

---

## Screen Specs

### 1. Onboarding (3 screens)

The onboarding should feel welcoming and warm — NOT a form. Use illustrations or the tarsier mascot placeholder, large text, and a single question per screen.

**Screen 1: Welcome**
- Large tarsier mascot (placeholder: dark charcoal #302B27 rounded shape with two gold #FCD116 circles for eyes)
- Text: "Tarsier" in functionalPurple, SF Rounded bold 36pt
- Subtitle: "Learn Tagalog" in textSecondary, SF Rounded 18pt
- Button: "Get Started" (primary style)
- Background: warmWhite with subtle brandPurple (#8778C3) gradient at bottom

**Screen 2: Skill Level**
- Question: "How much Tagalog do you know?"
- Three selectable cards (vertical stack):
  - "None — I'm starting fresh" 
  - "Some — I understand but can't speak" (this is the heritage learner — highlight this as most common)
  - "Conversational — I want to improve"
- Cards: cream background, functionalPurple border when selected, checkmark icon
- This selection is stored in SwiftData but doesn't change lesson content in v0.1

**Screen 3: Motivation**
- Question: "Why are you learning Tagalog?"
- Selectable pills/chips (multi-select):
  - "Connect with family"
  - "Cultural pride"
  - "Travel to the Philippines"
  - "Partner/relationship"
  - "Just curious"
- Button: "Let's go!" → navigates to Home

### 2. Home Screen (the Roadmap)

This is the most important screen. It should NOT be a flat list. Look at HelloChinese's roadmap or Duolingo's path — it's a visual journey.

**Layout:**
- Top bar: streak flame icon (brandYellow) + streak count on left, heart icon (heartRed) + heart count on right, XP badge in centre
- Below top bar: scrollable vertical roadmap
- Each chapter is a GROUP of lesson nodes connected by a dotted path line
- Chapter header: chapter title in heading font, chapter number badge (functionalPurple circle with white number)
- Lesson nodes: circular or rounded-square icons (56pt), numbered, with:
  - Locked state: grey fill, lock icon
  - Available state: cream fill, functionalPurple border, lesson number
  - Completed state: functionalPurple fill, white checkmark
  - Current state: functionalPurple border with pulsing/glowing animation
- Between chapters: a slightly larger "AI Practice" node with tarsier icon (unlocks when all chapter lessons complete)
- The path between nodes: dotted line in cardBorder colour, 2pt, connecting centre of each node

**The feel:** vertical scroll, nodes staggered slightly left-right (not a straight line), creating a winding path. HelloChinese does this well.

### 3. Lesson View (Slide-Based)

This is the core learning experience. Each lesson is a series of full-screen slides that the user swipes through or advances with a "Continue" button.

**Consistent elements on every lesson slide:**
- Progress bar at very top (below safe area)
- Close button (X) top-left to exit lesson (confirmation dialog)
- Slide content in the centre
- "Continue" button at bottom (primary style, fixed to bottom safe area)

**Slide types:**

**a) Cultural Context Slide**
- Full-width image at top (real photo from Wikimedia, 200pt height, corner radius 16pt, clipped)
- Title: heading font, functionalPurple
- Body: body font, textPrimary, line height 1.5
- If taglish_note exists: a subtle callout box (cream background, left border 3pt functionalPurple) with the note in caption font

**b) Teaching Slide (Etymology/Affix)**
- Title: heading font
- Body text: body font
- Colour-coded word breakdown: the KEY visual moment
  ```
  ┌────────────────────────────────┐
  │                                │
  │    n a g  │  l u t o           │
  │   ═══════   ═════════          │
  │   prefix     root              │
  │  (past)     (cook)             │
  │                                │
  │   functionalPurple  tarsierDark    │
  │                                │
  │   → nagluto = "cooked"        │
  │                                │
  └────────────────────────────────┘
  ```
  - The word parts should be in large tagalogWord font
  - Each part gets a coloured underline (3pt) and a small label below
  - Affix parts: functionalPurple underline, purple label
  - Root parts: tarsierDark underline, dark label
  - Combined meaning below in body font
  - This should be a custom SwiftUI view (AffixBreakdownView) reused across all lessons

**c) Vocabulary Slide**
- One word per slide (do NOT cram multiple words onto one screen — AirLearn's mistake)
- Layout:
  - Image at top if available (real photo, rounded, 180pt height)
  - Tagalog word: tagalogWord font, textPrimary, centre-aligned
  - Pronunciation guide: caption font, textSecondary, below the word
  - English meaning: body font, textSecondary
  - Example sentence in a card:
    - Tagalog sentence in bold
    - English translation below in regular
    - Taglish variant in a separate callout (cream background, left functionalPurple border)
  - Speaker icon (for future TTS — show but disable in v0.1 with "Coming soon" tooltip)

**d) Sentence Breakdown Slide**
- Full Tagalog sentence at top in tagalogWord font
- English translation below in textSecondary
- Below: horizontal row of tappable word "chips"
  - Each word is a rounded pill (cream background, cardBorder border)
  - Tapping a word expands a popover/sheet showing:
    - The word
    - Its role in the sentence
    - If it contains an affix: the colour-coded breakdown
  - Words containing affixes have a thin functionalPurple bottom border as a hint to tap
- Taglish version at bottom in callout style

**e) "Alam Mo Ba?" Slide**
- Distinct visual: gold (#FCD116) background (light, 0.15 opacity) with a small "💡" or tarsier-with-lightbulb icon
- Title: "Alam Mo Ba?" in heading font
- Body: body font, the fun fact
- These slides have NO "Continue" required — they auto-advance when the user taps or swipes, or have a "Got it!" button
- Feel: light, fun, breather between teaching and quizzing

**f) Quiz Slide**
- Question prompt: heading font, textPrimary
- Answer options:

  *Multiple choice:*
  - 4 vertical cards (cream background, cardBorder border, 52pt min height)
  - Tap to select → highlight with functionalPurple border
  - "Check" button appears at bottom after selection
  - Correct: card flashes green, confetti-like subtle particle effect (optional), explanation card slides up from bottom
  - Wrong: card flashes red + shake, heart decreases, explanation card slides up

  *Fill in blank:*
  - Sentence with a highlighted blank (functionalPurple underline)
  - Text input field: large, rounded, auto-focused
  - "Check" button below
  - Case-insensitive matching

  *Root pattern:*
  - Same as multiple choice but the explanation always includes a colour-coded affix breakdown

- Explanation card (slides up after answering):
  - Cream background, top corner radius 20pt (bottom sheet style)
  - Green header bar if correct ("Tama!" / "Correct!"), red if wrong ("Hindi pa" / "Not quite")
  - Explanation text in body font
  - "Continue" button to advance

**g) Summary Slide**
- Celebratory: brandYellow accent, maybe a simple tarsier "happy" expression
- "Lesson Complete!" in title font
- Stats: XP earned, words learned, roots learned
- List of key words learned (horizontal scroll of small pills)
- "Continue" button → returns to roadmap (with lesson node now marked complete)

### 4. AI Practice View (Gemini Chat)

- Appears as a chat interface — NOT the same slide layout as lessons
- Top bar: "Practice with Tarsier" title, close button
- Chat bubbles:
  - Tarsier (AI): cream background, left-aligned, small tarsier avatar circle
  - User: functionalPurple background, white text, right-aligned
- Text input at bottom with send button
- Max 6 turns, then a "Practice complete!" summary
- Gated: free users see a paywall sheet after 1 session, or watch ad button (AdMob rewarded video)

### 5. Words Screen (Word Bank)

The second tab. Shows every word the user has learned across completed lessons.

**Layout:**
- Top: "Words" title in heading font, total word count subtitle ("42 words learned")
- Search bar: rounded, cream background, placeholder "Search words..."
- Filter pills: horizontal scroll — "All", "Chapter 1", "Chapter 2", etc. Active pill: functionalPurple fill, white text. Inactive: cream fill, textSecondary text.
- Word list: vertical scroll of word cards

**Word Card:**
- Left side: Tagalog word in tagalogWord font (18pt), English meaning below in textSecondary
- Right side: small affix badge if the word contains a learned affix (pill shape, `${brandPurple}15` background, functionalPurple text, shows the affix e.g. "mag-" or "um-")
- Tap to expand: shows root breakdown (colour-coded AffixBreakdownView), example sentence, Taglish variant, pronunciation guide
- Bottom of expanded card: "Practice" button that creates a quick quiz on just this word (costs no hearts)

**Empty state:** tarsier mascot placeholder + "Start your first lesson to build your word bank"

### 6. Profile / Settings Screen

- Simple grouped list (SwiftUI Form style is fine here, but use cream section backgrounds)
- Top: tarsier avatar + user's streak stats (current streak, longest streak, total XP, lessons completed)
- Sections:
  - Profile: skill level, motivation (editable)
  - Preferences: notifications toggle, sound toggle
  - Subscription: current plan, manage subscription
  - About: version, credits, "Photo Credits" (opens attribution list from Wikimedia tracker)
  - Support: feedback email link

### 7. Tab Bar (Bottom Navigation)

**Critical pattern:** Every major language app (Duolingo, HelloChinese, AirLearn, Babbel) uses a simple bottom tab bar with the brand colour only on the active tab. No coloured headers. No floating pills. The tab bar is furniture, not a feature.

**Three tabs for v0.1:**

| Tab | Icon | Label | Destination |
|-----|------|-------|-------------|
| 1 | Book/map icon | Learn | Home / Roadmap |
| 2 | Character/text icon | Words | Word Bank |
| 3 | Person icon | Profile | Settings / Stats |

**Tab bar styling:**
- Background: warmWhite (#FAFAF7)
- Top border: 0.5pt, cardBorder (#E8E4DF)
- Inactive icon + label: textSecondary (#6B6B6B)
- Active icon + label: functionalPurple (#6B5B9A)
- Active indicator: small 4pt circle (functionalPurple) centred below the icon, NOT a full highlight bar
- Height: standard iOS tab bar height (~49pt + safe area)
- SF Rounded caption weight for labels

**Tab bar visibility:**
- VISIBLE on: Home/Roadmap, Words, Profile
- HIDDEN during: Onboarding, Lessons (full-screen slide flow), AI Practice (full-screen chat), Paywalls
- When entering a lesson: tab bar animates out (slide down). When exiting: animates back in.

**No purple header anywhere.** The top of screens is content (streak bar on Home, search bar on Words, stats on Profile) on warmWhite. Purple lives in the content layer — buttons, progress bars, selected states, affix highlights. This prevents the purple-sandwich effect of coloured bars top and bottom squeezing the content.

### 8. Streak / Hearts / XP Top Bar

- Persistent across Home screen only (not Words or Profile)
- Streak: flame emoji + number, gold (#FCD116) tint
- Hearts: heart emoji + number (out of 5), heartRed tint. When a heart is lost, animate it shrinking + fading.
- XP: star or shield icon + total XP, functionalPurple tint
- When hearts reach 0: modal sheet offering "Watch ad to refill" (AdMob rewarded) or "Get Premium" (Superwall paywall)

---

## Data Models (SwiftData)

```swift
@Model
class UserProfile {
    var skillLevel: String          // "none", "some", "conversational"
    var motivations: [String]       // ["family", "pride", "travel", etc.]
    var currentStreak: Int
    var longestStreak: Int
    var lastActiveDate: Date?
    var totalXP: Int
    var hearts: Int                 // Max 5, refills over time or via ad
    var lastHeartRefill: Date?
    var isPremium: Bool
}

@Model
class LessonProgress {
    var lessonId: String            // "001", "002", etc.
    var chapterId: String           // "ch01", "ch02", etc.
    var isCompleted: Bool
    var bestScore: Int              // Quiz score (correct answers)
    var completedAt: Date?
    var xpEarned: Int
}

@Model 
class ChapterProgress {
    var chapterId: String
    var isUnlocked: Bool
    var aiPracticeCompleted: Bool
    var aiPracticeSessionsUsed: Int // For free user gating
}

@Model
class WordBank {
    var word: String
    var root: String
    var meaning: String
    var lessonId: String
    var timesCorrect: Int
    var timesWrong: Int
    var lastPracticed: Date?
}
```

### Heart Refill Logic
```
- Max hearts: 5
- Hearts refill 1 per 30 minutes (configurable)
- Watching rewarded ad: +1 heart immediately
- Premium users: unlimited (hearts UI shows ∞ symbol)
- Hearts decrease by 1 for each wrong quiz answer
- Hearts do NOT decrease for re-reading teaching slides (slides before quiz)
```

---

## Lesson Data — JSON Bundle

All 30 lessons are bundled as local JSON files in the app bundle. No network calls needed.

- Location: `Resources/Lessons/lesson_001.json`, `lesson_002.json`, etc.
- Schema: see `tarsier_lesson_001_po_v0.3.json` for the reference structure
- Chapter metadata: a separate `chapters.json` defining chapter order, titles, and which lessons belong to each chapter
- Images: bundled in `Assets.xcassets` or a `LessonImages/` folder, referenced by filename in JSON

### JSON Loading
```swift
// Load and decode lesson JSON
struct LessonData: Codable {
    let lessonId: String
    let title: String
    let chapterId: String
    let chapterTitle: String
    let slides: [SlideData]
    let aiPractice: AIPracticeConfig?
    let gamification: GamificationConfig
}

struct SlideData: Codable {
    let slideId: String
    let type: SlideType // "cultural_context", "teaching", "vocabulary", "sentence_breakdown", "alam_mo_ba", "quiz", "lesson_summary"
    // ... type-specific fields
}
```

---

## Build Order (Claude Code Handoff)

### Block 1: Project Setup + Design System + Data Models
1. Create Xcode project (Tarsier, SwiftUI, SwiftData)
2. Implement TarsierColors, TarsierFonts, TarsierSpacing as Swift enums/extensions
3. Create Color hex extension
4. Implement all SwiftData models (UserProfile, LessonProgress, ChapterProgress, WordBank)
5. Create reusable card component (TarsierCard) with the warm styling
6. Create reusable button components (PrimaryButton, SecondaryButton)
7. Create the AffixBreakdownView component — this is the signature visual
8. Create progress bar component

### Block 2: Onboarding Flow + Home Screen
1. Three-screen onboarding (welcome, skill level, motivation)
2. Store selections in SwiftData UserProfile
3. Home screen with roadmap layout (scrollable, staggered nodes, path lines)
4. Streak/Hearts/XP top bar
5. Chapter headers with lesson nodes (locked, available, completed, current states)

### Block 3: Lesson View + Slide Engine
1. Lesson container view with progress bar and close button
2. Slide rendering engine — reads JSON, renders correct slide type
3. Cultural context slide
4. Teaching slide with AffixBreakdownView
5. Vocabulary slide with image + example + Taglish callout
6. Sentence breakdown slide with tappable word chips
7. "Alam Mo Ba?" slide with yellow accent
8. Quiz engine: multiple choice, fill-in-blank, root pattern, translate
9. Answer feedback: correct/wrong animations, explanation card
10. Summary slide with XP reward
11. Update LessonProgress and WordBank on completion

### Block 4: Streak + Hearts + XP Logic
1. Streak tracking (daily, local, with calendar day logic)
2. Heart system (5 max, decrease on wrong, refill timer)
3. XP accumulation
4. Hearts-empty modal (watch ad / go premium)
5. Heart refill animation

### Block 5: AI Practice (Gemini + Paywall + Ads)
1. Chat UI for "Practice with Tarsier"
2. Gemini API integration (load system prompt from lesson JSON)
3. Message sending, receiving, display
4. Session gating: 1 free per chapter, then paywall or ad
5. Superwall paywall integration
6. RevenueCat subscription tracking
7. AdMob rewarded video integration (heart refill + extra practice)

### Block 6: Settings + Polish + Ship Prep
1. Settings screen
2. Photo credits/attribution screen
3. App icon (placeholder — tarsier on blue background)
4. Launch screen
5. Haptic feedback on quiz answers
6. Review all transitions and animations
7. Test full lesson flow end-to-end
8. Archive and submit to App Store

---

## Critical "Don't" List

- **DO NOT** use default SwiftUI List/Form styling for lesson content. Cards only.
- **DO NOT** use system blue (Color.blue) or system purple (Color.purple). Always use functionalPurple (#6B5B9A).
- **DO NOT** use pure white (#FFFFFF) for backgrounds. Use warmWhite (#FAFAF7).
- **DO NOT** use SF Pro. All text is SF Rounded (.design(.rounded)).
- **DO NOT** use sharp corners. Minimum corner radius is 12pt, standard is 16pt.
- **DO NOT** show multiple vocabulary words on one screen. One word per slide.
- **DO NOT** start quizzing before teaching. Slides 1-4 teach, slide 5 quizzes.
- **DO NOT** use Color.gray for borders. Use cardBorder (#E8E4DF) — warm, not clinical.
- **DO NOT** add features not in this spec. Ship the MVP.

---

## SPM Packages (Add Manually in Xcode — Claude Code cannot modify .pbxproj)

These need to be added by Ean in Xcode before Claude Code can use them:
- **RevenueCat** — `https://github.com/RevenueCat/purchases-ios`
- **SuperwallKit** — `https://github.com/superwall/Superwall-iOS`
- **GoogleMobileAds** — `https://github.com/googleads/swift-package-manager-google-mobile-ads`
- **GoogleGenerativeAI** — `https://github.com/google/generative-ai-swift`

Until packages are added, Claude Code should stub the integration points with TODOs and protocol-based abstractions so the rest of the app works independently.

---

## Sample Lesson JSONs

Reference files in `docs/Lessons/`:
- `lesson_001_po.json` — Lesson 1 (Po & Opo, Chapter 1) — the opening lesson, zero grammar, pure cultural immersion
- Future lessons follow the same schema with affix breakdowns added from Lesson 5 onward

Read these before building the slide engine. The JSON structure defines the slide types, quiz formats, and data shapes the app needs to render.

---

## Build Tasks

Current build phase tasks are in `docs/Claude/v0/v0.1-Foundation.md`. Follow the block order defined in the "Build Order" section above. Complete one block at a time. Do not skip ahead.

---

## One More Thing

The full curriculum is in `docs/Tarsier_Roadmap.md`. Read it for the 30-lesson roadmap, chapter groupings, affix introduction order, and every "Alam Mo Ba?" entry. The research and design decisions behind every choice are in `docs/Tarsier_Research.md`. These are the content bibles — the app is just the vessel.
