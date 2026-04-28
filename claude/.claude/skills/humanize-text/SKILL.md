---
name: humanize-text
description: Rewrite AI-generated text so it reads like a human wrote it, without losing meaning or intent. Use this skill whenever the user asks to "humanize", "de-AI", "make this sound human/natural/less robotic", "remove the AI tells", or pastes a draft (email reply, cover letter, message, LinkedIn post, comment, blog draft, doc) and asks to clean it up, edit it, soften it, or make it sound more like them. Also trigger when the user complains that something "sounds AI", has "too many em dashes", or "sounds like ChatGPT/Claude wrote it". Apply this skill even when the user does not explicitly use the word "humanize" — if they're handing you AI-flavored prose and want it polished before they send it, this is the skill.
---

# humanize-text

Rewrite AI-generated text so a careful reader would not flag it as machine-written, while preserving the meaning, tone target, and any factual content.

The core failure mode of this task is **over-rewriting** — stripping out so much structure or polish that the meaning shifts or the message gets weaker. The goal is targeted surgery, not a full rewrite. Every change should be defensible: "this phrase was an AI tell, so I replaced it with X."

## Process

Work in three passes. Do not skip the diagnosis pass — diving straight into rewriting tends to produce another AI-flavored draft.

### Pass 1: Diagnose

Read the input and silently mark every AI tell you can find using the checklist in the "AI tells" section below. Group them mentally into:

- **Punctuation/typography tells** (em dashes as parenthetical breaks, smart quotes in casual contexts, etc.)
- **Phrase tells** (specific words/idioms LLMs overuse)
- **Structural tells** (rule-of-three, "not just X, but Y", over-bulleting, summary closers)
- **Tone tells** (over-enthusiasm, hedging stacks, performative balance)

If the input has very few tells, say so and make minimal changes. Don't invent flaws to fix.

### Pass 2: Rewrite

Rewrite the text applying the fixes below. While doing so:

1. **Preserve meaning, facts, names, numbers, and any specific claims.** If the original says "I led a team of 7", the rewrite still says "I led a team of 7" — not "a small team" or "several people".
2. **Match the original register.** A cover letter rewrite stays professional; a casual reply stays casual. Don't make formal text breezy or vice versa unless the user asks.
3. **Vary sentence length.** AI prose tends toward medium-length sentences in lockstep. Mix in some short ones. Let some run a little long if the thought is long.
4. **Allow small imperfections.** Real human writing has the occasional dangling "and", a sentence that starts with "But" or "So", a contraction, a slightly awkward phrasing the writer didn't bother to polish. Don't make it sloppy — just don't make it perfect.
5. **Cut, don't replace, where possible.** A lot of AI text bloat comes from filler ("It's worth noting that…", "In essence…", "Ultimately…"). Deleting these usually beats finding a "human" replacement.

### Pass 3: Sanity check

Before returning the rewrite, check:

- Did any factual content change? (If yes, restore it.)
- Did the ask/intent of the original survive? (Especially in emails — the actual request must still be clear.)
- Are there any leftover tells from the checklist?
- Does it read like something *this person* might write? If the user has shared past samples of their writing, lean toward that voice.

If the user asked for a brief rewrite, just return the rewritten text. If they asked "what was AI about it?" or "explain the changes", return the rewrite plus a short bullet list of the main changes.

## AI tells

This is the working checklist. Not every tell is wrong in every context — judgment matters — but each one should make you pause.

### Punctuation and typography

- **Em dashes used as parenthetical breaks.** "The plan — which we drafted last week — needs review." Replace with commas, parentheses, or two sentences. The em dash itself isn't bad; the *frequency* is the tell. If a 200-word email has three em dashes, two of them have to go.
- **Em dashes used for dramatic pivots.** "I thought it was over — but it wasn't." Often better as two sentences or with a comma.
- **Smart/curly quotes in casual contexts** (texts, Slack, code comments). Use straight quotes there.
- **Title Case In Headings That Don't Need Headings At All.**
- **Excessive colons introducing lists** in prose that should just be prose.

### Phrases LLMs overuse

Cut or replace on sight unless the user's voice genuinely uses them:

- "delve into", "dive deep", "navigate" (as a verb for abstract things), "journey"
- "leverage" (use "use"), "utilize" (use "use"), "robust", "seamless", "comprehensive", "vibrant", "rich tapestry", "landscape", "realm"
- "in today's fast-paced world", "in the ever-evolving"
- "game-changer", "elevate", "unlock", "unleash", "supercharge"
- "it's worth noting that", "it's important to remember", "it's crucial to understand"
- "furthermore", "moreover", "additionally" (often deletable; "and" or a new sentence works)
- "I hope this [email/message] finds you well" (in emails)
- "Please don't hesitate to reach out", "I'd be happy to" (overused openers/closers)
- "ultimately", "in essence", "at its core", "fundamentally" (usually filler)
- "nuanced", "multifaceted" (often vague)
- "Great question!", "Absolutely!", "Certainly!" as openers

### Structural tells

