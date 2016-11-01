
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
    # also add a `nexus` property with `this` in it
    if options?.contextBase?
      options.contextBase.nexus = this
      @_contextBase = options.contextBase

    # otherwise create our own with the `nexus` property
    else @_contextBase = nexus:this


  # simple existence check returns a boolean
  hasChain: (event) -> @chains?[event]?

  # gets the actual chain.
  # by default it will create it when it doesn't exist.
  chain: (event, create = true, options) ->
    chain = @chains?[event]
    unless chain? or create is false
      chain = @chains?[event] = @_makeChain event, options
    return chain

  on: (event, listeners...) ->
    # unwrap array
    if Array.isArray listeners[0] then listeners = listeners[0]

    # ensure we have a chain to add to
    chain = @chain event, true

    # gather into a single add without duplicates
    add = []
    for listener in listeners
      unless listener in chain.array then add.push listener

    # now add them all
    result = chain.add add...

    if result?.error? then return result

    # return for chaining...
    return this

  once: (event, listeners...) ->

    # unwrap array
    if Array.isArray listeners[0] then listeners = listeners[0]

    # ensure we have a chain to add to
    chain = @chain event, true

    # # store the listeners for removal
    #
    # either: 1. add it to the existing remove queue
    if chain.__nexusRemovals?
      chain.__nexusRemovals.splice removals.length, 0, listeners...

    # or, 2. create the queue using this array
    else chain.__nexusRemovals = listeners

    # add their listeners
    @on event, listeners...

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

    else chain.clear() for event,chain of @chains

    # return for chaining...
    return this

  emit: (event, args...) ->

    # if there's a chain for this event
    if @chains[event]?

      # TODO:
      #   provide the `base` to the chain.run() as an option
      #   provide the event and args as a property description to chain.run()

      # create a new context object based on the stored context 'base'
      context = Object.create @_contextBase

      # add the current event to emit and its args
      context.event = name: event, args: args

      # then call the chain with the context
      @chains[event].run context:context

    # if there's no chain for the event, return a result informing them
    else result:true, reason:'no chain for event', event:event


  # this is used by `_makeChain`.
  # having this allows overriding this specific function to change how the
  # nexus builds a chain. the `buildChain` is the `chain-bulider` module's
  # exported builder function. it's possible someone may want to replace
  # that with their own chain building process...
  _buildChain: (args...) -> buildChain args...

  # it's also possible they may want to override this functionality, so, it's
  # pulled from `on()` to be overridable.
  # and, then, I added the `chain()` function which also uses this.
  _makeChain: (event, options) ->

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
