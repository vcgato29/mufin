export mufin = {}

mufin =

  change_map: (map) =>
    changeMap(map)
    @change_map

  npc_reply: (reply) =>
    npc.reply(reply)
    @npc_reply

  door: (cell) =>
    use(cell, -1)
    @door

  map_position: =>
    funcmay.table\map(funcmay.string\split(currentMap(), ','), tonumber)

  on_map: (map) =>
    onMap(funcmay.table\join(map, ','))

  map_id: =>
    tonumber(currentMapId!)

  path: (...) =>

    direction = (start, stop) ->
      (start == stop) and 0 or (start < stop) and 1 or -1

    direction_desc = {
      { [-1]: 'left',   [0]: nil, [1]: 'right'  }
      { [-1]: 'top',    [0]: nil, [1]: 'bottom' }
    }

    -- Path should look like:
    -- {
    --   i
    --   {x,y}
    --   {
    --     {x,y}
    --     {x,y}
    --     …
    --   }
    -- }
    --
    -- We are looking for each entry.
    -- Each entry is a token.
    -- Token could be:
    -- - identifier
    -- - position
    -- - list of positions (auto-path)
    -- Getting a list of positions means we want auto-path, hence setting for each map:
    -- - history (list of previous maps)
    -- - change_map
    -- In the end, we return a plain list of paths.
    funcmay.table\inject { ... }, {}, (value, token) ->
      funcmay.table\concat value, switch type token
        when 'number'
          { { map: token } }
        when 'table'
          switch type funcmay.table\head token
            when 'number'
              { { map: token } }
            when 'table'
              funcmay.table\inject token, {}, (maps, map) ->
                funcmay.table\concat maps, if #maps == 0
                  { { map: map } }
                else
                  start, destination = (funcmay.table\last maps).map, map
                  maps[#maps] = nil -- Ugly but currently I’m too lazy to fix duplicates without in-place
                  funcmay.table\inject (funcmay.object\range start[1], destination[1]), {}, (memo, x) ->
                    funcmay.table\concat memo, funcmay.table\map (funcmay.object\range start[2], destination[2]), (y) ->
                      {
                        history: funcmay.table\concat (funcmay.table\map maps, (map) -> (funcmay.table\join map.map, ',')), (funcmay.table\map memo, (map) -> (funcmay.table\join map.map, ','))
                        map: { x, y }
                        change_map: funcmay.table\compact { direction_desc[1][direction x, destination[1]], direction_desc[2][direction y, destination[2]] }
                      }
            else
              { }

  manage: (func, hist) =>

    return {} unless func

    history_entry = { id: @map_id!, position: @map_position! }

    -- Append to history if map changed
    if #hist == 0 or not funcmay.object\compare history_entry, hist[#hist]
      hist[#hist+1] = history_entry

    -- Table should look like:
    -- {
    --   path:
    --     i
    --     {x,y}
    --     {
    --       {x,y}
    --       {x,y}
    --       …
    --     }
    --   function: (map) ->
    --     …
    --     map
    -- }
    table = func mufin

    -- Path handler
    path = @path table.path

    -- Select maps matching current position
    maps = funcmay.table\filter path, ((map) -> map.map == @map_id! or funcmay.object\compare map.map, @map_position!)

    -- Retrieve 1 map!
    -- <foo> does not support duplicates
    -- Select best matching map by comparing usable history
    -- Usable history is:
    -- - session history shorten to the history of a map
    -- - history of a map shorten to session history
    -- So we get 2 lists of history with same length,
    -- we just have to compare the 2 lists, if they are same we have our map!
    map = if #maps == 1
      maps[1]
    else
      funcmay.table\select maps, (map) ->
        return false unless map.history
        usable_hist = (funcmay.table\last hist, #map.history)
        usable_map_history = (funcmay.table\last map.history, #hist)
        #(funcmay.table\filter usable_hist, (hist) ->
          #(funcmay.table\filter usable_map_history, (map) ->
            not ((map.map == hist.id) or (funcmay.object\compare map.map, hist.position))) > 0) == 0

    -- in case of select failure
    if map == nil
      map = maps[1]

    -- User can configure map
    status, value = pcall table.function, map

    map = status and value or map

    -- Convert map entry to <foo> map format (string)
    map.map =
    switch type map.map
      when 'number'
        tostring map.map
      when 'table'
        funcmay.table\join map.map, ','
    map.changeMap = map.change_map and (funcmay.table\join map.change_map, '|') or ''

    -- Return single map to <foo>!
    { map }

  state:
    history:
      move:   {}
      bank:   {}
      phenix: {}

export move = ->
  mufin\manage mufin.move, mufin.state.history.move

export bank = ->
  mufin\manage mufin.bank, mufin.state.history.bank

export phenix = ->
  mufin\manage mufin.phenix, mufin.state.history.phenix
