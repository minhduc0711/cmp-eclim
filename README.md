# cmp-eclim
[nvim-cmp](https://github.com/hrsh7th/nvim-cmp) source for [Eclim](http://eclim.org/).

## Config
In your `init.lua`:
```lua
local cmp = require'cmp'
require'cmp'.setup {
  sources = {
    {
      name = 'eclim',
      keyword_length = 3, -- only trigger completion after 3 characters,
                          -- otherwise there'll be many irrelevant items
    },
    ...
  },
  ...
}
```
