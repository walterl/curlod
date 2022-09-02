(module curlod.lockdown
  {autoload {a curlod.aniseed.core
             bridge curlod.bridge
             log curlod.log
             nvim curlod.aniseed.nvim
             nu curlod.aniseed.nvim.util}})

(defn- last-line-num []
  (nvim.buf_line_count 0))

(defn- active-in-buf? []
  (= true nvim.w.curlod-active))

(defn- pattern? [x]
  (and (a.string? x)
       (vim.startswith x "/")
       (vim.endswith x "/")))

(defn- lua-pattern [s]
  (when (pattern? s)
    (s:sub 2 (a.dec (s:len)))))

(defn- lookup-first-line [pat]
  (var i 0)
  (a.some (fn [line]
            (set i (a.inc i))
            (when (line:match (lua-pattern pat))
              i))
          (nvim.buf_get_lines 0 0 -1 false)))

(defn- resolve-line-num [n]
  (if
    (= "number" (type n)) n
    (pattern? n) (lookup-first-line n)
    ;; else
    (tonumber n)))

(defn on-cursor-move []
  (when (active-in-buf?)
    (let [[start end] nvim.w.curlod-region
          [cur-line cur-col] (nvim.win_get_cursor 0)]
      (log.debug_ ">>>" start end cur-line cur-col)
      (if
        (< cur-line start)
        (do
          (log.info_ "Prevented cursor from leaving Curlod region")
          (nvim.win_set_cursor 0 [start cur-col]))

        (> cur-line end)
        (do
          (log.info_ "Prevented cursor from leaving Curlod region")
          (nvim.win_set_cursor 0 [end cur-col]))))))

(defn- region-start [start]
  (let [start (resolve-line-num start)]
    (if (a.nil? start)
      (do
        (log.error_ "Couldn't determine region start line. Using line 1.")
        1)
      start)))

(defn- region-end [end]
  (let [end (resolve-line-num end)]
    (if (a.nil? end)
      (do
        (log.error_ "Couldn't determine region end line. Using last line.")
        (last-line-num))
      end)))

(defn- smallest-first [a b]
  (if (< b a) [b a] [a b]))

(defn on-text-change []
  (when (active-in-buf?)
    (let [[old-start old-end] nvim.w.curlod-input-region
          [start end] (smallest-first (region-start old-start) (region-end old-end))]
      (when (or (not= old-start start) (not= old-end end))
        (log.debug_ "New region:" [start end])
        (set nvim.w.curlod-region [start end])))))

(defn enable [start end]
  (set nvim.w.curlod-active true)
  (set nvim.w.curlod-input-region [start end])
  (on-text-change)

  (let [[start end] nvim.w.curlod-region]
    (log.info_ "Locked cursor down between lines" start "and" end))

  ;; Commands
  (nvim.ex.augroup :curlod)
  (nvim.ex.autocmd_)
  (nvim.ex.autocmd
    "CursorMoved,CursorMovedI" :<buffer>
    (bridge.viml->lua :curlod.lockdown :on-cursor-move))
  (nvim.ex.autocmd
    "TextChanged,TextChangedI,TextChangedP" :<buffer>
    (bridge.viml->lua :curlod.lockdown :on-text-change))
  (nvim.ex.augroup :END)

  ;; Commands
  (nvim.ex.command_
    :-buffer "CurlodDisable"
    (bridge.viml->lua :curlod.lockdown :disable))
  (nvim.ex.command_
    :-buffer :CurlodSearchForward
    (bridge.viml->lua :curlod.lockdown :region-search))

  (nvim.ex.command_
    :-buffer :CurlodSearchBack
    (bridge.viml->lua :curlod.lockdown :region-search {:args "N"}))

  ;; Mappings
  (nvim.ex.nnoremap :<buffer> :n :<Cmd>CurlodSearchForward<CR>)
  (nvim.ex.nnoremap :<buffer> :N :<Cmd>CurlodSearchBack<CR>)

  ;; Ensure that cursor is in our lockdown region
  (on-cursor-move))

(defn disable []
  (set nvim.w.curlod-active false)
  (set nvim.w.curlod-region nil)
  (nvim.ex.autocmd_ :curlod)
  (nvim.ex.nunmap :<buffer> :n)
  (nvim.ex.nunmap :<buffer> :N))

(defn- cursor-in-region? [[cur-line _] [start-line end-line]]
  (<= start-line cur-line end-line))

(defn- cursor-at-any-pos? [[cur-line cur-col] positions]
  (not (a.nil? (a.some (fn [[l c]] (and (= cur-line l) (= cur-col c)))
                       positions))))

(defn region-search [next-cmd]
  (var next-cmd (or next-cmd "n"))
  (set nvim.w.curlod-active false)
  (var orig-cursor-pos (nvim.win_get_cursor 0))
  (var seen-match-pos [])
  (nu.normal next-cmd)
  (var cursor-pos (nvim.win_get_cursor 0))
  (log.debug_ "cursor-pos:" cursor-pos)
  (while (and (not (cursor-in-region? cursor-pos nvim.w.curlod-region))
              (not (cursor-at-any-pos? cursor-pos seen-match-pos)))
    (table.insert seen-match-pos cursor-pos)
    (nu.normal next-cmd)
    (set cursor-pos (nvim.win_get_cursor 0))
    (log.debug_ "cursor-pos:" cursor-pos))
  (when (cursor-at-any-pos? cursor-pos seen-match-pos)
    (log.error_ "Pattern not found in Curlod range.")
    (nvim.win_set_cursor 0 orig-cursor-pos))
  (set nvim.w.curlod-active true))

(comment
  (log.set-level :debug)
  (log.set-level :info)
  (pattern? nil)
  (resolve-line-num nil)
  (enable 3 20)
  (enable "/comment/")
  (enable 0 "/nvim/")
  )
