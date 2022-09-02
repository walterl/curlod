local _2afile_2a = "fnl/curlod/lockdown.fnl"
local _2amodule_name_2a = "curlod.lockdown"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("curlod.aniseed.autoload")).autoload
local a, bridge, log, nvim = autoload("curlod.aniseed.core"), autoload("curlod.bridge"), autoload("curlod.log"), autoload("curlod.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["bridge"] = bridge
_2amodule_locals_2a["log"] = log
_2amodule_locals_2a["nvim"] = nvim
local function last_line_num()
  return nvim.buf_line_count(0)
end
_2amodule_locals_2a["last-line-num"] = last_line_num
local function active_in_buf_3f()
  return (true == nvim.w["curlod-active"])
end
_2amodule_locals_2a["active-in-buf?"] = active_in_buf_3f
local function pattern_3f(x)
  return (a["string?"](x) and vim.startswith(x, "/") and vim.endswith(x, "/"))
end
_2amodule_locals_2a["pattern?"] = pattern_3f
local function lua_pattern(s)
  if pattern_3f(s) then
    return s:sub(2, a.dec(s:len()))
  else
    return nil
  end
end
_2amodule_locals_2a["lua-pattern"] = lua_pattern
local function lookup_first_line(pat)
  local i = 0
  local function _2_(line)
    i = a.inc(i)
    if line:match(lua_pattern(pat)) then
      return i
    else
      return nil
    end
  end
  return a.some(_2_, nvim.buf_get_lines(0, 0, -1, false))
end
_2amodule_locals_2a["lookup-first-line"] = lookup_first_line
local function resolve_line_num(n)
  if ("number" == type(n)) then
    return n
  elseif pattern_3f(n) then
    return lookup_first_line(n)
  else
    return tonumber(n)
  end
end
_2amodule_locals_2a["resolve-line-num"] = resolve_line_num
local function on_cursor_move()
  if active_in_buf_3f() then
    local _let_5_ = nvim.w["curlod-region"]
    local start = _let_5_[1]
    local _end = _let_5_[2]
    local _let_6_ = nvim.win_get_cursor(0)
    local cur_line = _let_6_[1]
    local cur_col = _let_6_[2]
    log.debug_(">>>", start, _end, cur_line, cur_col)
    if (cur_line < start) then
      log.info_("Prevented cursor from leaving Curlod region")
      return nvim.win_set_cursor(0, {start, cur_col})
    elseif (cur_line > _end) then
      log.info_("Prevented cursor from leaving Curlod region")
      return nvim.win_set_cursor(0, {_end, cur_col})
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_2a["on-cursor-move"] = on_cursor_move
local function region_start(start)
  local start0 = resolve_line_num(start)
  if a["nil?"](start0) then
    log.error_("Couldn't determine region start line. Using line 1.")
    return 1
  else
    return start0
  end
end
_2amodule_locals_2a["region-start"] = region_start
local function region_end(_end)
  local _end0 = resolve_line_num(_end)
  if a["nil?"](_end0) then
    log.error_("Couldn't determine region end line. Using last line.")
    return last_line_num()
  else
    return _end0
  end
end
_2amodule_locals_2a["region-end"] = region_end
local function smallest_first(a0, b)
  if (b < a0) then
    return {b, a0}
  else
    return {a0, b}
  end
end
_2amodule_locals_2a["smallest-first"] = smallest_first
local function on_text_change()
  if active_in_buf_3f() then
    local _let_12_ = nvim.w["curlod-input-region"]
    local old_start = _let_12_[1]
    local old_end = _let_12_[2]
    local _let_13_ = smallest_first(region_start(old_start), region_end(old_end))
    local start = _let_13_[1]
    local _end = _let_13_[2]
    if ((old_start ~= start) or (old_end ~= _end)) then
      log.debug_("New region:", {start, _end})
      nvim.w["curlod-region"] = {start, _end}
      return nil
    else
      return nil
    end
  else
    return nil
  end
end
_2amodule_2a["on-text-change"] = on_text_change
local function enable(start, _end)
  nvim.w["curlod-active"] = true
  nvim.w["curlod-input-region"] = {start, _end}
  on_text_change()
  do
    local _let_16_ = nvim.w["curlod-region"]
    local start0 = _let_16_[1]
    local _end0 = _let_16_[2]
    log.info_("Locked cursor down between lines", start0, "and", _end0)
  end
  nvim.ex.augroup("curlod")
  nvim.ex.autocmd_()
  nvim.ex.autocmd("CursorMoved,CursorMovedI", "<buffer>", bridge["viml->lua"]("curlod.lockdown", "on-cursor-move"))
  nvim.ex.autocmd("TextChanged,TextChangedI,TextChangedP", "<buffer>", bridge["viml->lua"]("curlod.lockdown", "on-text-change"))
  nvim.ex.augroup("END")
  return on_cursor_move()
end
_2amodule_2a["enable"] = enable
local function disable()
  nvim.w["curlod-active"] = false
  nvim.w["curlod-region"] = nil
  return nvim.ex.autocmd_("curlod")
end
_2amodule_2a["disable"] = disable
--[[ (pattern? nil) (resolve-line-num nil) (enable 3 20) (enable 15 "/stop/") (enable "/on%-cursor%-move/" 80) ]]--
return _2amodule_2a