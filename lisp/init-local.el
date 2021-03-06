;; my emacs configs

;;; Code:

;;; theme
(require-package 'solarized-theme)
(load-theme 'solarized-wombat-dark)
(disable-theme 'solarized-wombat-dark)

;;; mac and linux clipboard funcs
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "nil" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(if (eq system-type 'darwin)
    (  (setq interprogram-cut-function 'paste-to-osx)
       (setq interprogram-paste-function 'copy-from-osx)
       )

  )

(defun linux-copy (beg end)
  (interactive "r")
  ;;  (copy-region-as-kill beg end)
  (shell-command-on-region beg end  "pbcopy")
  ;;  (goto-char end)
  ;;  (insert-buffer "*Shell Command Output*")
  (with-current-buffer
      "*Shell Command Output*"
    (send-string-to-terminal
     (concat "\x1B]52;;"
             (buffer-string)
             "\x1B\x5C")

     ))
  )


(defun linux-copy-non-inter (text &optional push)
  (with-temp-buffer
    (insert text)
    (shell-command-on-region (point-min) (point-max)  "pbcopy")
    (with-current-buffer
        "*Shell Command Output*"
      (send-string-to-terminal
       (concat "\x1B]52;;"
               (buffer-string)
               "\x1B\x5C")
       ))))

(if (eq system-type 'gnu/linux)
    (setq interprogram-cut-function 'linux-copy-non-inter))

;;;; org-mode
(add-hook 'org-mode-hook
          (lambda()
            (setq truncate-lines nil)))



;;; global settings
;;(global-linum-mode 1) ; always show line numbers
;;(setq linum-format "%d| ")  ;set format

(require-package 'bind-key)
(bind-key* "M-n" (lambda ()
                   (interactive)
                   (setq this-command 'next-line)
                   (next-line 10)))
(bind-key* "M-p" (lambda ()
                   (interactive)
                   (setq this-command 'next-line)
                   (previous-line 10)))

;;; golang
(require-package 'go-mode)

(add-hook 'go-mode-hook #'lsp-deferred)

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

(require-package 'lsp-mode)
(require-package 'use-package)
(use-package lsp-mode
  :ensure t
  ;; uncomment to enable gopls http debug server
  ;; :custom (lsp-gopls-server-args '("-debug" "127.0.0.1:0"))
  :commands (lsp lsp-deferred)
  :config (progn
            ;; use flycheck, not flymake
            (setq lsp-prefer-flymake nil)))


;; Optional - provides fancier overlays.
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; Company mode is a standard completion package that works well with lsp-mode.
(use-package company
  :ensure t
  :config
  ;; Optionally enable completion-as-you-type behavior.
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1))

(require-package 'go-guru)
(use-package go-guru
  :demand t)


;; icons and neotree
(require-package 'neotree)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))
(defun neotree-project-dir ()
  "Open NeoTree using the git root."
  (interactive)
  (let ((project-dir (projectile-project-root))
        (file-name (buffer-file-name)))
    (neotree-toggle)
    (if project-dir
        (if (neo-global--window-exists-p)
            (progn
              (neotree-dir project-dir)
              (neotree-find file-name)))
      (message "Could not find git project root."))))

;; typescript
(require-package 'tide)
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
(add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)


;; solidity-mode
(require-package 'solidity-mode)

(setq solidity-comment-style 'slash)

(setq solidity-solc-path "/snap/bin/solc")

(require-package 'solidity-flycheck)

(setq solidity-flycheck-solc-checker-active t)

(require-package 'company-solidity)

;;; plantuml
(setq org-plantuml-jar-path (expand-file-name "~/.emacs.d/plantuml.jar"))

(with-eval-after-load "org"
  (add-to-list 'org-src-lang-modes '("plantuml" . plantuml))
  (org-babel-do-load-languages 'org-babel-load-languages '((plantuml . t)))
  )

(provide 'init-local)
;;; init-local.el ends here
