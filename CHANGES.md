0.3.0 - Released 2017/04/30

1. drop Node 0.12 and add 7
2. cache `node_modules` in Travis CI
3. submit coverage to coveralls via Travis CI
4. ignore usual directories for npm publish
5. add 2017 to LICENSE
6. add linting with coffeelint
7. add code coverage with istanbul and coffee-coverage
8. fixed repo URL in package.json
9. update deps
10. add coverage badge to README
11. link to license from README
12. add link to eventa in README


0.2.2 - Released 2016/11/01

1. update chain-builder dep

0.2.1 - Released 2016/11/01

1. updated README to reflect changes in 0.2.0

0.2.0 - Released 2016/11/01

1. generified the removal listener by moving removals onto chains and using chain ref in event
2. generified the ordering listeners by using chain ref in event
3. removed enforcing a default base
4. removed adding a `nexus` property to base
5. accept options to `chain()` so users can provide options to the chain being built
6. moved context `base` option handling to when chains are created. Either use the one provided as an option or the general one the nexus has, or none
7. changed `emit()` to accept all args (params 2+) as a single "event object" (param 2)
8. changed `emit()` to *not* do `Object.create()` and instead defer to the chain doing that (see items 5 and 6 above)
9. altered `chain.run()` calls to provide event name and object as `props` which enhance the context and allow all the `base` stuff to be separate


0.1.0 - Released 2016/10/29

1. initial working version with tests
