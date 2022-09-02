# Curlod

Lock your Neovim cursor down in a specified region of lines.

This will keep the cursor in the region starting at line 20, and ending at the
first line that starts with `END`:

```
:CurlodEnable 20 /^END/
```

Arguments are optional, and can be line numbers, or [Lua patterns](https://www.lua.org/pil/20.2.html) passed to [`string.match`](https://www.lua.org/pil/20.1.html).

The effect is limited to the active Neovim window.

Free your cursor with `:CurlodDisable`.

## Installation
Using [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'walterl/curlod'
```

## TODO
- [ ] Limit searches to Curlod region
- [ ] Highlight lines outside of Curlod region

## License
[MIT](./LICENSE.md)
