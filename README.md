# Curlod

Lock your Neovim cursor down in a specified region of lines.

The effect is limited to the active Neovim window, making this useful for
having a separate, restricted view of a long document, while working on one
part, while often referring to another part.

## Usage
This will keep the cursor in the region starting at line 20, and ending at the
first line that starts with `END`:

```vim
:CurlodEnable 20 /^END/
```

Arguments are optional, and can be line numbers, or [Lua patterns](https://www.lua.org/pil/20.2.html) passed to
[`string.match`](https://www.lua.org/pil/20.1.html), and wrapped in `/`s.

Alternatively, make a visual selection and run `CurlodEnableRange` on it:

```vim
:'<,'>CurlodEnableRange
```

Free your cursor again:

```vim
:CurlodDisable
```

## Installation
Using [vim-plug](https://github.com/junegunn/vim-plug):

```viml
Plug 'walterl/curlod'
```

## Development

Curlod was developed with [Conjure](https://github.com/Olical/conjure) and [Aniseed](https://github.com/Olical/aniseed).

### Change log level

```vim
:CurlodLogLevel debug
```

Or `info` (default) or `error`.

## Known limitations
### Out-of-region changes are still possible
There are many ways to change text in Vim without moving the cursor. Curlod
won't take on the Herculean task of trying to prevent that from happening
outside of the Curlod region.

This is considered out of scope for Curlod, since the primary motivation is to
keep the cursor bound to the specified region, in order to limit a window's
view on a buffer.

Attempts to prevent out-of-region edits are likely to degrade overall user
experience with an explosion in corner cases caused by combinations of hard to
predict effects.

## License
[MIT](./LICENSE.md)
