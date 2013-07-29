assert = require('chai').assert
h = require('./test_helpers')
{Stream, Box} = require '../jnoid.coffee.md'

describe 'EventStream', ->
  describe 'basics', ->
    it 'creates simple sequential stream', (done)->
      h.expectValues [1, 2, 3],
        Stream.sequentially(10, [1, 2, 3]),
        done

    it 'can be subscribed twice', (done)->
      i = 0
      donner = -> done() if ++i >= 2
      stream = Stream.sequentially(10, [1, 2, 3])
      h.expectValues [1, 2, 3], stream, donner
      setTimeout((-> h.expectValues([2, 3], stream, donner)), 15)

  describe 'unit', ->
    it 'never creates empty stream', (done)->
      h.expectValues [], Stream.never(), done

    it 'once creates simple stream', (done)->
      h.expectValues [5], Stream.once(5), done

    it 'unit is once', (done)->
      h.expectValues [5], Stream.unit(5), done

  describe 'transformation', ->
    it 'map maps events', (done)->
      h.expectValues [10, 20, 30],
        Stream.sequentially(10, [1, 2, 3]).map((x)-> x*10),
        done

    it 'filter filters events', (done)->
      h.expectValues [1, 3],
        Stream.sequentially(10, [1, 2, 3]).filter((x)-> x % 2 != 0 ),
        done

    it 'flatMap collects all the values from spawned streams', (done)->
      stream = Stream.sequentially(10, [1, 2, 3])
      h.expectValues [10, 100, 20, 200, 30, 300],
        stream.flatMap((x)-> Stream.sequentially(8, [10*x, 100*x])),
        done

  describe 'combination', ->
    it 'merge merges streams', (done)->
      first = Stream.sequentially(5, [1, 2])
      second = Stream.sequentially(15, [10, 20])
      h.expectValues [1, 2, 10, 20],
        first.merge(second),
        done

describe "Box", ->
  it "streams current value", (done)->
    i = 0
    donner = -> done() if ++i >= 2
    box = Box.sequentially(10, [1, 2, 3])
    h.expectValues [1, 2, 3], box, donner
    setTimeout((-> h.expectValues([1, 2, 3], box, donner)), 15)

  it 'flatMap collects only the values from last spawned streams', (done)->
    stream = Box.sequentially(10, [1, 2, 3])
    h.expectValues [10, 20, 30, 300],
      stream.flatMap((x)-> Box.sequentially(8, [10*x, 100*x])),
      done

  it "map2 zips two boxes", (done)->
    first = Box.sequentially(10, [1, 2])
    second = Box.sequentially(15, [100, 200, 300])
    h.expectValues [102, 202, 302],
      first.map2(second, (x, y) -> x + y),
      done
