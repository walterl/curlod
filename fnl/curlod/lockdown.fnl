(module curlod.lockdown
  {autoload {a curlod.aniseed.core
             bridge curlod.bridge
             nvim curlod.aniseed.nvim}})

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
  (var n 0)
  (a.some (fn [line]
            (set n (a.inc n))
            (when (line:match (lua-pattern pat))
              n))
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
      ;;(print ">>>" start end cur-line cur-col)
      (if
        (< cur-line start) (nvim.win_set_cursor 0 [start cur-col])
        (> cur-line end) (nvim.win_set_cursor 0 [end cur-col])))))

(defn- region-start [start]
  (let [start (resolve-line-num start)]
    (if (a.nil? start)
      (do
        (a.println "Couldn't determine region start line. Using line 1.")
        1)
      start)))

(defn- region-end [end]
  (let [end (resolve-line-num end)]
    (if (a.nil? end)
      (do
        (a.println "Couldn't determine region end line. Using last line.")
        (last-line-num))
      end)))

(defn enable [start end]
  (let [start (region-start start)
        end (region-end end)
        [start end] (if (< end start) [end start] [start end])]
    (set nvim.w.curlod-active true)
    (set nvim.w.curlod-region [start end])

    (a.println "Locked cursor down between lines" start "and" end)

    (nvim.ex.augroup :curlod)
    (nvim.ex.autocmd_)
    (nvim.ex.autocmd
      "CursorMoved,CursorMovedI" :<buffer>
      (bridge.viml->lua :curlod.lockdown :on-cursor-move))
    ;; TODO On buffer change, recalculate nvim.w.curlod-{start,end}
    (nvim.ex.augroup :END)
    ;; TODO Limit vim searches to Curlod region
    ;; TODO Highlight lines outside of Curlod region
    (on-cursor-move)
    ))

(defn disable []
  (set nvim.w.curlod-active false)
  (set nvim.w.curlod-region nil)
  (nvim.ex.autocmd_ :curlod))

(comment
  (pattern? nil)
  (resolve-line-num nil)
  (enable 3 20)
  (enable 15 "/stop/")
  (enable "/on%-cursor%-move/" 80)
  )
