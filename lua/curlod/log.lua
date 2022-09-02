local _2afile_2a = "fnl/curlod/log.fnl"
local _2amodule_name_2a = "curlod.log"
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
local a, nvim = autoload("curlod.aniseed.core"), autoload("curlod.aniseed.nvim")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["nvim"] = nvim
_G["current-level"] = "info"
local function println_debug(...)
  return a.println("[DEBUG]", ...)
end
_2amodule_locals_2a["println-debug"] = println_debug
local levels = {{"debug", println_debug}, {"info", a.println}, {"error", nvim.err_writeln}}
_2amodule_2a["levels"] = levels
local function bool(x)
  return not not x
end
_2amodule_locals_2a["bool"] = bool
local function valid_level_3f(level)
  local function _3_(_1_)
    local _arg_2_ = _1_
    local l = _arg_2_[1]
    local _ = _arg_2_[2]
    return (l == level)
  end
  return bool(a.some(_3_, levels))
end
_2amodule_locals_2a["valid-level?"] = valid_level_3f
local function level_idx(level)
  local idx = nil
  local i = 1
  while ((i <= a.count(levels)) and a["nil?"](idx)) do
    if (level == a.first(a.get(levels, i))) then
      idx = i
    else
    end
    i = a.inc(i)
  end
  return idx
end
_2amodule_locals_2a["level-idx"] = level_idx
local function log(level, ...)
  local idx = level_idx(level)
  if (idx <= level_idx(_G["current-level"])) then
    local f = a.second(a.get(levels, idx))
    return f(...)
  else
    return nil
  end
end
_2amodule_locals_2a["log"] = log
local function debug_(...)
  return log("debug", ...)
end
_2amodule_2a["debug_"] = debug_
local function info_(...)
  return log("info", ...)
end
_2amodule_2a["info_"] = info_
local function error_(...)
  return log("error", ...)
end
_2amodule_2a["error_"] = error_
local function set_level(level)
  if valid_level_3f(level) then
    _G["current-level"] = level
    return nil
  else
    return log("error", "Invalid log level: ", level)
  end
end
_2amodule_2a["set-level"] = set_level
--[[ (set-level "error") (level-idx "error") (log "debug" "foo") (log "info" "bar") (log "error" "baz") ]]--
return _2amodule_2a