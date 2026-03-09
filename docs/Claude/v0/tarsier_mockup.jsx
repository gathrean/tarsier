import { useState } from "react";

const C = { brandPurple: "#8778C3", fnPurple: "#6B5B9A", gold: "#FCD116", red: "#CE1126", green: "#2ECC71", dark: "#302B27", cream: "#FFF5E6", white: "#FAFAF7", text1: "#1A1A1A", text2: "#6B6B6B", border: "#E8E4DF", heart: "#E74C3C" };

const Eyes = ({ s = 40 }) => (<svg width={s} height={s} viewBox="0 0 60 60"><circle cx="30" cy="30" r="28" fill={C.dark}/><circle cx="20" cy="26" r="10" fill={C.gold}/><circle cx="40" cy="26" r="10" fill={C.gold}/><circle cx="20" cy="26" r="4.5" fill={C.dark}/><circle cx="40" cy="26" r="4.5" fill={C.dark}/><ellipse cx="30" cy="40" rx="4" ry="2.5" fill={C.dark} stroke={C.cream} strokeWidth="1"/><path d="M12 8Q8 2 6 6Q4 10 12 12" fill={C.dark}/><path d="M48 8Q52 2 54 6Q56 10 48 12" fill={C.dark}/></svg>);

const Mascot = ({ s = 120 }) => (<svg width={s} height={s} viewBox="0 0 120 140"><ellipse cx="60" cy="75" rx="35" ry="40" fill={C.dark}/><circle cx="60" cy="40" r="30" fill={C.dark}/><circle cx="48" cy="35" r="11" fill={C.gold}/><circle cx="72" cy="35" r="11" fill={C.gold}/><circle cx="48" cy="35" r="5" fill={C.dark}/><circle cx="72" cy="35" r="5" fill={C.dark}/><ellipse cx="60" cy="50" rx="4" ry="2.5" fill={C.dark} stroke={C.cream} strokeWidth="1.2"/><path d="M38 18Q32 4 28 12Q26 18 36 22" fill={C.dark}/><path d="M82 18Q88 4 92 12Q94 18 84 22" fill={C.dark}/><path d="M85 100Q95 110 90 120Q85 125 80 118" fill={C.dark}/><rect x="20" y="50" width="8" height="50" rx="4" fill={C.brandPurple} transform="rotate(-15,24,75)"/><polygon points="20,48 28,48 24,40" fill={C.cream} transform="rotate(-15,24,48)"/></svg>);

const Ht = ({ on = true }) => <span style={{ color: on ? C.heart : "#ddd", fontSize: 16 }}>♥</span>;

const S = { WELCOME: "w", SKILL: "sk", HOME: "h", WORDS: "wo", PROFILE: "p", LC: "lc", LT: "lt", LV: "lv", LQ: "lq", QF: "qf", LD: "ld", AI: "ai" };
const TABS = [S.HOME, S.WORDS, S.PROFILE];
const labels = { [S.WELCOME]: "Welcome", [S.SKILL]: "Skill Level", [S.HOME]: "Home / Roadmap", [S.WORDS]: "Words", [S.PROFILE]: "Profile", [S.LC]: "Slide: Cultural", [S.LT]: "Slide: Teaching", [S.LV]: "Slide: Vocabulary", [S.LQ]: "Slide: Quiz", [S.QF]: "Quiz Feedback", [S.LD]: "Lesson Complete", [S.AI]: "AI Practice" };

