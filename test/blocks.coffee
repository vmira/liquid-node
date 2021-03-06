Liquid = requireLiquid()
Promise = require "bluebird"

describe "Blocks (in general)", ->
  beforeEach -> @engine = new Liquid.Engine

  it "don't accept 'else'", ->
    expect(@engine.parse("{% capture %}{% else %}{% endcapture %}")).to.be.rejectedWith Liquid.SyntaxError,
      /tag does not expect else tag/

  it "don't accept plain 'end'", ->
    expect(@engine.parse("{% capture %}{% end %}")).to.be.rejectedWith Liquid.SyntaxError,
      /'end' is not a valid delimiter/

  it "fail if not terminated", ->
    expect(@engine.parse("{% capture %}")).to.be.rejectedWith Liquid.SyntaxError,
      /tag was never closed/

  it "fail on odd tags", ->
    expect(@engine.parse("{% %}")).to.be.rejectedWith Liquid.SyntaxError,
      /was not properly terminated/

  it "fail on illegal variables", ->
    expect(@engine.parse("{{ 2394 ")).to.be.rejectedWith Liquid.SyntaxError,
      /Variable .* was not properly terminated/

describe "Assign", ->
  it "assigns a variable", ->
    renderTest '.foo.', '{% assign foo = values %}.{{ foo[0] }}.',
      values: ["foo", "bar", "baz"]

  it "assigns a variable", ->
    renderTest  '.bar.', '{% assign foo = values %}.{{ foo[1] }}.',
      values: ["foo", "bar", "baz"]

describe "For", ->
  it "loops", ->
    renderTest(' 1  2  3 ', '{%for item in array%} {{item}} {%endfor%}', array: [1, 2, 3])

  it "loops", ->
    renderTest('123', '{%for item in array%}{{item}}{%endfor%}', array: [1, 2, 3])

  it "loops", ->
    renderTest('abcd', '{%for item in array%}{{item}}{%endfor%}', array: ['a', 'b', 'c', 'd'])

  it "loops", ->
    renderTest('a b c', '{%for item in array%}{{item}}{%endfor%}', array: ['a', ' ', 'b', ' ', 'c'])

  it "loops", ->
    renderTest('abc', '{%for item in array%}{{item}}{%endfor%}', array: ['a', '', 'b', '', 'c'])

  it "loops over ranges", ->
    renderTest '1234', '{%for item in (1..4)%}{{item}}{%endfor%}'

  it "supports else", ->
    renderTest 'none yet', '{% for item in array %}{{ item }}{% else %}none yet{% endfor %}'

  describe "with reverse", ->
    it "does not modify the source array", ->
      array = [ 1, 2, 3 ]
      renderTest('321', '{% for item in array reversed %}{{ item }}{% endfor %}', array: array).then ->
        # assert array unmodified
        expect(array.length).to.eql 3
        expect(array[0]).to.eql 1

  describe "with index", ->
    it "renders correctly", ->
      renderTest('123', '{%for item in array%}{{forloop.index}}{%endfor%}', array: [1,2,3])
    it "renders correctly", ->
      renderTest('321', '{%for item in array%}{{forloop.rindex}}{%endfor%}', array: [1,2,3])
    it "renders correctly", ->
      renderTest('210', '{%for item in array%}{{forloop.rindex0}}{%endfor%}', array: [1,2,3])
    it "renders correctly", ->
      renderTest('123', '{%for item in array%}{{forloop.index}}{%endfor%}', array: ['a','b','c'])
    it "renders correctly", ->
      renderTest('123', '{%for item in array%}{{forloop.index}}{%endfor%}', array: ['a','b','c'])
    it "renders correctly", ->
      renderTest('012', '{%for item in array%}{{forloop.index0}}{%endfor%}', array: ['a','b','c'])
    it "renders correctly", ->
      renderTest('1234', '{%for item in array%}{{forloop.index}}{%endfor%}', array: [{a:1},{b:1},{c:1},{d:1}])
    it "renders correctly", ->
      renderTest('', '{%for item in array%}{{forloop.index}}{%endfor%}', array: [])
    it "renders correctly", ->
      renderTest('first123', '{% for item in array %}{% if forloop.first%}first{% endif %}{{forloop.index}}{% endfor %}', array: [1,2,3])
    it "renders correctly", ->
      renderTest('123last', '{% for item in array %}{{forloop.index}}{% if forloop.last%}last{% endif %}{% endfor %}', array: [1,2,3])
    it "renders correctly", ->
      renderTest('vw', '{%for item in array limit:2%}{{item}}{%endfor%}', array: ['v','w','x','y'])
    it "renders correctly", ->
      renderTest('xy', '{%for item in array offset:2%}{{item}}{%endfor%}', array: ['v','w','x','y'])

describe "IfChanged", ->
  it "renders correctly", ->
    renderTest('123', '{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}', array: [ 1, 1, 2, 2, 3, 3 ])
  it "renders correctly", ->
    renderTest('1', '{%for item in array%}{%ifchanged%}{{item}}{% endifchanged %}{%endfor%}', array: [ 1, 1, 1, 1 ])

describe "Capture", ->
  it "captures", ->
    renderTest 'X', '{% capture foo %}Foo{% endcapture %}{% if "Foo" == foo %}X{% endif %}'

  it "assigns a variable", ->
    renderTest  '.bar.', '{% assign foo = values %}.{{ foo[1] }}.',
      values: ["foo", "bar", "baz"]

describe "Raw", ->
  it "ignores liquid-tags in body", ->
    renderTest '{% if value %}{{ value }}{% endif %}',
      '{% raw %}{% if value %}{{ value }}{% endif %}{% endraw %}',
      value: true

describe "Comment", ->
  it "it swallows it's body", ->
    renderTest '',
      '{% comment %}This is a comment{% endcomment %}'

describe "Increment", ->
  it "increments like i++", ->
    renderTest '1', '{% increment i %}', i: 1

  it "interprents non-existing variables as 0", ->
    renderTest '0', '{% increment i %}'

describe "Decrements", ->
  it "decrements like --i", ->
    renderTest '0', '{% decrement i %}', i: 1

  it "interprents non-existing variables as 0", ->
    renderTest '-1', '{% decrement i %}'
