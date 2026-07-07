// Lunch-suggestion button (issue #3).

var LUNCH_OPTIONS = [
  '麻辣香锅',
  '牛肉面',
  '寿司',
  '沙拉',
  '汉堡',
  '炒饭',
  '火锅',
  '披萨',
  '饺子',
  '粥',
];

function pickRandomLunch() {
  var index = Math.floor(Math.random() * LUNCH_OPTIONS.length);
  return LUNCH_OPTIONS[index];
}

function initLunchButton() {
  var actions = document.getElementById('actions');
  if (!actions) return;

  var button = document.createElement('button');
  button.id = 'lunch-button';
  button.textContent = '中午吃什么？';

  var result = document.createElement('div');
  result.id = 'lunch-result';

  button.addEventListener('click', function () {
    result.textContent = pickRandomLunch();
  });

  actions.appendChild(button);
  actions.appendChild(result);
}

// Runs on real page load, and also on require() from the DOM-stub test
// (scripts/test-lunch-button.js), which sets global.document before this.
if (typeof document !== 'undefined') {
  initLunchButton();
}

if (typeof module !== 'undefined') {
  module.exports = { LUNCH_OPTIONS: LUNCH_OPTIONS, pickRandomLunch: pickRandomLunch };
}
