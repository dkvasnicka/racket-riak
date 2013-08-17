racket-riak
===========

A basic [Riak](http://basho.com/riak/) client written in [Racket](http://racket-lang.org). I know this has been done before but I wanted something simple that would work with the current version of Riak. And I need to practice Racket :)
Work in progess, refactoring to be done.

Available as a [PLaneT package](http://planet.racket-lang.org/display.ss?package=racket-riak.plt&owner=dkvasnicka).

#### Sanity check

1. `git clone https://github.com/dkvasnicka/racket-riak.git`
2. Open `main.rkt` and setup `host` and `port` (will be externalized in the future of course...)
2. `cd racket-riak`
3. `raco test tests`
