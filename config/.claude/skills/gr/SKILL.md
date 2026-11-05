---
name: gr
description: Grammar check for any language (English, Brazilian Portuguese, Spanish, etc.). Takes a text, says whether it is grammatically correct, and suggests corrections and more natural alternatives. Use when the user runs /gr, or asks to check, proofread, fix or review the grammar, spelling or wording of a text ("is this correct?", "está certo?", "revisa esse texto", "fix my English").
---

# gr — grammar check

The input is the text after `/gr` (or the text the user asks to check). If there is no text, ask for it.

## How to check

1. Detect the language and variant (e.g. pt-BR vs pt-PT, en-US vs en-GB). Judge the text by the rules of that variant, so a correct Brazilian construction is not flagged as a European Portuguese error. If the text mixes languages, check each part in its own language.
2. Look for real errors: spelling, accents, agreement (number, gender, verb), verb tense and mood, prepositions and regência, crase, articles, punctuation, word order, wrong word choice (false friends, "affect/effect", "mas/mais").
3. Separately, note style points that are not errors: awkward or unnatural phrasing, repetition, overly formal or informal tone. Keep them apart so the user knows what is wrong versus what could just be better.
4. Respect the register. Informal text (chat, Slack) is not wrong for being informal; only flag it if it breaks grammar or the user asked for formal writing.
5. Do not change the meaning or the author's voice.

## Output

Write the explanations in the user's language (the language they talk to you in), not necessarily the language of the text.

If the text is correct, say so in one line, and offer at most one or two optional style alternatives if they really help.

Otherwise use this format:

**Language:** <language/variant>

**Corrected text:**
> <full corrected text>

**Corrections:**
| Original | Correction | Why |
|---|---|---|
| ... | ... | short reason (the rule) |

**Alternatives** (optional, style only):
- <a more natural or concise version, and when to use it>

Keep explanations short: one line per correction. For a long text, list every error but group repeated ones (e.g. "missing comma before 'mas' — 3 times").

## Examples

Input: `/gr Fazem dois anos que eu moro aqui e nunca fui no cinema.`

**Language:** Portuguese (pt-BR)

**Corrected text:**
> Faz dois anos que eu moro aqui e nunca fui ao cinema.

**Corrections:**
| Original | Correction | Why |
|---|---|---|
| Fazem | Faz | "fazer" indicating elapsed time is impersonal, always singular |
| no cinema | ao cinema | in formal writing "ir" takes "a"; "ir no" is common in speech |

Input: `/gr I didn't knew that she have two brothers.`

**Language:** English

**Corrected text:**
> I didn't know that she has two brothers.

**Corrections:**
| Original | Correction | Why |
|---|---|---|
| didn't knew | didn't know | after "did/didn't" use the base form |
| she have | she has | third person singular takes "has" |
