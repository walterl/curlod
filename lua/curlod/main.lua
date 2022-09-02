local _2afile_2a = "fnl/curlod/main.fnl"
local _2amodule_name_2a = "curlod.main"
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
local bridge, nvim = autoload("curlod.bridge"), autoload("curlod.aniseed.nvim")
do end (_2amodule_locals_2a)["bridge"] = bridge
_2amodule_locals_2a["nvim"] = nvim
local function init()
  nvim.ex.command_("-nargs=*", "CurlodEnable", bridge["viml->lua"]("curlod.lockdown", "enable", {args = "<f-args>"}))
  return nvim.ex.command_("-nargs=1", "CurlodLogLevel", bridge["viml->lua"]("curlod.log", "set-level", {args = "<f-args>"}))
end
_2amodule_2a["init"] = init
return _2amodule_2a