export default function App() {
  const [sc, setSc] = useState(S.WELCOME);
  const [tab, setTab] = useState("learn");
  const [skill, setSkill] = useState(null);
  const [ans, setAns] = useState(null);
  const [expW, setExpW] = useState(null);
  const [wordFilter, setWordFilter] = useState("all");

  const goTab = (t) => { setTab(t); setSc(t === "learn" ? S.HOME : t === "words" ? S.WORDS : S.PROFILE); };
  const showTabs = TABS.includes(sc);

  const f = { title: { fontSize: 24, fontWeight: 700, color: C.text1, fontFamily: "system-ui" }, heading: { fontSize: 20, fontWeight: 700, color: C.text1, fontFamily: "system-ui" }, body: { fontSize: 15, color: C.text1, fontFamily: "system-ui", lineHeight: 1.6 }, caption: { fontSize: 13, color: C.text2, fontFamily: "system-ui" }, tagWord: { fontSize: 32, fontWeight: 700, color: C.text1, fontFamily: "system-ui" } };

  const Btn = ({ children, onClick, off }) => (<div onClick={off ? undefined : onClick} style={{ backgroundColor: off ? "#ccc" : C.fnPurple, color: "white", padding: "16px 24px", borderRadius: 14, textAlign: "center", fontWeight: 600, fontSize: 17, fontFamily: "system-ui", cursor: off ? "default" : "pointer", margin: "0 20px" }}>{children}</div>);

  const Crd = ({ children, style = {}, onClick }) => (<div onClick={onClick} style={{ backgroundColor: C.cream, borderRadius: 16, border: `1px solid ${C.border}`, padding: 16, boxShadow: "0 2px 8px rgba(0,0,0,0.04)", cursor: onClick ? "pointer" : "default", ...style }}>{children}</div>);

  const PBar = ({ cur, tot }) => (<div style={{ padding: "0 20px", marginBottom: 12, display: "flex", alignItems: "center", gap: 12 }}><span onClick={() => { setSc(S.HOME); setTab("learn"); }} style={{ fontSize: 20, cursor: "pointer", opacity: 0.5 }}>✕</span><div style={{ flex: 1, height: 6, backgroundColor: C.border, borderRadius: 3 }}><div style={{ height: 6, width: `${(cur/tot)*100}%`, backgroundColor: C.fnPurple, borderRadius: 3, transition: "width 0.3s" }}/></div><span style={{ fontSize: 12, color: C.text2, fontFamily: "system-ui", fontWeight: 600 }}>{cur}/{tot}</span></div>);

  const TabBar = () => (<div style={{ height: 56, backgroundColor: C.white, borderTop: `0.5px solid ${C.border}`, display: "flex", alignItems: "center", justifyContent: "space-around", flexShrink: 0 }}>
    {[{ id: "learn", label: "Learn", icon: "📖" }, { id: "words", label: "Words", icon: "📝" }, { id: "profile", label: "Profile", icon: "👤" }].map(t => (
      <div key={t.id} onClick={() => goTab(t.id)} style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 2, cursor: "pointer", padding: "4px 20px", position: "relative" }}>
        <span style={{ fontSize: 18, filter: tab === t.id ? "none" : "grayscale(1) opacity(0.5)" }}>{t.icon}</span>
        <span style={{ fontSize: 10, fontWeight: 600, fontFamily: "system-ui", color: tab === t.id ? C.fnPurple : C.text2 }}>{t.label}</span>
        {tab === t.id && <div style={{ position: "absolute", top: -1, width: 4, height: 4, borderRadius: 2, backgroundColor: C.fnPurple }}/>}
      </div>
    ))}</div>);

  const TopBar = () => (<div style={{ padding: "8px 20px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
    <div style={{ display: "flex", alignItems: "center", gap: 6 }}><span style={{ fontSize: 18 }}>🔥</span><span style={{ fontWeight: 700, fontSize: 16, color: C.text1, fontFamily: "system-ui" }}>3</span></div>
    <div style={{ display: "flex", alignItems: "center", gap: 4, backgroundColor: `${C.fnPurple}15`, padding: "4px 12px", borderRadius: 12 }}><span style={{ fontSize: 12, fontWeight: 700, color: C.fnPurple, fontFamily: "system-ui" }}>45 XP</span></div>
    <div style={{ display: "flex", gap: 3 }}>{[1,2,3,4,5].map(i => <Ht key={i} on={i<=4}/>)}</div>
  </div>);

  const TaRe = ({ text }) => (<div style={{ borderLeft: `3px solid ${C.fnPurple}`, backgroundColor: `${C.brandPurple}08`, borderRadius: "0 8px 8px 0", padding: "8px 12px", marginTop: 8 }}><div style={{ fontSize: 12, color: C.fnPurple, fontWeight: 600, fontFamily: "system-ui", marginBottom: 2 }}>Taglish Reality</div><div style={{ ...f.caption, lineHeight: 1.5 }}>{text}</div></div>);

  const renderScreen = () => {
    switch (sc) {
      case S.WELCOME: return (
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", height: "100%", padding: 20, background: `linear-gradient(180deg, ${C.white} 60%, ${C.brandPurple}15 100%)` }}>
          <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
            <div style={{ width: 140, height: 140, borderRadius: 35, backgroundColor: C.brandPurple, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 32 }}><Mascot s={110}/></div>
            <div style={{ fontSize: 36, fontWeight: 700, color: C.fnPurple, fontFamily: "system-ui", letterSpacing: -0.5 }}>Tarsier</div>
            <div style={{ fontSize: 18, color: C.text2, fontFamily: "system-ui", marginTop: 4 }}>Learn Tagalog</div>
          </div>
          <div style={{ width: "100%", paddingBottom: 40 }}><Btn onClick={() => setSc(S.SKILL)}>Get Started</Btn></div>
        </div>);

      case S.SKILL: return (
        <div style={{ padding: 20, display: "flex", flexDirection: "column", height: "100%" }}>
          <div style={f.title}>How much Tagalog do you know?</div>
          <div style={{ ...f.caption, marginBottom: 24, marginTop: 8 }}>This helps us start you in the right place.</div>
          <div style={{ display: "flex", flexDirection: "column", gap: 12, flex: 1 }}>
            {[{ id: "none", label: "None", desc: "I'm starting fresh" }, { id: "some", label: "Some — I understand but can't speak", desc: "The most common for heritage learners", hl: true }, { id: "conv", label: "Conversational", desc: "I want to improve and go deeper" }].map(o => (
              <Crd key={o.id} onClick={() => setSkill(o.id)} style={{ border: skill === o.id ? `2px solid ${C.fnPurple}` : `1px solid ${C.border}`, backgroundColor: skill === o.id ? `${C.brandPurple}12` : C.cream, display: "flex", alignItems: "center", gap: 12 }}>
                <div style={{ width: 24, height: 24, borderRadius: 12, border: `2px solid ${skill === o.id ? C.fnPurple : C.border}`, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>{skill === o.id && <div style={{ width: 12, height: 12, borderRadius: 6, backgroundColor: C.fnPurple }}/>}</div>
                <div><div style={{ fontWeight: 600, fontSize: 16, color: C.text1, fontFamily: "system-ui" }}>{o.label}</div><div style={{ ...f.caption, marginTop: 2 }}>{o.desc}</div>{o.hl && <div style={{ fontSize: 11, color: C.fnPurple, fontFamily: "system-ui", marginTop: 4, fontWeight: 600 }}>Most common</div>}</div>
              </Crd>))}
          </div>
          <div style={{ paddingBottom: 20 }}><Btn off={!skill} onClick={() => { setSc(S.HOME); setTab("learn"); }}>Continue</Btn></div>
        </div>);

      case S.HOME: return (
        <div style={{ height: "100%" }}><TopBar/>
          <div style={{ padding: "0 20px", overflowY: "auto", height: "calc(100% - 48px)" }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: C.fnPurple, fontFamily: "system-ui", letterSpacing: 1, textTransform: "uppercase", marginBottom: 8 }}>Chapter 1</div>
            <div style={{ fontSize: 22, fontWeight: 700, color: C.text1, fontFamily: "system-ui", marginBottom: 20 }}>Magalang — Respect</div>
            <div style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
              {[{ n: 1, t: "Po & Opo", s: "done" }, { n: 2, t: "Kumusta", s: "done" }, { n: 3, t: "Oo, Hindi, Salamat", s: "cur" }, { n: 4, t: "Ako, Ikaw, Siya", s: "lock" }].map((l, i) => (
                <div key={l.n} style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
                  {i > 0 && <div style={{ width: 2, height: 24, backgroundColor: C.border }}/>}
                  <div onClick={() => l.s !== "lock" && setSc(S.LC)} style={{ width: 64, height: 64, borderRadius: 20, display: "flex", alignItems: "center", justifyContent: "center", cursor: l.s !== "lock" ? "pointer" : "default", marginLeft: i % 2 === 0 ? -40 : 40, backgroundColor: l.s === "done" ? C.fnPurple : l.s === "cur" ? C.cream : "#EEEAE6", border: l.s === "cur" ? `3px solid ${C.fnPurple}` : "none", boxShadow: l.s === "cur" ? `0 0 0 4px ${C.brandPurple}30` : "0 2px 4px rgba(0,0,0,0.06)" }}>
                    {l.s === "done" ? <span style={{ color: "white", fontSize: 22 }}>✓</span> : l.s === "lock" ? <span style={{ color: "#bbb", fontSize: 18 }}>🔒</span> : <span style={{ color: C.fnPurple, fontWeight: 700, fontSize: 20, fontFamily: "system-ui" }}>{l.n}</span>}
                  </div>
                  <div style={{ marginLeft: i % 2 === 0 ? -40 : 40, marginTop: 6 }}><div style={{ fontSize: 12, fontWeight: 600, color: l.s === "lock" ? "#bbb" : C.text1, fontFamily: "system-ui" }}>{l.t}</div></div>
                </div>))}
              <div style={{ width: 2, height: 24, backgroundColor: C.border }}/>
              <div style={{ width: 64, height: 64, borderRadius: 20, display: "flex", alignItems: "center", justifyContent: "center", backgroundColor: `${C.gold}20`, border: `2px dashed ${C.gold}` }} onClick={() => setSc(S.AI)}><Eyes s={36}/></div>
              <div style={{ fontSize: 12, fontWeight: 600, color: C.text2, fontFamily: "system-ui", marginTop: 6 }}>AI Practice</div>
              <div style={{ width: 2, height: 32, backgroundColor: C.border }}/>
              <div style={{ fontSize: 13, fontWeight: 600, color: C.fnPurple, fontFamily: "system-ui", letterSpacing: 1, textTransform: "uppercase", marginTop: 8, marginBottom: 8 }}>Chapter 2</div>
              <div style={{ fontSize: 18, fontWeight: 700, color: C.text1, fontFamily: "system-ui", marginBottom: 16 }}>Kain! — Food & Basics</div>
              {[{ n: 5, t: "Kain — Let's Eat" }, { n: 6, t: "Luto — Cooking" }].map((l, i) => (
                <div key={l.n} style={{ display: "flex", flexDirection: "column", alignItems: "center" }}>
                  {i > 0 && <div style={{ width: 2, height: 24, backgroundColor: C.border }}/>}
                  <div style={{ width: 56, height: 56, borderRadius: 18, display: "flex", alignItems: "center", justifyContent: "center", backgroundColor: "#EEEAE6", marginLeft: i % 2 === 0 ? 30 : -30 }}><span style={{ color: "#bbb", fontSize: 16 }}>🔒</span></div>
                  <div style={{ marginLeft: i % 2 === 0 ? 30 : -30, marginTop: 6 }}><div style={{ fontSize: 12, color: "#bbb", fontFamily: "system-ui", fontWeight: 600 }}>{l.t}</div></div>
                </div>))}
              <div style={{ height: 20 }}/>
            </div>
          </div>
        </div>);

      case S.WORDS: {
        const words = [
          { tl: "po", en: "politeness marker", root: null, afx: null, ch: 1 },
          { tl: "opo", en: "yes (respectful)", root: "oo + po", afx: null, ch: 1 },
          { tl: "salamat", en: "thank you", root: null, afx: null, ch: 1, borrow: "Spanish: salaam (Arabic)" },
          { tl: "mano po", en: "hand blessing", root: null, afx: null, ch: 1 },
          { tl: "kumusta", en: "how are you", root: null, afx: null, ch: 1, borrow: "Spanish: ¿Cómo está?" },
          { tl: "maganda", en: "beautiful", root: "ganda", afx: "ma-", ch: 1 },
          { tl: "kumain", en: "to eat / ate", root: "kain", afx: "um-", ch: 2 },
          { tl: "magluto", en: "to cook", root: "luto", afx: "mag-", ch: 2 },
          { tl: "nagluto", en: "cooked", root: "luto", afx: "nag-", ch: 2 },
          { tl: "pagkain", en: "food", root: "kain", afx: "pag-", ch: 2 },
        ];
        const fil = wordFilter === "all" ? words : words.filter(w => w.ch === parseInt(wordFilter));
        return (
          <div style={{ height: "100%" }}>
            <div style={{ padding: "16px 20px 0" }}>
              <div style={f.title}>Words</div>
              <div style={{ ...f.caption, marginBottom: 12 }}>{words.length} words learned</div>
              <div style={{ display: "flex", alignItems: "center", gap: 8, padding: "10px 14px", borderRadius: 12, backgroundColor: C.cream, border: `1px solid ${C.border}`, marginBottom: 12 }}>
                <span style={{ fontSize: 14, color: C.text2 }}>🔍</span><span style={{ fontSize: 14, color: `${C.text2}90`, fontFamily: "system-ui" }}>Search words...</span>
              </div>
              <div style={{ display: "flex", gap: 8, marginBottom: 16 }}>
                {["all", "1", "2"].map(fl => (<div key={fl} onClick={() => setWordFilter(fl)} style={{ padding: "6px 14px", borderRadius: 20, cursor: "pointer", fontSize: 13, fontWeight: 600, fontFamily: "system-ui", whiteSpace: "nowrap", backgroundColor: wordFilter === fl ? C.fnPurple : C.cream, color: wordFilter === fl ? "white" : C.text2, border: wordFilter === fl ? "none" : `1px solid ${C.border}` }}>{fl === "all" ? "All" : `Ch ${fl}`}</div>))}
              </div>
            </div>
            <div style={{ padding: "0 20px", overflowY: "auto", height: "calc(100% - 155px)" }}>
              {fil.map((w, i) => (
                <div key={i} onClick={() => setExpW(expW === i ? null : i)} style={{ cursor: "pointer", marginBottom: 8 }}>
                  <Crd style={{ padding: "12px 16px" }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                      <div><div style={{ fontSize: 18, fontWeight: 700, color: C.text1, fontFamily: "system-ui" }}>{w.tl}</div><div style={{ ...f.caption, marginTop: 2 }}>{w.en}</div></div>
                      <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                        {w.afx && <div style={{ padding: "3px 10px", borderRadius: 12, backgroundColor: `${C.brandPurple}15`, fontSize: 12, fontWeight: 600, color: C.fnPurple, fontFamily: "system-ui" }}>{w.afx}</div>}
                        <span style={{ fontSize: 12, color: C.text2, transform: expW === i ? "rotate(180deg)" : "none", transition: "transform 0.2s" }}>▼</span>
                      </div>
                    </div>
                    {expW === i && (<div style={{ marginTop: 12, paddingTop: 12, borderTop: `1px solid ${C.border}` }}>
                      {w.root && (<div style={{ marginBottom: 8 }}>
                        <div style={{ fontSize: 12, fontWeight: 600, color: C.fnPurple, fontFamily: "system-ui", marginBottom: 4 }}>Breakdown</div>
                        <div style={{ display: "flex", gap: 4, alignItems: "center" }}>
                          {w.afx && <span style={{ padding: "2px 8px", borderRadius: 6, backgroundColor: `${C.fnPurple}20`, color: C.fnPurple, fontSize: 16, fontWeight: 700, fontFamily: "system-ui" }}>{w.afx.replace("-","")}</span>}
                          {w.afx && <span style={{ color: C.text2 }}>+</span>}
                          <span style={{ padding: "2px 8px", borderRadius: 6, backgroundColor: `${C.dark}12`, color: C.dark, fontSize: 16, fontWeight: 700, fontFamily: "system-ui" }}>{w.root}</span>
                        </div>
                      </div>)}
                      {w.borrow && <div style={{ fontSize: 12, color: C.gold, fontWeight: 600, fontFamily: "system-ui", marginBottom: 4 }}>💡 {w.borrow}</div>}
                      <div style={{ display: "flex", justifyContent: "flex-end", marginTop: 8 }}><div style={{ padding: "6px 14px", borderRadius: 10, border: `1.5px solid ${C.fnPurple}`, fontSize: 13, fontWeight: 600, color: C.fnPurple, fontFamily: "system-ui" }}>Practice</div></div>
                    </div>)}
                  </Crd>
                </div>))}
            </div>
          </div>);
      }

      case S.PROFILE: return (
        <div style={{ height: "100%", padding: 20, overflowY: "auto" }}>
          <div style={{ display: "flex", alignItems: "center", gap: 16, marginBottom: 24 }}>
            <div style={{ width: 56, height: 56, borderRadius: 20, backgroundColor: C.brandPurple, display: "flex", alignItems: "center", justifyContent: "center" }}><Eyes s={40}/></div>
            <div><div style={{ fontSize: 20, fontWeight: 700, color: C.text1, fontFamily: "system-ui" }}>Learner</div><div style={f.caption}>Heritage speaker</div></div>
          </div>
          <div style={{ display: "flex", gap: 12, marginBottom: 24 }}>
            {[{ l: "Streak", v: "3 🔥", c: C.gold }, { l: "XP", v: "45", c: C.fnPurple }, { l: "Words", v: "10", c: C.dark }, { l: "Lessons", v: "2/30", c: C.green }].map(s => (
              <div key={s.l} style={{ flex: 1, textAlign: "center", padding: 12, borderRadius: 14, backgroundColor: C.cream, border: `1px solid ${C.border}` }}>
                <div style={{ fontSize: 18, fontWeight: 700, color: s.c, fontFamily: "system-ui" }}>{s.v}</div>
                <div style={{ fontSize: 11, color: C.text2, fontFamily: "system-ui", marginTop: 2 }}>{s.l}</div>
              </div>))}
          </div>
          {[{ s: "Profile", items: ["Skill level", "Motivation"] }, { s: "Preferences", items: ["Notifications", "Sound effects"] }, { s: "Subscription", items: ["Manage subscription", "Restore purchases"] }, { s: "About", items: ["Photo credits", "Privacy policy", "Send feedback"] }].map(g => (
            <div key={g.s} style={{ marginBottom: 16 }}>
              <div style={{ fontSize: 13, fontWeight: 600, color: C.text2, fontFamily: "system-ui", marginBottom: 8, textTransform: "uppercase", letterSpacing: 0.5 }}>{g.s}</div>
              <Crd style={{ padding: 0 }}>{g.items.map((item, i) => (
                <div key={item} style={{ padding: "14px 16px", borderBottom: i < g.items.length - 1 ? `1px solid ${C.border}` : "none", display: "flex", justifyContent: "space-between" }}>
                  <span style={{ fontSize: 15, color: C.text1, fontFamily: "system-ui" }}>{item}</span><span style={{ color: C.text2 }}>›</span>
                </div>))}</Crd>
            </div>))}
        </div>);

      case S.LC: return (
        <div style={{ display: "flex", flexDirection: "column", height: "100%" }}><PBar cur={1} tot={9}/>
          <div style={{ flex: 1, padding: "0 20px", overflowY: "auto" }}>
            <div style={{ borderRadius: 16, overflow: "hidden", marginBottom: 16 }}><div style={{ height: 160, background: `linear-gradient(135deg, ${C.brandPurple}40, ${C.fnPurple}30)`, display: "flex", alignItems: "center", justifyContent: "center" }}><div style={{ textAlign: "center", color: "white" }}><div style={{ fontSize: 48 }}>🙏</div><div style={{ fontSize: 12, opacity: 0.8, marginTop: 4, fontFamily: "system-ui" }}>Photo: Filipino family mano po</div></div></div></div>
            <div style={{ fontSize: 22, fontWeight: 700, color: C.fnPurple, fontFamily: "system-ui", marginBottom: 8 }}>The word that changes everything</div>
            <div style={{ ...f.body, marginBottom: 16 }}>There's one word in Tagalog that you can start using right now — even in English sentences. It has no direct translation. It's not 'sir' or 'ma'am.' It's a single particle that transforms any sentence from casual to respectful.</div>
            <div style={{ ...f.body, marginBottom: 16 }}>That word is <span style={{ fontWeight: 700, color: C.fnPurple, fontSize: 18 }}>po</span>.</div>
            <TaRe text={'In real conversation, po works even in full English: "I didn\'t eat yet po." Filipinos do this constantly.'}/>
          </div>
          <div style={{ padding: "12px 0 24px" }}><Btn onClick={() => setSc(S.LT)}>Continue</Btn></div>
        </div>);

      case S.LT: return (
        <div style={{ display: "flex", flexDirection: "column", height: "100%" }}><PBar cur={3} tot={9}/>
          <div style={{ flex: 1, padding: "0 20px", overflowY: "auto" }}>
            <div style={f.heading}>Where does 'po' go?</div>
            <div style={{ ...f.body, marginBottom: 24, marginTop: 8 }}>Po usually goes after the verb or pronoun. Putting it at the end also works — the safest default for beginners.</div>
            {[{ tl: "Kumain na po ako.", en: "I already ate (respectful).", note: "After 'na', before 'ako'" }, { tl: "Salamat po.", en: "Thank you (respectful).", note: "End of sentence — simplest" }, { tl: "Saan po ito?", en: "Where is this? (respectful)", note: "After 'saan' (where)" }].map((ex, i) => (
              <Crd key={i} style={{ marginBottom: 12 }}>
                <div style={{ fontSize: 18, fontWeight: 700, color: C.text1, fontFamily: "system-ui", marginBottom: 4 }}>{ex.tl.split("po").map((p, j) => j === 0 ? <span key={j}>{p}<span style={{ color: C.fnPurple, backgroundColor: `${C.brandPurple}15`, padding: "1px 4px", borderRadius: 4 }}>po</span></span> : <span key={j}>{p}</span>)}</div>
                <div style={{ ...f.caption, marginBottom: 6 }}>{ex.en}</div>
                <div style={{ fontSize: 12, color: C.fnPurple, fontFamily: "system-ui", fontWeight: 500 }}>↳ po goes: {ex.note}</div>
              </Crd>))}
          </div>
          <div style={{ padding: "12px 0 24px" }}><Btn onClick={() => setSc(S.LV)}>Continue</Btn></div>
        </div>);

      case S.LV: return (
        <div style={{ display: "flex", flexDirection: "column", height: "100%" }}><PBar cur={5} tot={9}/>
          <div style={{ flex: 1, padding: "0 20px", display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
            <div style={{ width: "100%", height: 140, borderRadius: 16, background: `linear-gradient(135deg, ${C.brandPurple}25, ${C.cream})`, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 24 }}><span style={{ fontSize: 56 }}>🙏🏽</span></div>
            <div style={f.tagWord}>mano po</div>
            <div style={{ ...f.caption, marginBottom: 2 }}>MAH-noh poh</div>
            <div style={{ display: "flex", alignItems: "center", gap: 6, marginBottom: 20 }}><div style={{ width: 28, height: 28, borderRadius: 14, backgroundColor: `${C.text2}20`, display: "flex", alignItems: "center", justifyContent: "center" }}><span style={{ fontSize: 14 }}>🔊</span></div><span style={{ fontSize: 11, color: C.text2, fontFamily: "system-ui" }}>Coming soon</span></div>
            <div style={{ fontSize: 16, color: C.text2, fontFamily: "system-ui", textAlign: "center", marginBottom: 20 }}>hand blessing gesture + words said while doing it</div>
            <Crd style={{ width: "100%" }}>
              <div style={{ fontSize: 16, fontWeight: 600, color: C.text1, fontFamily: "system-ui", marginBottom: 4 }}>Mano po, Lola.</div>
              <div style={{ ...f.caption, marginBottom: 10 }}>Bless me, Grandmother.</div>
              <TaRe text="You take an elder's hand and press the back of it to your forehead as you say this."/>
            </Crd>
          </div>
          <div style={{ padding: "12px 0 24px" }}><Btn onClick={() => setSc(S.LQ)}>Continue</Btn></div>
        </div>);

      case S.LQ: return (
        <div style={{ display: "flex", flexDirection: "column", height: "100%" }}><PBar cur={7} tot={9}/>
          <div style={{ flex: 1, padding: "0 20px" }}>
            <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 8 }}><div style={{ display: "flex", gap: 3 }}>{[1,2,3,4].map(i => <Ht key={i}/>)}<Ht on={false}/></div></div>
            <div style={{ ...f.heading, fontSize: 18, marginBottom: 20, lineHeight: 1.4 }}>You're meeting your friend's lola for the first time. How do you say 'thank you'?</div>
            {["Salamat.", "Salamat po.", "Thanks!", "Salamat naman."].map((o, i) => (
              <div key={i} onClick={() => setAns(i)} style={{ padding: "14px 16px", borderRadius: 14, border: ans === i ? `2px solid ${C.fnPurple}` : `1.5px solid ${C.border}`, backgroundColor: ans === i ? `${C.brandPurple}10` : C.cream, marginBottom: 10, cursor: "pointer", fontSize: 16, fontFamily: "system-ui", fontWeight: ans === i ? 600 : 400, color: C.text1, transition: "all 0.15s" }}>{o}</div>))}
          </div>
          <div style={{ padding: "12px 0 24px" }}><Btn off={ans === null} onClick={() => setSc(S.QF)}>Check</Btn></div>
        </div>);

      case S.QF: { const ok = ans === 1; return (
        <div style={{ display: "flex", flexDirection: "column", height: "100%" }}><PBar cur={7} tot={9}/>
          <div style={{ flex: 1, padding: "0 20px" }}>
            <div style={{ ...f.heading, fontSize: 18, marginBottom: 20 }}>You're meeting your friend's lola for the first time. How do you say 'thank you'?</div>
            {["Salamat.", "Salamat po.", "Thanks!", "Salamat naman."].map((o, i) => (
              <div key={i} style={{ padding: "14px 16px", borderRadius: 14, border: i === 1 ? `2px solid ${C.green}` : i === ans && i !== 1 ? `2px solid ${C.red}` : `1.5px solid ${C.border}`, backgroundColor: i === 1 ? `${C.green}15` : i === ans && i !== 1 ? `${C.red}10` : C.cream, marginBottom: 10, fontSize: 16, fontFamily: "system-ui", fontWeight: i === 1 || i === ans ? 600 : 400, color: C.text1 }}>{o} {i === 1 && "✓"}</div>))}
          </div>
          <div style={{ backgroundColor: ok ? `${C.green}12` : `${C.red}08`, borderTop: `3px solid ${ok ? C.green : C.red}`, padding: "16px 20px 32px", borderRadius: "20px 20px 0 0" }}>
            <div style={{ fontSize: 18, fontWeight: 700, color: ok ? C.green : C.red, fontFamily: "system-ui", marginBottom: 8 }}>{ok ? "Tama! ✨" : "Hindi pa — not quite"}</div>
            <div style={{ ...f.body, fontSize: 14, marginBottom: 16 }}>When speaking to an elder you've just met, 'po' is essential. 'Salamat po' shows respect. Without po, it's too casual for a lola.</div>
            <Btn onClick={() => { setAns(null); setSc(S.LD); }}>Continue</Btn>
          </div>
        </div>); }

      case S.LD: return (
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", height: "100%", padding: 20 }}>
          <div style={{ fontSize: 48, marginBottom: 16 }}>🎉</div>
          <div style={{ fontSize: 26, fontWeight: 700, color: C.text1, fontFamily: "system-ui", marginBottom: 8 }}>Lesson Complete!</div>
          <div style={{ display: "flex", gap: 24, margin: "16px 0 32px" }}>
            {[{ v: "+15", l: "XP earned", c: C.fnPurple }, { v: "🔥 4", l: "Day streak", c: C.gold }, { v: "5/5", l: "Correct", c: C.green }].map(s => (
              <div key={s.l} style={{ textAlign: "center" }}><div style={{ fontSize: 28, fontWeight: 700, color: s.c, fontFamily: "system-ui" }}>{s.v}</div><div style={{ fontSize: 12, color: C.text2, fontFamily: "system-ui" }}>{s.l}</div></div>))}
          </div>
          <div style={{ fontSize: 14, fontWeight: 600, color: C.text2, fontFamily: "system-ui", marginBottom: 12 }}>Words learned</div>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 8, justifyContent: "center", marginBottom: 40 }}>
            {["po", "opo", "hindi po", "mano po", "salamat po", "sige po"].map(w => (<div key={w} style={{ padding: "6px 14px", borderRadius: 20, backgroundColor: `${C.brandPurple}15`, color: C.fnPurple, fontSize: 14, fontWeight: 600, fontFamily: "system-ui" }}>{w}</div>))}
          </div>
          <Btn onClick={() => { setSc(S.HOME); setTab("learn"); }}>Continue</Btn>
        </div>);

      case S.AI: return (
        <div style={{ display: "flex", flexDirection: "column", height: "100%" }}>
          <div style={{ padding: "8px 20px", display: "flex", alignItems: "center", justifyContent: "space-between", borderBottom: `1px solid ${C.border}` }}>
            <span onClick={() => { setSc(S.HOME); setTab("learn"); }} style={{ fontSize: 18, cursor: "pointer", opacity: 0.5 }}>✕</span>
            <div style={{ display: "flex", alignItems: "center", gap: 6 }}><Eyes s={24}/><span style={{ fontWeight: 700, fontSize: 16, color: C.text1, fontFamily: "system-ui" }}>Practice with Tarsier</span></div>
            <div style={{ width: 18 }}/>
          </div>
          <div style={{ flex: 1, padding: 20, overflowY: "auto" }}>
            <div style={{ display: "flex", gap: 8, marginBottom: 16 }}><div style={{ flexShrink: 0 }}><Eyes s={32}/></div><Crd style={{ maxWidth: "80%", padding: 12 }}><div style={f.body}>Kumain ka na ba? 😊 Let's practice Chapter 1. Pretend you just arrived at a family gathering — how would you greet your friend's lola?</div></Crd></div>
            <div style={{ display: "flex", justifyContent: "flex-end", marginBottom: 16 }}><div style={{ maxWidth: "80%", backgroundColor: C.fnPurple, borderRadius: 16, padding: 12 }}><div style={{ fontSize: 15, color: "white", fontFamily: "system-ui", lineHeight: 1.5 }}>Mano po, Lola! Kumusta po kayo?</div></div></div>
            <div style={{ display: "flex", gap: 8 }}><div style={{ flexShrink: 0 }}><Eyes s={32}/></div><Crd style={{ maxWidth: "80%", padding: 12 }}><div style={f.body}>Ang galing! 🎉 Perfect — you used mano po AND kumusta po. Now she asks: "Kumain ka na ba?" — what do you say?</div></Crd></div>
          </div>
          <div style={{ padding: "12px 20px 24px", borderTop: `1px solid ${C.border}`, display: "flex", gap: 8 }}>
            <div style={{ flex: 1, padding: "12px 16px", borderRadius: 14, border: `1.5px solid ${C.border}`, fontSize: 15, color: C.text2, fontFamily: "system-ui" }}>Type your response...</div>
            <div style={{ width: 44, height: 44, borderRadius: 14, backgroundColor: C.fnPurple, display: "flex", alignItems: "center", justifyContent: "center", cursor: "pointer" }}><span style={{ color: "white", fontSize: 18 }}>↑</span></div>
          </div>
        </div>);

      default: return null;
    }
  };

  return (
    <div style={{ minHeight: "100vh", backgroundColor: "#F0EDE8", display: "flex", flexDirection: "column", alignItems: "center", padding: "20px 16px", fontFamily: "system-ui" }}>
      <div style={{ display: "flex", flexWrap: "wrap", gap: 5, justifyContent: "center", marginBottom: 20, maxWidth: 650 }}>
        {Object.entries(labels).map(([id, label]) => (
          <button key={id} onClick={() => { setSc(id); setAns(null); if (TABS.includes(id)) setTab(id === S.WORDS ? "words" : id === S.PROFILE ? "profile" : "learn"); }}
            style={{ padding: "5px 10px", borderRadius: 10, border: "none", backgroundColor: sc === id ? C.fnPurple : "white", color: sc === id ? "white" : C.text1, fontSize: 11, fontWeight: 600, cursor: "pointer", fontFamily: "system-ui" }}>{label}</button>
        ))}
      </div>
      <div style={{ width: 375, height: 750, backgroundColor: C.white, borderRadius: 40, overflow: "hidden", boxShadow: "0 20px 60px rgba(0,0,0,0.15)", border: `3px solid ${C.border}`, display: "flex", flexDirection: "column" }}>
        <div style={{ height: 44, backgroundColor: C.white, display: "flex", alignItems: "center", justifyContent: "center", paddingTop: 8, flexShrink: 0 }}><div style={{ width: 120, height: 5, backgroundColor: C.dark, borderRadius: 3, opacity: 0.2 }}/></div>
        <div style={{ flex: 1, overflow: "auto" }}>{renderScreen()}</div>
        {showTabs && <TabBar/>}
      </div>
      <div style={{ marginTop: 16, fontSize: 12, color: C.text2, textAlign: "center", maxWidth: 400 }}>Tab bar visible on Learn, Words, Profile. Hidden during lessons, onboarding, AI practice. All colours match CLAUDE.md.</div>
    </div>
  );
}
