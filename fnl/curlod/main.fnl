(module curlod.main
  {autoload {bridge curlod.bridge
             nvim curlod.aniseed.nvim}})

(defn init []
  (nvim.ex.command_
    "-nargs=*" "CurlodEnable"
    (bridge.viml->lua :curlod.lockdown :enable {:args :<f-args>}))
  (nvim.ex.command_
    "-range" "CurlodEnableRange"
    (bridge.viml->lua :curlod.lockdown :enable-range {:args "<line1>, <line2>"}))
  (nvim.ex.command_
    "-nargs=1" "CurlodLogLevel"
    (bridge.viml->lua :curlod.log :set-level {:args :<f-args>})))
