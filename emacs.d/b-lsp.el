(provide 'b-lsp)

(when (>= emacs-major-version 27)
  (require 'package)
  (setq package-user-dir (concat (file-name-directory load-file-name)
                                 "melpa"))
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/")
               t)
  (package-initialize)
  (require 'lsp-mode)
  (require 'lsp-pyright)
  (setq lsp-completion-provider :none)
  (setq lsp-pyright-auto-import-completions
        nil)
  ;; disable bottom documentation popup
  (setq lsp-signature-auto-activate nil)
  (add-hook 'js-mode-hook #'lsp)
  (add-hook 'web-mode-hook #'lsp)
  (setq gc-cons-threshold 100000000)
  (setq read-process-output-max (* 1024 1024)))
