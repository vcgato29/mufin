require 'funcmay'
require 'mufin'

describe 'mufin', ->

  describe 'path', ->

    it 'path', ->
      input = {
        {
          { -2, 0 }, {  0, 0 }, { 0, 2 }
        }
      }
      output = {
        { map: { -2, 0 }, change_map: { 'right'  }, history: {                                     } }
        { map: { -1, 0 }, change_map: { 'right'  }, history: { '-2,0'                              } }
        { map: {  0, 0 }, change_map: { 'bottom' }, history: { '-2,0', '-1,0'                      } }
        { map: {  0, 1 }, change_map: { 'bottom' }, history: { '-2,0', '-1,0', '0,0'               } }
        { map: {  0, 2 }, change_map: {          }, history: { '-2,0', '-1,0', '0,0', '0,1'        } }
      }
      assert.are.same (mufin\path table.unpack input), output
