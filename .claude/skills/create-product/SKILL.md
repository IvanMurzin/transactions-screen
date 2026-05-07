---
name: create-product
description: Use to turn a rough product vision into a complete product source of truth. Conducts a deep interview about audience, problem, JTBD, MVP, monetization, financial model, acquisition, retention, analytics, risks, anti-goals, and roadmap. Populates docs/product/* with decision-complete files.
---

# create-product

Turns "I have an app idea" into a finished `docs/product/*`. The
output of this skill is the contract every future spec defends.

## When to use

- First-time setup of a new project bootstrapped from sdd_template.
- Major product pivots that invalidate big parts of the existing
  product docs.

Do **not** use this for small product tweaks — those go through
`create-spec` against the existing product docs.

## How it behaves

The skill is an interviewer, not a stenographer. Treat the user's
first description as a starting point and challenge it.

### Interview structure

For each topic, follow the loop: ask → push back on weak answers →
write a draft → confirm → move on. Do not let vague answers slip
through.

1. **Vision & "why now"** → `product_brief.md`
2. **Audience & JTBD** → `audience_and_jtbd.md`
3. **Problem & solution** → `problem_solution.md`
4. **MVP scope** → `mvp_scope.md`
5. **Business model** → `business_model.md`
6. **Financial model** → `financial_model.md`
7. **Acquisition & growth** → `acquisition_and_growth.md`
8. **Retention** → `retention.md`
9. **Metrics** → `metrics.md`
10. **Risks** → `risks.md`
11. **Roadmap** → `roadmap.md`
12. **Open questions** → `open_questions.md`

### Things you must push back on

- "Everyone is the audience" → narrow it.
- "We'll figure out monetization later" → at least name the
  hypothesis.
- "It's like X but better" → what specifically is the wedge?
- An MVP that requires more than one engineer-month → cut it down.
- Metrics that aren't measurable in app instrumentation → reword.

### Things you must NOT do

- Write code or specs.
- Ship vague filler ("the product will delight users").
- Skip a topic because the user is impatient — nudge them through.

## Output

- All files in `docs/product/` filled in. The README's table is the
  checklist.
- A short summary message listing what was decided and what remains
  in `open_questions.md`.

## Done when

- Every doc except `open_questions.md` has zero stub paragraphs.
- The user can read `mvp_scope.md` and tell a stranger what's in v1
  in under a minute.
- `metrics.md` lists 3-7 numbers with concrete definitions.
