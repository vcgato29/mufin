Mufin (⚠) WIP – Non-functional
=====

Mufin is a `foo` framework for the game `bar`.

Features
--------

- MoonScript instead of Lua
- Provide a set functional primitives ([FuncMay][])
- Automatic path `path: { { <start>, …, <end> } }`
- Collision handler (you will never write trash path again)

### Examples

#### With vanilla `foo`

``` lua
function move()
  return {
    { map = '-2,0', gather = true, changeMap = 'right'  },
    { map = '-1,0', gather = true, changeMap = 'right'  },
    { map =  '0,0', gather = true, custom = (function() changeMap(MARKER and 'right' or 'down') end) },
    { map =  '0,1', gather = true, custom = (function() changeMap(MARKER and 'up' or 'right') end) },
    { map =  '1,1', gather = true, changeMap = 'left', custom = (function() MARKER = true end) },
    { map =  '1,0', gather = true, changeMap = 'right' },
    { map =  '2,0', gather = true, changeMap = 'right' },
    { map =  '3,0', gather = true, changeMap = 'right' },
    { map =  '4,0', gather = true, changeMap = 'right' },
    { map =  '5,0', gather = true },
  }
end
```

#### With Mufin

``` moon
mufin.move = =>
  {
    path:
      {
        {-2,0}
        { 0,1}
        { 1,1}
        { 0,1}
        { 0,0}
        { 5,0}
      }
    function: (map) ->
      map.gather = true
      map
  }
```

`path` accepts a list of tokens: `path: { <token>, …, <token-n> }`

Token can be:
- a position, non-linear path: `path: { <pos>, …, <pos-n> }`
- a list of positions, linerar (automatic) path: `path: { { <start>, …, <end> } }`

Dependencies
------------

* [MoonScript][]
  - [FuncMay][]
* [Ruby][]
  - [Thor][]
* [Busted][] (optional, for testing)
* [Guard::Listener][] (optional, for developing)

Installation
------------

 1. Make sure you have the dependencies installed
 2. Clone the repository
 3. Place [mufin](bin/mufin) on your `$PATH` with a symbolic link (your home `bin/` is a good choice if it is on your path)

Testing
-------

To test, just type `make test` in the [root](.) directory.

Usage
-----

    mufin compile

    mufin compile < input.moon > output.lua

    mufin compile input.moon

    mufin compile input.moon --output output.lua

    mufin compile input/

    mufin compile input/ --output output/

Methods
-------

* [mufin](lib/mufin.moon)
  + change_map map
  + npc_reply reply
  + door cell
  + map_position
  + on_map map
  + map_id


[MoonScript]: http://moonscript.org
[FuncMay]: https://github.com/alexherbo2/funcmay.moon
[Ruby]: http://ruby-lang.org
[Thor]: http://whatisthor.com
[Busted]: http://olivinelabs.com/busted
[Guard]: http://guardgem.org
[Guard::Listener]: https://github.com/alexherbo2/guard-listener
