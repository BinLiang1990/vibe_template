// Test for the lunch-suggestion button logic (issue #3).
// Plain Node script (no test framework, no build step) with a hand-rolled
// DOM stub, to match the repo's no-framework constraint and this Node's
// lack of a built-in test runner.
const assert = require('assert');
const path = require('path');

function makeDomStub() {
  const elements = {};
  function makeElement(id) {
    let _id = id;
    const el = {
      textContent: '',
      _listeners: {},
      addEventListener(event, handler) {
        this._listeners[event] = handler;
      },
      appendChild(child) {
        this._children = this._children || [];
        this._children.push(child);
      },
      click() {
        if (this._listeners.click) this._listeners.click();
      },
    };
    Object.defineProperty(el, 'id', {
      get() {
        return _id;
      },
      set(value) {
        _id = value;
        elements[value] = el;
      },
    });
    if (id) elements[id] = el;
    return el;
  }
  elements.actions = makeElement('actions');
  return {
    getElementById(id) {
      return elements[id];
    },
    createElement() {
      return makeElement();
    },
    _elements: elements,
  };
}

function loadApp() {
  const domStub = makeDomStub();
  global.document = domStub;
  const appPath = path.join(__dirname, '..', 'public', 'app.js');
  delete require.cache[require.resolve(appPath)];
  const app = require(appPath);
  return { app, domStub };
}

let failures = 0;

function runTest(name, fn) {
  try {
    fn();
    console.log(`PASS: ${name}`);
  } catch (err) {
    failures += 1;
    console.log(`FAIL: ${name}`);
    console.log(err.message);
  }
}

runTest('LUNCH_OPTIONS is a non-empty list of strings', () => {
  const { app } = loadApp();
  assert.ok(Array.isArray(app.LUNCH_OPTIONS));
  assert.ok(app.LUNCH_OPTIONS.length > 0);
  for (const option of app.LUNCH_OPTIONS) {
    assert.strictEqual(typeof option, 'string');
    assert.ok(option.length > 0);
  }
});

runTest('pickRandomLunch always returns a known option', () => {
  const { app } = loadApp();
  for (let i = 0; i < 50; i++) {
    const pick = app.pickRandomLunch();
    assert.ok(app.LUNCH_OPTIONS.includes(pick));
  }
});

runTest('clicking the button renders a known option into the result element', () => {
  const { app, domStub } = loadApp();
  const button = domStub._elements['lunch-button'];
  const result = domStub._elements['lunch-result'];
  assert.ok(button, 'button should be wired into #lunch-button');
  assert.ok(result, 'result element should be wired into #lunch-result');

  for (let i = 0; i < 20; i++) {
    button.click();
    assert.ok(result.textContent.length > 0);
    assert.ok(app.LUNCH_OPTIONS.includes(result.textContent));
  }
});

process.exit(failures === 0 ? 0 : 1);
