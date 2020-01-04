;; lines for meta data
;; https://github.com/rememberYou/.emacs.d/blob/master/config.org

;; * Encapsulate my customization inside a function
;;    that gets called through radian-after-init-hook
(defun radian-local--after-init ()
  (server-start)
  (add-to-list 'Info-directory-list (expand-file-name "etc/" user-emacs-directory))
  ;; ** Auto Encryption/Decryption support for gpg and asc files
  (setq epa-armor t)
  (setq epa-file-name-regexp "\\.\\(gpg\\|asc\\)$")
  (epa-file-name-regexp-update)

  (use-package all-the-icons ;;https://github.com/wyuenho/dotfiles/blob/master/.emacs
    :defer 1
    :if (display-graphic-p)
    :config
    ;; replace major-mode names with corresponding icons
    (add-hook 'after-change-major-mode-hook
              (lambda ()
                (let* ((icon (all-the-icons-icon-for-mode major-mode))
                       (face-prop (and (stringp icon) (get-text-property 0 'face icon))))
                  (when (and (stringp icon) (not (string= major-mode icon)) face-prop)
                    (setq mode-name (propertize icon 'display '(:ascent center))))))))
  ;; remove parens around mode representations in mode-line
  (delete "(" (delete ")" mode-line-modes)) ;; the round parens are added by bindings.el
  ;; remove minor-mode representation in mode-line
  (setq mode-line-modes    ;; from https://emacs.stackexchange.com/questions/3925/hide-list-of-minor-modes-in-mode-line/46947#46947
        (mapcar (lambda (elem)
                  (pcase elem
                    (`(:propertize (,_ minor-mode-alist . ,_) . ,_)
                     "")
                    (t elem)))
                mode-line-modes))


;; ** csv-mode package
  (use-package csv-mode)

;; ** 'general' package
  (use-package general
    ;;mbk :straight t
    :demand t
    :config
    (general-override-mode))

;; *** Create our own definer and make 'SPC' the leader key
  ;;    straight from general docuentation
  (general-create-definer tyrant-def
    :states '(normal motion visual insert emacs)
    :prefix "SPC"
    :non-normal-prefix "M-SPC"
    :prefix-command 'tyrant-prefix-command
    :prefix-map 'tyrant-prefix-map)

;; ** evil package
  (use-package evil
    ;;mbk :straight t
    :demand t
    :init
    (setq evil-want-keybinding nil)
    :general
    ;; more than one (ie. multiple) keybinding can be specified for any given keyword this way
    ;; don't understand the concept of keyword arguments and how parameters are bound to arguments
    ;; move over visual lines like normal lines
    (:states '(motion normal)
             "j" #'evil-next-visual-line
             "k" #'evil-previous-visual-line)
    ;; z+ originally == evil-scroll-bottom-line-to-top -- rarely needed.
    ;; repurpose to text scaling
    (:states '(visual normal)
             "z+" #'text-scale-adjust)
    (:states '(insert)
             "C-e" #'end-of-line
             "C-a" #'evil-first-non-blank-of-visual-line)
    :config
    (progn
      (setq evil-search-module 'evil-search)
      (setq evil-magic 'very-magic)
      ;; (setq evil-want-C-i-jump nil)
      (add-hook 'git-commit-mode-hook 'evil-insert-state)
      (evil-set-initial-state 'messages-buffer-mode 'normal)
      (evil-set-initial-state 'magit-log-edit-mode 'insert)
      ;; evil-normal-state is preferred, so revert when idle
      (run-with-idle-timer 60 t 'evil-normal-state)
      ;; do/don't echo evil state
      (setq evil-echo-state t)
      ;; don't move cursor back when exiting insert state
      (setq evil-move-cursor-back nil)
      ;; evil everywhere
      (evil-mode 1)
      ))

  (use-package evil-indent-textobject
    ;;mbk :straight t
    :after evil
    :commands (evil-indent))

  (use-package evil-surround
    ;; :commands (evil-surround-region evil-surround-change evil-surround-delete)
    ;; :hook ((LaTeX-mode org-mode markdown-mode prog-mode) . evil-surround-mode)
    ;;mbk :straight t
    ;;mbk :general
    ;;mbk (:states '(visual)
    ;;mbk          "s" 'evil-surround-region
    ;;mbk          "S" 'evil-substitute)
    :after evil
    :defer 1
    :config
    (global-evil-surround-mode 1)
    )

  (use-package evil-commentary
    ;;mbk :straight t
    :after evil
    :commands (evil-commentary evil-commentary-line)
    ;; :diminish evil-commentary-mode
    :config
    (evil-commentary-mode))

  ;; minor-mode-alist variable determines how minormode are displayed
  (use-package evil-escape
    :after evil
    :init
    (evil-escape-mode)
    (setq evil-escape-lighter nil)
    :config
    (setq-default evil-escape-key-sequence "tn")
    (setq-default evil-escape-undordered-key-sequence t)
    )

  (use-package evil-text-object-python
    :after evil
    :hook ((python-mode . evil-text-object-python-add-bindings)))

  ;;mbk (use-package evil-mc
  ;;mbk   :straight t
  ;;mbk   ;;mbk :commands (evil-mc-make-all-cursors evil-mc-make-and-goto-next-match))
  ;;mbk   :config
  ;;mbk   (global-evil-mc-mode 1))

  ;;mbk (use-package evil-numbers
  ;;mbk   :straight t
  ;;mbk   :commands (evil-numbers/inc-at-pt evil-numbers/dec-at-pt)
  ;;mbk   :init
  ;;mbk   :general
  ;;mbk   (:states '(normal)
  ;;mbk    "C-c +" 'evil-numbers/inc-at-pt
  ;;mbk    "C-c -" 'evil-numbers/dec-at-pt)

  (use-package evil-visualstar
    ;;mbk :straight t
    :after evil
    ;;mbk :commands (evil-visualstar/begin-search-forward evil-visualstar/begin-search-backward))
    :config
    )

  ;; needed to explicitly spec out annalist -- otherwise getting a fail: no recipe found for annalist
  (straight-use-package '(annalist :host github :repo "noctuid/annalist.el"))
  (use-package evil-collection
    :straight (:host github
                     :repo "emacs-evil/evil-collection"
                     :files (:defaults "modes") ;; recipe is needed, otherwise causes build error
                     :fork (:repo "mbkamble/evil-collection"))
    :after evil
    :defer 1
    :custom (evil-collection-setup-minibuffer t)
    :init (evil-collection-init)
    ;; (message "evil-collection-init executed")
    ;;mbk (setq evil-collection-mode-list t)
    )

  (use-package evil-args
    :defer 2
    :general
    (:keymaps 'evil-inner-text-objects-map
              "a" 'evil-inner-arg)
    (:keymaps 'evil-outer-text-objects-map
              "a" 'evil-outer-arg)
    )

;; ** outshine
;;   (use-package outshine
;;     :defer 2
;;     :blackout ;; blackout is an enhancement over delight
;;     ;;mbk :straight t
;;     :hook ((prog-mode . outshine-mode)
;;            )
;;     :config
;;     ;; works (setcar (cdr (assq 'outshine-mode minor-mode-alist)) " Osh") ;; default is " Outshine"
;;     ;; Narrowing now works within the headline rather than requiring to be on it
;;     (setq outshine-org-style-global-cycling-at-bob-p t)
;;     (advice-add 'outshine-narrow-to-subtree :before
;;                 (lambda (&rest args) (unless (outline-on-heading-p t)
;;                                        (outline-previous-visible-heading 1))))
;;     :general
;;     (:definer 'minor-mode
;;      :keymaps 'outshine-mode
;;      :states  '(normal motion)
;;      "<backtab>" #'outshine-cycle-buffer
;;      "M-TAB"     #'outshine-cycle
;;      "gh"        #'outline-up-heading
;;      "gj"        #'outline-forward-same-level
;;      "gk"        #'outline-backward-same-level
;;      "gl"        #'outline-next-visible-heading
;;      "gu"        #'outline-previous-visible-heading)
;;     (:definer 'minor-mode
;;      :keymaps 'outshine-mode
;;      :states  '(insert)
;;      "M-RET"   #'outshine-insert-heading
;;      "S-M-RET" #'outshine-insert-subheading)
;;     )

  (use-package evil-lion
    :defer 1
    :after evil
    :config
    (evil-lion-mode)
    )

  (use-package which-key
    :defer 1
    :blackout ;; prevent mode display in mode-line
    :config
    (which-key-mode +1))

  (use-package avy
    :config
    (setq avy-timeout-seconds 0.35)
    (setq avy-background t))

  (use-package ivy-xref
    :init (if (< emacs-major-version 27)
              (setq xref-show-xrefs-function #'ivy-xref-show-xrefs)
            (setq xref-show-definitions-function #'ivy-xref-show-defs)))

  (use-package dired-hacks-utils)
  (use-package dired-filter
    :after dired-hacks-utils)
  (use-package dired-narrow
    :general (:states '(normal) :keymaps 'dired-mode-map "* n" #'dired-narrow))
  (use-package winum
    :init
    (setq winum-keymap
          (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-`") 'winum-select-window-by-number)
            (define-key map (kbd "M-0") 'winum-select-window-0-or-10)
            (define-key map (kbd "M-1") 'winum-select-window-1)
            (define-key map (kbd "M-2") 'winum-select-window-2)
            (define-key map (kbd "M-3") 'winum-select-window-3)
            (define-key map (kbd "M-4") 'winum-select-window-4)
            (define-key map (kbd "M-5") 'winum-select-window-5)
            (define-key map (kbd "M-6") 'winum-select-window-6)
            (define-key map (kbd "M-7") 'winum-select-window-7)
            (define-key map (kbd "M-8") 'winum-select-window-8)
            map))
    :config
    (defun winum-assign-9-to-calculator-8-to-flycheck-errors ()
      (cond
       ((equal (buffer-name) "*Calculator*") 9)
       ((equal (buffer-name) "*Flycheck errors*") 8)))

    (defun winum-assign-0-to-neotree ()
      (when (string-match-p (buffer-name) ".*\\*NeoTree\\*.*") 10))

    (add-to-list 'winum-assign-functions #'winum-assign-9-to-calculator-8-to-flycheck-errors)
    ;;(add-to-list 'winum-assign-functions #'winum-assign-0-to-neotree)
    (setq winum-ignored-buffers '(" *which-key*")
          winum-auto-setup-mode-line nil)
    (winum-mode)
    )
  ;; Application Keybindings
  (tyrant-def
    :keymaps 'override
    "a"  '(:ignore t :which-key "Applications")
    "ad" 'dired-jump
    "ae" 'eshell
    "ar" 'ranger
    "aw" 'wttrin
    )
  ;; Buffer Keybindings
  (tyrant-def
    :keymaps 'override

    "b"  '(:ignore t :which-key "Buffers")
    ;;"bb" 'helm-mini
    ;;"bc" 'cpm/copy-whole-buffer-to-clipboard
    "bD" 'kill-buffer-and-window
    ;;"bd" 'cpm/kill-this-buffer
    "be" 'erase-buffer
    ;; "bf" 'cpm/browse-file-directory
    ;;"bj" 'cpm/jump-in-buffer
    "bk" 'evil-delete-buffer
    "bK" 'crux-kill-other-buffers
    "bl" 'display-line-numbers-mode
    ;;"bN" 'cpm/new-buffer-new-frame
    "bo" 'ivy-switch-buffer-other-window
    "br" 'revert-buffer
    "bs" 'counsel-switch-buffer
    "bR" 'crux-rename-buffer-and-file
    "bt" 'open-dir-in-iterm
    )
  ;; File Keybindings
  (tyrant-def
    :keymaps 'override

    "f"  '(:ignore t :which-key "Files")
    "ff" 'counsel-find-files
    "fl" 'counsel-locate
    "fo" 'crux-open-with
    "fs" 'save-buffer
    "fr" 'counsel-recentf
    "fy" '(cpm/show-and-copy-buffer-filename :which-key "show/copy")
    )

  ;; Search Keybindings
  (tyrant-def
    :keymaps 'override

    "s"  '(:ignore t :which-key "Search")
    "sa" 'evil-avy-goto-char-timer
    "sw" 'evil-avy-goto-word-or-subword-1
    )

  ;; Outline minor mode
  ;;mbk   (tyrant-def
  ;;mbk     :keymaps 'override
  ;;mbk
  ;;mbk     "n"  '(:ignore t :which-key "Narrow")
  ;;mbk     ;; Narrowing
  ;;mbk     "nn" '#outshine-narrow-to-subtree
  ;;mbk     "nw" '#widen
  ;;mbk
  ;;mbk     ;; Structural edits (use the keys defined by evil-collection-outline)
  ;;mbk    )
  ;;mbk    (tyrant-def
  ;;mbk     :keymaps 'outline-minor-mode-map
  ;;mbk     :states '(normal visual motion)
  ;;mbk     "gh" 'outline-up-heading
  ;;mbk     "gj" 'outline-forward-same-level
  ;;mbk     "gk" 'outline-backward-same-level
  ;;mbk     "gl" 'outline-next-visible-heading ;; also on ']]' (evil-collection-outline)
  ;;mbk     "gu" 'outline-previous-visible-heading ;; also on '[[' (evil-collection-outline)
  ;;mbk     )
  (custom-set-variables
   ;; custom-set-variables was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(radian-mode-line-left
     '((:eval
        (radian-mode-line-buffer-modified-status))
       " "
       evil-mode-line-tag
       (:eval
        (format "[%s]"
                (winum-get-number-string)))
       " " mode-line-buffer-identification
       "   " mode-line-position radian-mode-line-project-and-branch
       "  " mode-line-modes))
   '(recentf-max-saved-items 200)
   )
  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   )
  (with-eval-after-load 'python
              (add-to-list 'python-shell-completion-native-disabled-interpreters "jupyter")
              (message (format "add-to-list done. disabled interpreters=%s" python-shell-completion-native-disabled-interpreters))
              (setq python-shell-interpreter "jupyter"
                    python-shell-interpreter-args "console --simple-prompt"
                    python-shell-prompt-detect-failure-warning nil))
  )

(defalias 'yes-or-no-p 'y-or-n-p)
(custom-set-default 'display-line-numbers-type 'relative)
(setq straight-cache-autoloads t)
(setq straight-use-package-by-default t)
(setq use-package-verbose t)
(setq evil-want-keybinding nil)
(defvar outline-minor-mode-prefix "\M-#")

;; define a eshell command for multiple arguments
(defun eshell/for-each (cmd &rest args)
    (let ((fn (intern cmd))
          (dir default-directory))
      (dolist (arg (eshell-flatten-list args))
        (let ((default-directory dir))
          (funcall fn arg)))))


(add-hook 'radian-after-init-hook #'radian-local--after-init)
(add-hook 'radian-before-straight-hook (lambda () (setq straight-recipes-emacsmirror-use-mirror t)))

;; notes
;; ivy--actions-list stores the action items that show up in Hydra mode
;; C-o brings up hydra
