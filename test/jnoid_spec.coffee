require 'coffee-script'
assert = require('chai').assert
Jnoid = require '../src/jnoid'

describe 'fromDOM', ->
  it 'exists', ->
    assert.isFunction Jnoid.fromDOM

describe 'more and noMore', ->
  it 'is the same', ->
    assert.equal(Jnoid.more, Jnoid.more)
    assert.equal(Jnoid.noMore, Jnoid.noMore)

  it 'is different', ->
    assert.notEqual(Jnoid.more, Jnoid.noMore)

describe 'fromArray', ->
  it 'works', (done)->
    expectEvents [1, 2, 3],
      Jnoid.fromList([1, 2, 3]),
      done

describe 'unit', ->
  it 'sends a single event', (done)->
    expectEvents [1],
      Jnoid.unit(1),
      done

  it 'does not send anything with no arguments', (done)->
    expectEvents [],
      Jnoid.unit(),
      done

describe 'sequentially', ->
  it 'sends all events', (done)->
    expectEvents [1, 2, 3],
      Jnoid.sequentially(10, [1, 2, 3]),
      done

describe 'later', ->
  it 'sends one event', (done)->
    expectEvents [1],
      Jnoid.later(10, 1),
      done

describe 'flatMap', ->
  it 'combines spawned streams (trivial case)', (done)->
    stream = Jnoid.fromList([1, 2, 3])
    expectEvents [1, 2, 3],
      stream.flatMap((x)-> Jnoid.unit(x)),
      done

  it 'can be aliased as bind', (done)->
    stream = Jnoid.fromList([1, 2, 3])
    expectEvents [1, 2, 3],
      stream.bind((x)-> Jnoid.unit(x)),
      done

describe 'map', ->
  it 'transforms values', (done)->
    stream = Jnoid.fromList([1, 2, 3])
    expectEvents [2, 4, 6],
      stream.map((x)-> x * 2),
      done

describe 'merge', ->
  it 'merges lots of streams', (done)->
    first = Jnoid.fromList([1, 2, 3])
    second = Jnoid.fromList([10, 20, 30])
    third = Jnoid.fromList([100, 200, 300])
    expectEvents [1, 2, 3, 10, 20, 30, 100, 200, 300],
      first.merge(second, third),
      done

describe 'delay', ->
  it 'sends all events after a delay', (done)->
    first = Jnoid.fromList([1, 2, 3]).delay(10)
    second = Jnoid.fromList([10, 20, 30])
    expectEvents [10, 20, 30, 1, 2, 3],
      first.merge(second),
      done

describe 'zip', ->
  it 'zips streams', (done)->
    first = Jnoid.sequentially(10, [1, 2])
    second = Jnoid.sequentially(15, [100, 200])
    expectEvents [[1, 100], [2, 100], [2, 200]],
      first.zip(second),
      done

describe 'zipWith', ->
  it 'zips with function', (done)->
    first = Jnoid.sequentially(10, [1, 2])
    second = Jnoid.sequentially(15, [100, 200])
    expectEvents [101, 102, 202],
      first.zipWith(second, (x, y) -> x + y),
      done

describe 'and', ->
  it 'executes boolean "and" between streams', (done)->
    first = Jnoid.sequentially(10, [false, true])
    second = Jnoid.sequentially(15, [false, true])
    expectEvents [false, false, true],
      first.and(second),
      done

describe 'or', ->
  it 'executes boolean "or" between streams', (done)->
    first = Jnoid.sequentially(10, [false, true])
    second = Jnoid.sequentially(15, [false, true])
    expectEvents [false, true, true],
      first.or(second),
      done

describe 'not', ->
  it 'executes boolean "not" on stream', (done)->
    stream = Jnoid.sequentially(10, [false, true, false])
    expectEvents [true, false, true],
      stream.not(),
      done

describe 'filter', ->
  it 'filters stream', (done)->
    stream = Jnoid.sequentially(10, [10, 100, 20])
    expectEvents [10, 20],
      stream.filter((x)-> x < 50),
      done

expectEvents = (expectedEvents, stream, done)->
  events = []
  stream.onValue (event) ->
    if event.isEnd()
      assert.deepEqual(events, expectedEvents)
      done()
    else
      events.push(event.value)
