# Design: Lunch suggestion button (issue #3)

## Problem
Issue #3: add a button that, when clicked, randomly generates a "what to
have for lunch" suggestion (in Chinese, per the issue text), so the operator
can decide what to eat.

## Decision
Extend the existing hello-world page (`public/`) rather than a new page.
`public/app.js` (currently an empty stub) gets:
- a hardcoded list of lunch options (Chinese text)
- a button appended into the existing `#actions` div in `index.html`
- a click handler that picks a random item and renders it into a result
  element next to the button

No backend, no persistence, no build step — consistent with issue #1's
static-site decision.

## Layout
```
public/
  index.html   - unchanged structurally; #actions div now holds button + result (rendered by JS)
  style.css    - add minor styling for button/result
  app.js       - lunch options array, click handler, DOM wiring
```

## Test plan
Extend the smoke-test approach used for issue #1: a Node script
(`scripts/test-lunch-button.js`) that loads `public/app.js` in a minimal DOM
(via `node --test` + a tiny hand-rolled DOM stub, no new dependency) and
asserts:
- the lunch options list is non-empty
- clicking the button sets the result text to one of the known options
- clicking repeatedly always yields a value from the known list (never
  empty/undefined)

Given the "no framework/build step" constraint, this test avoids adding
npm/jsdom as a dependency and instead stubs just the DOM surface the code
touches (`document.getElementById`, `textContent`, `addEventListener`).

## Out of scope
Persisting history of past suggestions, weighting/avoiding repeats,
external food APIs, styling beyond minimal legibility.
