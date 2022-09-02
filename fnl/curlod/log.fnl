(module curlod.log
  {autoload {a curlod.aniseed.core
             nvim curlod.aniseed.nvim}})

(set _G.curlod-log-level :info)

(defn- println-debug [...]
  (a.println "[DEBUG]" ...))

(def levels
  [[:debug println-debug]
   [:info a.println]
   [:error nvim.err_writeln]])

(defn- bool [x]
  ;; Surely there's a built-in better way...?
  (not (not x)))

(defn- valid-level? [level]
  (bool
    (a.some (fn [[l _]] (= l level)) levels)))

(defn- level-idx [level]
  (var idx nil)
  (var i 1)
  (while (and (<= i (a.count levels)) (a.nil? idx))
    (when (= level (a.first (a.get levels i)))
      (set idx i))
    (set i (a.inc i)))
  idx)

(defn- log [level ...]
  (let [idx (level-idx level)]
    (when (<= (level-idx _G.curlod-log-level) idx)
      (let [f (a.second (a.get levels idx))]
        (f ...)))))

(defn debug_ [...]
  (log :debug ...))

(defn info_ [...]
  (log :info ...))

(defn error_ [...]
  (log :error ...))

(defn set-level [level]
  (if (valid-level? level)
    (set _G.curlod-log-level level)
    (log :error "Invalid log level: " level)))

(comment
  (set-level :error)
  (level-idx :error)

  (log :debug "foo")
  (log :info "bar")
  (log :error "baz")
  )
