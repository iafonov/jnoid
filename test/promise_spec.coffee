assert = require('chai').assert
h = require('./test_helpers')
Jnoid = require '../src/jnoid.coffee.md'

success = undefined
fail = undefined
promise = {
  then: (s, f) ->
    success = s
    fail = f
}

nop = ->

describe "Jnoid.fromPromise", ->
  it "produces value and ends on success", (done)->
    h.expectValues ["A"],
      Jnoid.fromPromise(promise),
      done
    success("A")

  it "ends on error", (done)->
    h.expectErrors ["E"],
      Jnoid.fromPromise(promise),
      done
    fail("E")

  it "unsubscribes", ->
    events = []
    unsub = Jnoid.fromPromise(promise).subscribe((e) => events.push(e))
    unsub()
    success("A")
    assert.deepEqual(events, [])

  it "aborts on unsubscribe", ->
    isAborted = false
    promise.abort = ->
      isAborted = true
    unsub = Jnoid.fromPromise(promise).subscribe(nop)
    unsub()
    delete promise.abort
    assert.equal(isAborted, true)
