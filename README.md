# Curlod

Lock your Neovim cursor down in a specified region of lines.

This is useful for having a separate, restricted view of a long document, while
working on one part, but needing to often refer to another.

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

## Known limitations
### Out-of-region changes are still possible
There are many ways to change text in Vim without moving the cursor.

This is considered out of scope for Curlod, since the primary motivation is to
keep the cursor bound in order to limit a window's view on a buffer.

Attempts to prevent out-of-region edits are likely to degrade user experience
with an explosion in corner cases caused by combinations of hard to predict
effects.

## License
[MIT](./LICENSE.md)