- **"Not just X — it's Y" / "It isn't about X. It's about Y."** Pivot constructions. Powerful once; an AI tell when used twice in 300 words.
- **Tricolons (rule of three).** "Clear, concise, and compelling." "Fast, reliable, and scalable." Drop one of the three or just pick the strongest word.
- **Symmetrical paragraph structure.** Three paragraphs, each ~3 sentences, each with the same shape. Break the symmetry.
- **Closing summary that restates the message.** Emails and short messages don't need a "To summarize…" or "In short…" closer. Cut it.
- **Bullets where prose would be more natural.** Casual messages and most emails read better as paragraphs. Only keep bullets if the content is genuinely list-shaped (a real enumeration, comparable items).
- **Headers in short pieces.** A 250-word email almost never needs `## Headers`.
- **Performative balance.** "While X has its merits, Y also offers compelling advantages." Real humans usually have a lean and show it.

### Tone tells

- **Over-hedging.** "It might be worth potentially considering whether perhaps…" Pick one hedge or none.
- **Over-enthusiasm.** Exclamation points stacked, "I'd love to", "I'm thrilled to", in contexts that don't warrant it.
- **Apology stacking** in professional contexts. "I'm so sorry to bother you, I really apologize for the inconvenience…" One apology, then the ask.
- **Robotic politeness in casual contexts.** A reply to a friend that reads like customer service.
- **No contractions** when contractions would be natural. "I am writing to follow up" → "I'm following up".

## Examples

**Example 1 — Email reply**

Input:
> Hi Sarah,
>
> I hope this email finds you well. Thank you so much for reaching out regarding the Q3 roadmap — I really appreciate you taking the time to share the latest updates with me.
>
> After reviewing the document carefully, I have a few thoughts I wanted to share. First, I think the timeline for the migration project is quite ambitious — given the scope of the work involved, we may want to consider building in some additional buffer. Second, I'd love to better understand how we're planning to handle the dependencies on the data team's deliverables.
>
> Please don't hesitate to let me know if you'd like to discuss further. I'd be happy to jump on a call.
>
> Best regards,
> Bharat

Output:
> Hi Sarah,
>
> Thanks for sending the Q3 roadmap. Two things on my mind after reading it:
>
> The migration timeline feels tight given the scope — worth building in a buffer? And I'd like to understand how we're handling the dependencies on the data team's deliverables.
>
> Happy to jump on a call if easier.
>
> Bharat

Notes on the changes: dropped "I hope this email finds you well", "thank you so much for reaching out", and the "please don't hesitate" closer (all classic AI email tells). Kept exactly one em dash where it earns its place. Cut the parallel "First… Second…" structure for something more conversational. Preserved both substantive points (timeline concern, dependency question).

**Example 2 — Cover letter paragraph**

Input:
> In my previous role at Acme Corp, I had the opportunity to leverage my expertise in distributed systems to architect a robust, scalable solution that not only reduced infrastructure costs by 30% but also significantly improved system reliability. This experience taught me the importance of building comprehensive solutions that elevate the entire engineering organization.

Output:
> At Acme, I designed the distributed system that cut our infrastructure costs by 30% and meaningfully reduced our incident rate. The thing I took away from it was that the work that pays off isn't the clever local fix — it's the boring foundational stuff the whole team ends up depending on.

Notes: "leverage", "robust", "scalable", "comprehensive", "elevate" — all cut. "Not only X but also Y" pivot — gone. The fluffy closer about "the importance of" replaced with an actual specific opinion that sounds like a person.

**Example 3 — Minimal changes warranted**

Input:
> Reviewed the PR. Two things — the retry logic in `client.go` doesn't back off, and the test for the timeout case is asserting on the wrong field. Otherwise looks good, ship after those.

Output:
> Reviewed the PR. Two things: the retry logic in `client.go` doesn't back off, and the test for the timeout case is asserting on the wrong field. Otherwise looks good — ship after those.

Notes: This was already mostly fine. Only swapped one em dash for a colon (the first em dash was being used as a list-introducer, which reads stiff) and moved the second em dash to where it does real work.

## When the user gives constraints

- **"Keep it the same length"** — match word count within ~10%.
- **"Make it shorter"** — aim for 30–50% reduction; AI text is usually padded.
- **"Match my voice" + sample provided** — read the sample first. Note their sentence length, contraction usage, formality, signature phrases. Then rewrite to match.
- **"Just remove the em dashes"** — do only that. Don't take it as license to rewrite the whole thing.

## What not to do

- Don't add slang or affected casualness if the original was professional. "Hey team, just wanted to drop a quick note" is its own kind of AI tell now.
- Don't introduce typos to fake humanity. Real humans make typos but don't fake them.
- Don't lose specificity. If the original had a number, a name, or a concrete detail, keep it.
- Don't editorialize about the original ("This was clearly AI-generated…") unless asked. Just do the rewrite.
- Don't refuse to rewrite something on the grounds that it "sounds fine" without showing the user what you'd change. Offer a diff or before/after.
