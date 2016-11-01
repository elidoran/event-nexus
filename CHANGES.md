
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
