# Event Nexus
[![Build Status](https://travis-ci.org/elidoran/event-nexus.svg?branch=master)](https://travis-ci.org/elidoran/event-nexus)
[![Dependency Status](https://gemnasium.com/elidoran/event-nexus.png)](https://gemnasium.com/elidoran/event-nexus)
[![npm version](https://badge.fury.io/js/event-nexus.svg)](http://badge.fury.io/js/event-nexus)
[![Coverage Status](https://coveralls.io/repos/github/elidoran/event-nexus/badge.svg?branch=master)](https://coveralls.io/github/elidoran/event-nexus?branch=master)

A central object for event listening and emitting with advanced execution controls.

See [chain-builder](https://www.npmjs.com/package/chain-builder) for how event listeners are executed.

See [ordering](https://www.npmjs.com/package/ordering) for how event listeners are ordered within an event chain.

See [needier](https://www.npmjs.com/package/needier) for `ordering` sorts based on dependencies.

See [eventa](https://www.npmjs.com/package/eventa) for another event system.

## Install

```sh
npm install event-nexus --save
```


## Usage

```javascript
// get the module's builder function
var buildNexus = require('event-nexus')

// the only build option is `contextBase`.
// it can have constants as well as functions
// anything in it will be available in the execution context
// given to each event listener function
var buildOptions = { contextBase: {some: 'stuff'} }

// build the nexus with the options
var nexus = buildNexus(buildOptions);

// add an event listener
nexus.on('some event', function() {
  // this will print:
  //   context base: stuff
  console.log('context base:', this.some);
});

// to use a custom context base for an individual event chain,
// instead of all event chains, create the event chain manually
// and specify the options:
// (true means create if it isn't created)
nexus.chain('new event name', true, {
  base: { the: 'custom base' }
});

// you can do a `once` listener as well.
// or, if you want it to execute 2 or more times depending on something:
nexus.on('some event', function(control) {
  // if we have run enough times we're no longer needed...
  if (this.event.something) {
    control.remove();
    // or add a reason for info purposes:
    control.remove('I am no longer needed');
  }
});

// both `on` and `once` allow specifying multiple listeners at once.
// they accept them as a list of params, or, as a single param array
nexus.on('some event', listener1, listener2, listener3);
nexus.on('some event', listeners);

// remove a listener:
nexus.off('event name')

// remove all event listeners for a specific event:
nexus.clear('event name');
// OR: remove all event listeners for *all* events:
nexus.clear();

// finally, emit event with a name and, optionally, an event object
var eventObject = { some: 'thing' };
nexus.emit('eventing', eventObject);
// a listener for the above example:
nexus.on('eventing', function() {
  // this.eventName == 'eventing'
  // this.event == eventObject
  // the below prints:
  //   eventing some thing
  console.log(this.eventName, 'some', this.event.some);
});
```

## API

Nexus functions:

1. **on** - add listener(s)
2. **once** - same as `on()` except they run only once
3. **off** - remove a listener
4. **clear** - remove all listeners for all events, or, for a specific event
5. **emit** - usual emitter accepts event name and an event object

## TODO

1. accept a callback in `emit()` which is added as a one-time 'done' event listener on the chain.

## [MIT License](LICENSE)
