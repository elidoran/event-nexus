# flatten arrays fast
flatten = require '@flatten/array'

# this module is used to build each event chain
buildChain = require 'chain-builder'

# this is used to order the array of functions used by an event chain
order      = require 'ordering'

# mark a chain as *not* ordered when an add/remove occurs
markChanged = (event) -> event.chain.__isOrdered = false

# order the array before a chain run executes
ensureOrdered = (event) ->
  unless event.chain.__isOrdered is true
    order event.chain.array
    event.chain.__isOrdered = true

# remove any listeners registered for removal ('once' listeners)
removeListeners = (error, results) ->
  if error? then return

  chain = results.chain
  removals = chain.__nexusRemovals

  if removals?.length > 0
    # each function in `removals` should be removed from the chain
    # *and*, removed from the removals queue, so, get via pop()
    chain.remove removals.pop() until removals.length is 0

  return


class Nexus
  constructor: (options) ->
    # hold event chains
    @chains = {}

    # holds listeners which should be removed after an emit.
    @_remove = {}

    # allow customizing the context passed to a chain run
    if options?.contextBase?
      @_contextBase = options.contextBase


  # simple existence check returns a boolean
  hasChain: (event) -> @chains?[event]?


  # gets the actual chain.
  # by default it will create it when it doesn't exist.
  chain: (event, create = true, options) ->

    chain = @chains?[event]
    unless chain? or create is false
      chain = @chains?[event] = @_makeChain event, options
    return chain


  on: (event) ->

    # optimization friendly way to convert `arguments`
    listeners = new Array arguments.length - 1
    listeners[i - 1] = arguments[i] for i in [1 ... arguments.length]
    flatten listeners

    # ensure we have a chain to add to
    chain = @chain event, true

    # gather into a single add without duplicates
    add = []
    for listener in listeners
      unless listener in chain.array then add[add.length] = listener

    # now add them all
    result = chain.add.apply chain, add

    if result?.error? then return result

    # return for chaining...
    return this


  once: (event) ->

    # optimization friendly way to convert `arguments`
    listeners = new Array arguments.length - 1
    listeners[i - 1] = arguments[i] for i in [1 ... arguments.length]
    flatten listeners

    # ensure we have a chain to add to
    chain = @chain event, true

    # # store the listeners for removal
    #
    # either: 1. add it to the existing remove queue
    if chain.__nexusRemovals?
      chain.__nexusRemovals.push.apply chain.__nexusRemovals, listeners

    # or, 2. create the queue using this array
    else chain.__nexusRemovals = listeners

    # add their listeners
    @on.apply this, [event, listeners]

    # return for chaining...
    return this


  # remove listener from event chain
  off: (event, listener) ->

    chain = @chains[event]

    if chain? then chain.remove listener

    # return for chaining...
    return this


  # remove all listeners (optionally for a specified event)
  clear: (event) ->

    # for a specific event, try to clear its chain. it may not exist
    if event? then @chains?[event]?.clear?()

    else chain.clear() for event, chain of @chains

    # return for chaining...
    return this


  emit: (eventName, eventObject) ->

    # if there's a chain for this event
    if @chains[eventName]?

      # add the event object to the context via `props` in case the `base`
      # is provided by the nexus or a custom base given when the chain was
      # created
      @chains[eventName].run
        # context: no context cuz we want base+props to be used
        props:
          eventName: # let's provide the event name as well.
            value       : eventName
            writable    : false
            configurable: false
            enumerable  : true
          event:
            value       : eventObject
            writable    : true
            configurable: true
            enumerable  : true

    # if there's no chain for the event, return a result informing them
    else result:true, reason:'no chain for event', event:eventName


  # this is used by `_makeChain`.
  # having this allows overriding this specific function to change how the
  # nexus builds a chain. the `buildChain` is the `chain-bulider` module's
  # exported builder function. it's possible someone may want to replace
  # that with their own chain building process...
  _buildChain: -> buildChain.apply this, arguments


  # it's also possible they may want to override this functionality, so, it's
  # pulled from `on()` to be overridable.
  # and, then, I added the `chain()` function which also uses this.
  _makeChain: (event, options) ->

    # if this nexus has a context base and the options don't specify a base,
    # then specify the nexus' base.
    if @_contextBase? and not options?.base?
      if options? then options.base = @_contextBase # add into existing
      else options = base: @_contextBase            # make the options
    # otherwise, allow things to proceed with options as they are

    # use the local function which uses `buildChain` by default.
    chain = @_buildChain options

    # watch this chain for changes. when changed, set a marker

    # add listner to both add/remove events
    chain.on 'add', markChanged
    chain.on 'remove', markChanged

    # add a start listener which does ordering if __isOrdered is false.
    # this way, we aren't ordering over and over again as things are
    # added and removed. instead, we order it before executing the chain
    # Note: this is possible because chain-builder emits 'start' before
    # beginning to execute the chain.
    chain.on 'start', ensureOrdered

    # when a chain execution is done, remove any listeners queued for removal
    chain.on 'done', removeListeners



# export a function which creates a Strung instance
module.exports = (options) -> new Nexus options

# export the class as a sub property on the function
module.exports.Nexus = Nexus
