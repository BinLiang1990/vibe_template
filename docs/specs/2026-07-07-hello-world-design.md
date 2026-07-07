# Design: Hello World static page (issue #1)

## Problem
Repo has no code yet. Issue #1 asks for a minimal "hello world" as the first
artifact. Issue #3 (separate PR) will add a lunch-suggestion button on top of
this page, so the page needs a stable place to hang a button later.

## Decision
Plain static HTML/CSS/JS, no build step, no framework (operator-confirmed).
Single page at `public/index.html` with a linked stylesheet and a linked JS
file (empty for now, wired up so issue #3 can add a click handler without
restructuring anything).

## Layout
```
public/
  index.html   - "Hello, World!" heading, container for future button
  style.css    - minimal styling
  app.js       - empty entry point, loaded via <script defer>
```

## Test plan
No build tooling in the repo, so "tests" here are a scripted smoke check:
`scripts/test-hello-world.sh` starts a static file server on a fixed port,
curls `index.html`, and asserts the response contains "Hello, World!" and
correctly links style.css/app.js. This gives a red/green signal for CI
without introducing a JS test framework for a static page.

## Out of scope
Any framework/build tooling, the lunch button itself (issue #3), styling
beyond minimal legibility, deployment.
