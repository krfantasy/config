(require 'package)
(setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))
(package-initialize) ;; You might already have this line


;;; CC mode
(require 'cc-mode)
(defconst w2h-c-style
  '("bsd"
    (c-basic-offset . 4)
    (c++-indent-level . 4)
    (indent-tabs-mode . t)
    (tab-width . 4)
    (c-comment-only-line-offset . 0)
    (c-offsets-alist . ((inextern-lang . 0)
                        (extern-lang-open . 0)
                        (extern-lang-close . 0)
                        (arglist-close . 0)
                        (cpp-macro . [0])))
    (c-hanging-braces-alist . ((brace-list-open)
                               (brace-list-close)
                               (statement-cont before)
                               (statement-open before)
                               (substatement-open before after)
                               (block-close . c-snug-do-while)
                               (extern-lang-open after)
                               (namespace-open after)))
    (c-block-comment-prefix . "*")))

(c-add-style "w2h" w2h-c-style)

(defun my-c-mode-common-hook ()
  (setq indent-tabs-mode nil)
  (c-set-style "w2h")
  (c-toggle-syntactic-indentation 1)
  (c-toggle-electric-state 1)
  (c-toggle-auto-hungry-state 1)
  (flyspell-prog-mode))

(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c-mode-common-hook 'lsp-deferred)

;; OpenCL
(require 'opencl-mode)
(add-to-list 'auto-mode-alist '("\\.cl\\'" . opencl-mode))
(add-to-list 'auto-mode-alist '("\\.clh\\'" . opencl-mode))

;(require 'maxima)

;; Gud
(setq gdb-many-windows t)
(defvar all-gud-modes
  '(gud-mode comint-mode gdb-locals-mode gdb-frames-mode  gdb-breakpoints-mode)
  "A list of modes when using gdb")
(defun kill-all-gud-buffers ()
  "Kill all gud buffers including Debugger, Locals, Frames, Breakpoints.
Do this after `q` in Debugger buffer."
  (interactive)
  (save-excursion
        (let ((count 0))
          (dolist (buffer (buffer-list))
                (set-buffer buffer)
                (when (member major-mode all-gud-modes)
                  (setq count (1+ count))
                  (kill-buffer buffer)
                  (delete-other-windows))) ;; fix the remaining two windows issue
          (message "Killed %i buffer(s)." count))))

;; Semantic
;; (require 'semantic)
;; (global-semanticdb-minor-mode 1)
;; (global-semantic-idle-scheduler-mode 1)
;; (global-semantic-mru-bookmark-mode 1)

;; (semantic-mode 1)

;; (require 'semantic/senator)
;; (require 'semantic/bovine/c)
;; (require 'semantic/bovine/gcc)
;; (require 'semantic/ia)


;; (global-set-key [f12] 'semantic-ia-fast-jump)
;; ;(global-set-key [S-f12] 'semantic-mrub-switch-tag)

;; (defadvice push-mark (around semantic-mru-bookmark activate)
;;     "Push a mark at LOCATION with NOMSG and ACTIVATE passed to `push-mark'.
;; If `semantic-mru-bookmark-mode' is active, also push a tag onto
;; the mru bookmark stack."
;;     (semantic-mrub-push semantic-mru-bookmark-ring
;;                         (point)
;;                         'mark)
;;     ad-do-it)

;; (global-set-key [S-f12]
;;                 (lambda ()
;;                   (interactive)
;;                   (if (ring-empty-p (oref semantic-mru-bookmark-ring ring))
;;                       (error "Semantic Bookmark ring is currently empty"))
;;                   (let* ((ring (oref semantic-mru-bookmark-ring ring))
;;                          (alist (semantic-mrub-ring-to-assoc-list ring))
;;                          (first (cdr (car alist))))
;;                     (if (semantic-equivalent-tag-p (oref first tag)
;;                                                    (semantic-current-tag))
;;                         (setq first (cdr (car (cdr alist)))))
;;                     (semantic-mrub-switch-tags first))))

;;; Lua
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))


;;; Common Lisp
(require 'slime)
(slime-setup '(slime-fancy slime-mrepl slime-company))
(add-to-list 'auto-mode-alist '("\\.cl\\'" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.xcvb\\'" . lisp-mode))
(add-to-list 'auto-mode-alist '("\\.asdf\\'" . lisp-mode))
(setq slime-net-coding-system 'utf-8-unix
      slime-lisp-implementations '((sbcl ("/usr/local/bin/sbcl") :coding-system utf-8-unix)
                                   (ccl ("/usr/local/bin/ccl64") :coding-system utf-8-unix))
      slime-autodoc-use-multiline-p t
      slime-default-lisp 'sbcl)
(load "/home/krfantasy/quicklisp/clhs-use-local.el" t)
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)

;;; Scheme
(add-to-list 'auto-mode-alist '("\\.sls\\'" . scheme-mode))
(load-file "~/Source/geiser/elisp/geiser.el")

(add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-mode))
(require 'racket-xp)
(add-hook 'racket-mode-hook #'racket-xp-mode)
(add-hook 'racket-xp-mode-hook
	  (lambda ()
            (setq tab-always-indent 'complete)
	    (remove-hook 'pre-redisplay-functions
			 #'racket-xp-pre-redisplay
			 t))

;;; smartparens
(require 'smartparens-config)
(smartparens-global-mode 1)
(setq sp-highlight-pair-overlay nil)


;; Paredit
(autoload 'paredit-mode "paredit"
  "Minor mode for pseudo-structurally editing Lisp code." t)

;; Stop SLIME's REPL from grabbing DEL,
;; which is annoying when backspacing over a '('
(defun override-slime-repl-bindings-with-paredit ()
  (define-key slime-repl-mode-map
    (read-kbd-macro paredit-backward-delete-key) nil))
(add-hook 'slime-repl-mode-hook 'override-slime-repl-bindings-with-paredit)


;; Electric RETURN
(defvar electrify-return-match
  "[\]}\)\"]"
  "If this regexp matches the text after the cursor, do an \"electric\"
  return.")
(defun electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
	(save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

;; Using local-set-key in a mode-hook is a better idea.
;; (global-set-key (kbd "RET") 'electrify-return-if-match)


(defun switch-to-paredit ()
  (smartparens-mode -1)
  (paredit-mode +1)
  (local-set-key (kbd "RET") 'electrify-return-if-match))

(defvar lisp-mode-hooks
  '(emacs-lisp-mode-hook
    lisp-interaction-mode-hook
    ielm-mode-hook
    scheme-mode-hook
    geiser-mode-hook
    geiser-repl-mode-hook
    lisp-mode-hook
    inferior-lisp-mode-hook
    slime-repl-mode-hook))

(mapcar (lambda (hook) (add-hook hook 'switch-to-paredit))
	lisp-mode-hooks)

;;; Company mode
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(setq company-auto-complete nil
      company-clang-executable "clang-10")
(global-set-key (kbd "M-/") 'company-complete-common-or-cycle)
(company-quickhelp-mode)
(define-key company-active-map (kbd "SPC") nil)


;;; FlyCheck
(require 'flycheck)
(add-hook 'after-init-hook #'global-flycheck-mode)
(setq-default flycheck-disabled-checkers '(c/c++-gcc)
	      flycheck-c/c++-clang-executable "clang-10")
(add-hook 'c++-mode-hook
	  (lambda ()
	    (setq flycheck-clang-language-standard "c++17")
	    (setq flycheck-clang-openmp t)))

(flycheck-define-checker opencl-clang
  "bullshit here!"
  :command ("clang-8" "-xcl" "-cl-std=CL1.2" "-DCLANG_SYNTAX_CHECK" "-fsyntax-only" "-I./" source)
  :standard-input t
  :error-patterns
  ((error line-start
          (message "In file included from") " " (or "<stdin>" (file-name))
          ":" line ":" line-end)
   (info line-start (or "<stdin>" (file-name)) ":" line ":" column
         ": note: " (optional (message)) line-end)
   (warning line-start (or "<stdin>" (file-name)) ":" line ":" column
            ": warning: " (optional (message)) line-end)
   (error line-start (or "<stdin>" (file-name)) ":" line ":" column
          ": " (or "fatal error" "error") ": " (optional (message)) line-end))

  :modes opencl-mode)
(add-to-list 'flycheck-checkers 'opencl-clang)

;;; misc
;; flyspell
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

;; magit
(require 'magit)
(global-set-key (kbd "C-x g") 'magit-status)
(setq transient-default-level 5)

;; Helm
(require 'helm-config)
(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
(helm-mode 1)

;; font
(add-to-list 'default-frame-alist '(font . "Monaco 10"))
(set-face-attribute 'default t :font "Monaco 10")

;; linum
(require 'linum)
(linum-mode 1)
(setq toggle-truncate-lines t)
(setq linum-format "%3d ")
(add-hook 'find-file-hooks (lambda () (linum-mode 1)))


(require 'tabbar)
(tabbar-mode)
(global-set-key (kbd "C-c M-p") 'tabbar-backward-group)
(global-set-key (kbd "C-c M-n") 'tabbar-forward-group)
(global-set-key (kbd "C-c M-b") 'tabbar-backward)
(global-set-key (kbd "C-c M-f") 'tabbar-forward)

;; Add a buffer modification state indicator in the tab label, and place a
;; space around the label to make it looks less crowd.
(defadvice tabbar-buffer-tab-label (after fixup_tab_label_space_and_flag activate)
  (setq ad-return-value
        (if (and (buffer-modified-p (tabbar-tab-value tab))
                 (buffer-file-name (tabbar-tab-value tab)))
            (concat " + " (concat ad-return-value " "))
          (concat " " (concat ad-return-value " ")))))
;; Called each time the modification state of the buffer changed.
(defun ztl-modification-state-change ()
  (tabbar-set-template tabbar-current-tabset nil)
  (tabbar-display-update))
;; First-change-hook is called BEFORE the change is made.
(defun ztl-on-buffer-modification ()
  (set-buffer-modified-p t)
  (ztl-modification-state-change))
(add-hook 'after-save-hook 'ztl-modification-state-change)
;; This doesn't work for revert, I don't know.
;;(add-hook 'after-revert-hook 'ztl-modification-state-change)
(add-hook 'first-change-hook 'ztl-on-buffer-modification)

;; rainbow delimiters
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key (kbd "C-z") nil)
(setq column-number-mode t
      blink-cursor-mode t)
(setq-default  indent-tabs-mode nil)

(auto-image-file-mode t)

(global-font-lock-mode t)

(fset 'yes-or-no-p 'y-or-n-p)

;; delete trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(global-visual-line-mode 1)

;; matching paren
(show-paren-mode t)
(setq show-paren-style 'parentheses
      default-major-mode 'text-mode
      mouse-yank-at-point t
      inhibit-startup-message t
      visible-bell t)

;; Org Mode
(setq org-clock-persist 't
      org-log-done 'note)
(org-clock-persistence-insinuate)


(require 'ediff)
(setq ediff-split-window-function 'split-window-horizontally)

;;; ERC
(setq erc-nick "krfantasy")

;; eww
(setq browse-url-browser-function 'eww-browse-url)

;;; Gnus
(setq user-mail-address "jay.xu.krfantasy@gmail.com"
      user-full-name "Jay Xu")

(setq gnus-select-method
      '(nnimap "GMail"
               (nnimap-address "imap.gmail.com")
               (nnimap-server-port "imaps")
               (nnimp-stream ssl)))

(setq smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]\")\"]\\)")

;(add-to-list 'gnus-secondary-select-methods '(nntp "nntp.aioe.org"))

;;; Font
(add-to-list 'default-frame-alist '(font . "Monaco 10"))
(set-face-attribute 'default t :font "Monaco 10")
(set-frame-font "Monaco 10" nil t)
;;; setup emoji
(add-hook 'after-init-hook #'global-emojify-mode)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(column-number-mode t)
 '(company-backends
   (quote
    (company-slime company-nxml company-css company-cmake company-files company-abbrev company-elisp
                   (company-dabbrev-code company-gtags company-etags company-keywords)
                   company-oddmuse company-dabbrev)))
 '(company-quickhelp-color-background "#4F4F4F")
 '(company-quickhelp-color-foreground "#DCDCCC")
 '(company-quickhelp-delay 1.0)
 '(compilation-message-face (quote default))
 '(cua-global-mark-cursor-color "#7ec98f")
 '(cua-normal-cursor-color "#8c8a85")
 '(cua-overwrite-cursor-color "#e5c06d")
 '(cua-read-only-cursor-color "#8ac6f2")
 '(custom-enabled-themes (quote (dracula)))
 '(custom-safe-themes
   (quote
    ("d916b686ba9f23a46ee9620c967f6039ca4ea0e682c1b9219450acee80e10e40" "5a04c3d580e08f5fc8b3ead2ed66e2f0e5d93643542eec414f0836b971806ba9" "f56eb33cd9f1e49c5df0080a3e8a292e83890a61a89bceeaa481a5f183e8e3ef" "13a8eaddb003fd0d561096e11e1a91b029d3c9d64554f8e897b2513dbf14b277" "0fffa9669425ff140ff2ae8568c7719705ef33b7a927a0ba7c5e2ffcfac09b75" "2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "dcdd1471fde79899ae47152d090e3551b889edf4b46f00df36d653adc2bf550d" "0c9f63c9d90d0d135935392873cd016cc1767638de92841a5b277481f1ec1f4a" "13a05a5318b1f78bffd5c584b5d1260ae6745c01fe030bc5155b5f828936319c" "41c8c11f649ba2832347fe16fe85cf66dafe5213ff4d659182e25378f9cfc183" "7dc3fe8fadb914563790a3fbe587fd455626442f66da333ea4de2c455feefb98" "947190b4f17f78c39b0ab1ea95b1e6097cc9202d55c73a702395fc817f899393" default)))
 '(default-frame-alist (quote ((height . 48) (width . 120) (font . "Monaco 10"))))
 '(dictionary-server "localhost")
 '(ede-project-directories (quote ("/home/krfan/LoopOS")))
 '(emojify-emoji-set "emojione-v2.2.6")
 '(ensime-sem-high-faces
   (quote
    ((var :foreground "#000000" :underline
          (:style wave :color "yellow"))
     (val :foreground "#000000")
     (varField :foreground "#600e7a" :slant italic)
     (valField :foreground "#600e7a" :slant italic)
     (functionCall :foreground "#000000" :slant italic)
     (implicitConversion :underline
                         (:color "#c0c0c0"))
     (implicitParams :underline
                     (:color "#c0c0c0"))
     (operator :foreground "#000080")
     (param :foreground "#000000")
     (class :foreground "#20999d")
     (trait :foreground "#20999d" :slant italic)
     (object :foreground "#5974ab" :slant italic)
     (package :foreground "#000000")
     (deprecated :strike-through "#000000"))))
 '(erc-modules
   (quote
    (autoaway autojoin button completion fill irccontrols list match menu move-to-prompt netsplit networks noncommands readonly ring stamp spelling track)))
 '(erc-nick "krfantasy" t)
 '(fci-rule-color "#383838")
 '(geiser-active-implementations (quote (chez guile)))
 '(geiser-chez-extra-command-line-parameters nil)
 '(geiser-default-implementation (quote chez))
 '(geiser-implementations-alist
   (quote
    (((regexp "\\.ss$")
      chez)
     ((regexp "\\.def$")
      chez)
     ((regexp "\\.sls$")
      chez)
     ((regexp "\\.scm$")
      guile)
     ((regexp "\\.scm$")
      chicken)
     ((regexp "\\.release-info$")
      chicken)
     ((regexp "\\.meta$")
      chicken)
     ((regexp "\\.setup$")
      chicken)
     ((regexp "\\.scm$")
      mit)
     ((regexp "\\.pkg$")
      mit)
     ((regexp "\\.scm$")
      chibi)
     ((regexp "\\.sld$")
      chibi)
     ((regexp "\\.scm$")
      gambit))))
 '(helm-completion-style (quote emacs))
 '(highlight-changes-colors (quote ("#e5786d" "#834c98")))
 '(highlight-symbol-colors
   (quote
    ("#53f14ae238f6" "#3dfc4d203fcc" "#58f348ab45e4" "#3ec3324f41e1" "#41574c3354ab" "#52464649390d" "#45ad48955232")))
 '(highlight-symbol-foreground-color "#989790")
 '(highlight-tail-colors
   (quote
    (("#2e2e2d" . 0)
     ("#3d454b" . 20)
     ("#3a463b" . 30)
     ("#404249" . 50)
     ("#4b4436" . 60)
     ("#4a4036" . 70)
     ("#4c3935" . 85)
     ("#2e2e2d" . 100))))
 '(hl-bg-colors
   (quote
    ("#4b4436" "#4a4036" "#4f4240" "#4c3935" "#3b313d" "#404249" "#3a463b" "#3d454b")))
 '(hl-fg-colors
   (quote
    ("#292928" "#292928" "#292928" "#292928" "#292928" "#292928" "#292928" "#292928")))
 '(hl-paren-colors (quote ("#7ec98f" "#e5c06d" "#a4b5e6" "#834c98" "#8ac6f2")))
 '(lsp-clients-clangd-args (quote ("--completion-style=detailed")))
 '(lsp-clients-clangd-executable "clangd-10")
 '(lsp-enable-snippet nil)
 '(lsp-ui-doc-border "#989790")
 '(lua-default-application "luajit")
 '(nrepl-message-colors
   (quote
    ("#CC9393" "#DFAF8F" "#F0DFAF" "#7F9F7F" "#BFEBBF" "#93E0E3" "#94BFF3" "#DC8CC3")))
 '(nyan-animate-nyancat t)
 '(nyan-mode t)
 '(nyan-wavy-trail t)
 '(org-agenda-files (quote ("~/work.org")))
 '(org-clock-idle-time 15)
 '(org-html-htmlize-output-type (quote css))
 '(package-selected-packages
   (quote
    (racket-mode auctex-lua emoji-fontset emojify pcre2el markdown-mode+ cmake-mode company-auctex auctex yasnippet solarized-theme zenburn-theme dracula-theme darcula-theme dictionary helm rainbow-delimiters company-c-headers opencl-mode company-glsl doom nyan-mode company-lua lua-mode markdown-preview-mode markdown-preview-eww multi-term magit glsl-mode yaml-mode flycheck company-jedi markdown-mode paredit tabbar smartparens evil-smartparens company-quickhelp)))
 '(pdf-view-midnight-colors (quote ("#DCDCCC" . "#383838")))
 '(pos-tip-background-color "#2e2e2d")
 '(pos-tip-foreground-color "#989790")
 '(show-paren-mode t)
 '(smartrep-mode-line-active-bg (solarized-color-blend "#8ac6f2" "#2e2e2d" 0.2))
 '(tabbar-background-color nil)
 '(tabbar-use-images t)
 '(term-default-bg-color "#292928")
 '(term-default-fg-color "#8c8a85")
 '(vc-annotate-background "#2B2B2B")
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   (quote
    ((20 . "#BC8383")
     (40 . "#CC9393")
     (60 . "#DFAF8F")
     (80 . "#D0BF8F")
     (100 . "#E0CF9F")
     (120 . "#F0DFAF")
     (140 . "#5F7F5F")
     (160 . "#7F9F7F")
     (180 . "#8FB28F")
     (200 . "#9FC59F")
     (220 . "#AFD8AF")
     (240 . "#BFEBBF")
     (260 . "#93E0E3")
     (280 . "#6CA0A3")
     (300 . "#7CB8BB")
     (320 . "#8CD0D3")
     (340 . "#94BFF3")
     (360 . "#DC8CC3"))))
 '(vc-annotate-very-old-color "#DC8CC3")
 '(weechat-color-list
   (quote
    (unspecified "#292928" "#2e2e2d" "#4f4240" "#ffb4ac" "#3d454b" "#8ac6f2" "#4b4436" "#e5c06d" "#404249" "#a4b5e6" "#4c3935" "#e5786d" "#3a463b" "#7ec98f" "#8c8a85" "#73726e")))
 '(xterm-color-names
   ["#2e2e2d" "#ffb4ac" "#8ac6f2" "#e5c06d" "#a4b5e6" "#e5786d" "#7ec98f" "#e7e4da"])
 '(xterm-color-names-bright
   ["#292928" "#ddaa6f" "#6a6965" "#73726e" "#8c8a85" "#834c98" "#989790" "#f5f2e7"]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(tabbar-selected ((t (:inherit tabbar-default :background "gray50" :foreground "blue" :box (:line-width 1 :color "white" :style pressed-button))))))
