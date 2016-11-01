assert = require 'assert'

buildNexus = require '../../lib'

fn0 = ->
fn1 = ->
fn2 = ->
fn3 = ->

describe 'test nexus', ->

  nexus = null

  beforeEach 'build a new nexus', -> nexus = buildNexus()

  describe 'creation', ->

    it 'should be a builder function', ->

      assert.equal typeof buildNexus, 'function'

    it 'should be buildable', -> assert buildNexus()

    it 'should export the class', -> assert buildNexus.Nexus


  describe 'on() creates event chain', ->

    it 'with single listener', ->

      nexus.on 'test', fn1
      assert.strictEqual nexus?.chains?.test?.array?[0], fn1

    it 'with multiple listeners', ->

      nexus.on 'test', fn1, fn2, fn3

      assert.strictEqual nexus?.chains?.test?.array?[0], fn1
      assert.strictEqual nexus?.chains?.test?.array?[1], fn2
      assert.strictEqual nexus?.chains?.test?.array?[2], fn3

    it 'with array of listeners', ->

      nexus.on 'test', [ fn1, fn2, fn3 ]

      assert.strictEqual nexus?.chains?.test?.array?[0], fn1
      assert.strictEqual nexus?.chains?.test?.array?[1], fn2
      assert.strictEqual nexus?.chains?.test?.array?[2], fn3


  describe 'once() creates event chain and queues removal', ->

    it 'with single listener ', ->

      nexus.once 'test', fn1

      assert.strictEqual nexus?.chains?.test?.array?[0], fn1
      assert.strictEqual nexus?.chains?.test?.__nexusRemovals?[0], fn1

    it 'with multiple listeners', ->

      nexus.once 'test', fn1, fn2, fn3

      assert.strictEqual nexus?.chains?.test?.array?[0], fn1
      assert.strictEqual nexus?.chains?.test?.array?[1], fn2
      assert.strictEqual nexus?.chains?.test?.array?[2], fn3

      assert.strictEqual nexus?.chains?.test.__nexusRemovals?[0], fn1
      assert.strictEqual nexus?.chains?.test.__nexusRemovals?[1], fn2
      assert.strictEqual nexus?.chains?.test.__nexusRemovals?[2], fn3

    it 'with array of listeners', ->

      nexus.once 'test', [ fn1, fn2, fn3 ]

      assert.strictEqual nexus?.chains?.test?.array?[0], fn1
      assert.strictEqual nexus?.chains?.test?.array?[1], fn2
      assert.strictEqual nexus?.chains?.test?.array?[2], fn3

      assert.strictEqual nexus?.chains?.test.__nexusRemovals?[0], fn1
      assert.strictEqual nexus?.chains?.test.__nexusRemovals?[1], fn2
      assert.strictEqual nexus?.chains?.test.__nexusRemovals?[2], fn3


  describe 'off() removes listener', ->

    it 'with one listener', ->

      nexus.on 'test', fn1
      assert.strictEqual nexus?.chains?.test?.array?[0], fn1

      nexus.off 'test', fn1
      assert.strictEqual nexus?.chains?.test?.array?.length, 0

    it 'with one listener in many', ->

      nexus.on 'test', fn1, fn2, fn3
      assert.strictEqual nexus?.chains?.test?.array?.length, 3

      nexus.off 'test', fn2
      assert.strictEqual nexus?.chains?.test?.array?.length, 2


  describe 'clear()', ->

    it 'should do nothing when event doesn\'t have a chain to clear', ->

      nexus.clear 'nada'

    it 'should do nothing when there are no chains to clear', ->

      nexus.clear()

    it 'removes listener for an event', ->

      nexus.on 'test1', fn1
      nexus.on 'test2', fn2
      nexus.on 'test3', fn3

      assert.strictEqual nexus?.chains?.test1?.array?.length, 1
      assert.strictEqual nexus?.chains?.test2?.array?.length, 1
      assert.strictEqual nexus?.chains?.test3?.array?.length, 1

      nexus.clear 'test2'

      assert.strictEqual nexus?.chains?.test2?.array?.length, 0

    it 'removes listeners for an event', ->

      nexus.on 'test1', fn0
      nexus.on 'test2', fn1, fn2
      nexus.on 'test3', fn3

      assert.strictEqual nexus?.chains?.test1?.array?.length, 1
      assert.strictEqual nexus?.chains?.test2?.array?.length, 2
      assert.strictEqual nexus?.chains?.test3?.array?.length, 1

      nexus.clear 'test2'

      assert.strictEqual nexus?.chains?.test1?.array?.length, 1
      assert.strictEqual nexus?.chains?.test2?.array?.length, 0
      assert.strictEqual nexus?.chains?.test3?.array?.length, 1

    it 'removes listeners for an event', ->

      nexus.on 'test1', fn0
      nexus.on 'test2', fn1, fn2
      nexus.on 'test3', fn3

      assert.strictEqual nexus?.chains?.test1?.array?.length, 1
      assert.strictEqual nexus?.chains?.test2?.array?.length, 2
      assert.strictEqual nexus?.chains?.test3?.array?.length, 1

      nexus.clear()

      assert.strictEqual nexus?.chains?.test1?.array?.length, 0
      assert.strictEqual nexus?.chains?.test2?.array?.length, 0
      assert.strictEqual nexus?.chains?.test3?.array?.length, 0


  describe 'emit()', ->

    it 'should do nothing when event doesn\'t have a chain to run', ->

      result = nexus.emit 'nada'

      assert.equal result?.result, true, 'should return success result'
      assert.equal result?.reason, 'no chain for event', 'should explain itself'
      assert.equal result?.event, 'nada', 'should include the event'

    it 'should do nothing when event chain to run is empty', ->

      nexus.on 'empty', fn1
      nexus.off 'empty', fn1

      assert.equal nexus?.chains?.empty.array.length, 0

      result = nexus.emit 'empty'

      assert result?.result

    it 'should call listener via its event chain', ->

      called = false
      callName = null
      callArg = null
      arg = 'some arg'
      hasArg = false
      fn = (control, context) ->
        called = true
        callName = context.eventName
        callArg = context.event

      nexus.on 'test', fn

      assert.equal nexus?.chains?.test.array.length, 1
      assert.strictEqual nexus?.chains?.test.array[0], fn

      result = nexus.emit 'test', arg

      assert result?.result
      assert called, 'should call listener'
      assert.equal callName, 'test', 'event name should match'
      assert.equal callArg, arg, 'arg should match'

    it 'should call listener via its event chain', ->

      eventObject =
        one: 'some arg'
        two: 'another arg'

      called1 = false
      object1 = null

      fna = (control, context) ->
        called1 = true
        object1 = context?.event

      called2 = false
      object2 = null

      fnb = (control, context) ->
        called2 = true
        object2 = context?.event

      nexus.on 'test', fna, fnb

      assert.equal nexus?.chains?.test.array.length, 2

      result = nexus.emit 'test', eventObject

      assert result?.result

      assert called1, 'should call first listener'
      assert.strictEqual object1, eventObject, 'event object should match'

      assert called2, 'should call second listener'
      assert.strictEqual object2, eventObject, 'event object should match'


  describe 'context base', ->

    it 'should use nexus base as prototype of new context', ->

      calledKey = null
      calledEvent = null

      base =
        key: 'value'
        fn : (event) ->
          calledKey = @key
          calledEvent = event

      listener = () ->
        @fn @event
        return

      nexus = buildNexus contextBase:base

      nexus.on 'test', listener

      nexus.emit 'test', 'somearg'

      assert.equal calledEvent, 'somearg'
      assert.equal calledKey, 'value'

    it 'should use chain\'s base as prototype of new context', ->

      calledKey = null
      calledEvent = null
      calledKey2 = null
      calledEvent2 = null

      base =
        key: 'value'
        fn : (event) ->
          calledKey = @key
          calledEvent = event

      notUsedBase =
        key2: 'value'
        fn2 : (event) ->
          calledKey2 = @key
          calledEvent2 = event

      listener = () ->
        @fn @event
        return

      nexus = buildNexus contextBase:notUsedBase

      # create the chain specifically to provide options with `base`
      nexus.chain 'test', true, base:base

      # now add a listener
      nexus.on 'test', listener

      nexus.emit 'test', 'somearg'

      assert.equal calledEvent, 'somearg'
      assert.equal calledKey, 'value'

      assert.equal calledEvent2, undefined, 'shouldnt use the nexus base'
      assert.equal calledKey2, undefined, 'shouldnt use the nexus base'
