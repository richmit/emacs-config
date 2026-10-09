;; -*- Mode:emacs-lisp; lexical-binding: nil; Coding:us-ascii-unix; fill-column:158 -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;; @file      init.el--SS-X-X-X-X
;; @author    Mitch Richling <https://www.mitchr.me>
;; @brief     My Emacs dot file.@EOL
;; @std       Emacs Lisp unix windows osx
;; @copyright
;;  @parblock
;;  Copyright (c) 1989-2022, Mitchell Jay Richling <http://www.mitchr.me> All rights reserved.
;;
;;  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
;;
;;  1. Redistributions of source code must retain the above copyright notice, this list of conditions, and the following disclaimer.
;;
;;  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions, and the following disclaimer in the documentation
;;     and/or other materials provided with the distribution.
;;
;;  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software
;;     without specific prior written permission.
;;
;;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;;  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
;;  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;;  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;;  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
;;  DAMAGE.
;;  @endparblock
;; @warning   Very specific to my needs -- a bug for everyone else and a feature for me.@EOL@EOL
;; @warning   You will need to fix the stuff under "Manual-Meta-Config".@EOL@EOL
;; @filedetails
;;
;; Some fundamental bits of my Emacs configuration have been factored out into Emacs packages.  These may be found on github.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mjr-dotfile-message (fmt &rest rest)
  "Like `message', but only logs to *Messages* without dispalying anything and prefixes message with time stamp."
  (let ((inhibit-message 't))
    (apply #'message (concat (format-time-string "%Y-%m-%d_%H:%M:%S.%3N") ": .EMACS: " fmt) rest)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro mjr-time-it (&rest body)
  "Return value from last form of BODY, print `message' with runtime for BODY."
  `(let ((start-time (current-time))
         (return-val (progn ,@body))
         (complt-time (current-time)))
     (message "time-code: %0.5f sec for %s"
              (float-time (time-subtract complt-time start-time))
              (let ((tmp (format "%s" (quote ,@body))))
                (if (< 50 (length tmp))
                    (concat (substring tmp 0 50) "...")
                    tmp)))
     return-val))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Init file loading....")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'cl-lib)
(require 'dired)
(require 'dired-aux)
(require 'pcase)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Pre-Customizing Emacs (performance tweaks)....")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq gc-cons-threshold 50000000)
(add-hook 'emacs-startup-hook (lambda ()
                                (mjr-dotfile-message "HOOK: emacs-startup-hook")
                                (setq gc-cons-threshold 800000)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Manual-Meta-Config...")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Set to "auto-config" and the values will be set to a best guess, or hard-wire the value to something here.
(defvar mjr-richmit-mode "auto-config")
(defvar mjr-jrichli-mode "auto-config")
(defvar mjr-home         "auto-config")  ;; Home Directory
(defvar mjr-win-home     "auto-config")  ;; Windows Home Directory
(defvar mjr-dir-pbin     "auto-config")  ;; Personal bin directory
(defvar mjr-dir-core     "auto-config")  ;; Core directory

;; (setq mjr-jrichli-mode 't)
;; (setq mjr-richmit-mode nil)

(mjr-dotfile-message "Manual-Meta-Config: mjr-richmit-mode: %s" mjr-richmit-mode)
(mjr-dotfile-message "Manual-Meta-Config: mjr-jrichli-mode: %s" mjr-jrichli-mode)
(mjr-dotfile-message "Manual-Meta-Config: mjr-home:         %s" mjr-home)
(mjr-dotfile-message "Manual-Meta-Config: mjr-win-home:     %s" mjr-win-home)
(mjr-dotfile-message "Manual-Meta-Config: mjr-dir-pbin:     %s" mjr-dir-pbin)
(mjr-dotfile-message "Manual-Meta-Config: mjr-dir-core:     %s" mjr-dir-core)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Auto-Meta-Config...")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(cl-flet ((set-if-auto-config (var val) (when (string-equal (symbol-value var) "auto-config")
                                          (set var val))))
  (let ((urln (user-real-login-name))
        (kmn  '("richmit"))
        (kpn  '("jrichli" "swift")))

    ;; Set mjr-richmit-mode & mjr-jrichli-mode
    ;; If we have a recognized login-name, then auto-config
    (cond ((cl-find urln kmn :test #'string=) (progn (set-if-auto-config 'mjr-richmit-mode 't)
                                                     (set-if-auto-config 'mjr-jrichli-mode nil)))
          ((cl-find urln kpn :test #'string=) (progn (set-if-auto-config 'mjr-richmit-mode nil)
                                                     (set-if-auto-config 'mjr-jrichli-mode 't))))
    (set-if-auto-config 'mjr-richmit-mode nil)
    (set-if-auto-config 'mjr-jrichli-mode nil)

    ;; Set mjr-home
    ;; Use magical ~ path if possible.  Otherwise look in likely spots.
    (set-if-auto-config 'mjr-home (let ((tmp (expand-file-name "~")))
                                    (if (file-exists-p tmp)
                                        tmp
                                        (cl-find-if #'file-exists-p
                                                    (flatten-tree (mapcar (lambda (u) (mapcar (lambda (p) (file-name-concat p u))
                                                                                              '("/Users/" "/home/" "/u/")))
                                                                          (append kmn kpn)))))))

    ;; Set mjr-win-home
    (set-if-auto-config 'mjr-win-home (when (eq system-type 'windows-nt)
                                        (cl-find-if #'file-exists-p (mapcar (lambda (u) (expand-file-name (concat "C:/Users/" u))) (append kmn kpn)))))

    ;; Set mjr-dir-pbin & mjr-dir-core
    (when mjr-home
      (dolist (vvp '((mjr-dir-pbin . ("bin"  "" ))
                     (mjr-dir-core . ("core" "" ))))
        (let ((variable   (car vvp))
              (candidates (cdr vvp)))
          (dolist (candidate candidates)
            (let ((p (file-name-concat mjr-home candidate)))
              (when (file-exists-p p)
                (set-if-auto-config variable p)))))))

    ;; Report what we set
    (mjr-dotfile-message "Auto-Meta-Config: mjr-richmit-mode: %s" mjr-richmit-mode)
    (mjr-dotfile-message "Auto-Meta-Config: mjr-jrichli-mode: %s" mjr-jrichli-mode)
    (mjr-dotfile-message "Auto-Meta-Config: mjr-home:         %s" mjr-home)
    (mjr-dotfile-message "Auto-Meta-Config: mjr-win-home:     %s" mjr-win-home)
    (mjr-dotfile-message "Auto-Meta-Config: mjr-dir-pbin:     %s" mjr-dir-pbin)
    (mjr-dotfile-message "Auto-Meta-Config: mjr-dir-core:     %s" mjr-dir-core)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-install-mjr-packages")
(defun mjr-install-mjr-packages (action source &optional packages)
  "Install/upgrade my personal packages from github or the local filesystem.
 - ACTION is one of:
   - missing .... Install missing packages
   - reinstall .. Delete and install packages
   - report ..... Report on missing packages
   - delete ..... Delete packages
 - ACTION is one of:
   - github .. github repo
   - git ..... Local git repo"
  (interactive (let ((act-arg (intern (concat ":" (if (and (boundp 'ido-everywhere) ido-everywhere)
                                             (ido-completing-read "Action: " (list "missing" "report" "reinstall" "delete") nil t)
                                             (completing-read     "Action: " (list "missing" "report" "reinstall" "delete") nil t))))))
                 (list act-arg
                       (when (member act-arg '(:missing :reinstall))
                         (intern (concat ":" (if (and (boundp 'ido-everywhere) ido-everywhere)
                                                 (ido-completing-read "Source: " (list "github" "git" "file") nil t)
                                                 (completing-read     "Source: " (list "github" "git" "file") nil t))))))))
  (message "mjr-install-mjr-packages: Processing request")
  (let ((packages (if (listp packages) packages (list packages))))
    (cl-flet ((pkg-to-pkg-install-kw-list-or-file (pkg) (pcase source
                                                          (:github (list pkg :url (concat "https://github.com/richmit/" (symbol-name pkg))))
                                                          (:git    (let ((fn (expand-file-name (file-name-concat "~/MJR/world/my_prog/emacs/" (symbol-name pkg)))))
                                                                     (if (file-exists-p fn)
                                                                       (list pkg :url fn)
                                                                       (message "mjr-install-mjr-packages: Skip install of %s.  Repo missing." pkg))))
                                                          (_       (error "mjr-install-mjr-packages: Unsupported value for SOURCE: %s" source)))))
      (let* ((gbl-packages '(mrscpi-in-emacs
                             mjr-emacs-unloved
                             mjr-buffer-directory
                             mjr-apply-dired-magic
                             el-vergo
                             mjr-show-buffer
                             mjr-eval
                             mjr-numbers-in-column
                             mjr-preview
                             mjr-thingy-lookeruper
                             mjr-zotero
                             mjr-embedded-debug
                             mjr-flow
                             mjr-compile
                             mjr-code-tools))
             (loc-packages nil) ;; Packages not on git-hub
             (avl-packages (if (equal :git source)
                               (append gbl-packages loc-packages)
                               gbl-packages))
             (sel-packages (if packages
                               (cl-remove-if-not (lambda (x) (member x packages)) avl-packages)
                               avl-packages)))
        (pcase action
          (:report    (if-let* ((missing-packages (cl-remove-if #'package-installed-p sel-packages)))
                          (message "mjr-install-mjr-packages: Missing package: %s" pkg)
                        (message "mjr-install-mjr-packages: All requested packages are installed")))
          (:missing   (when-let* ((missing-packages (cl-remove-if #'package-installed-p sel-packages)))
                        (when (y-or-n-p (format "Install packages(%s)?" missing-packages))
                          (dolist (pkg missing-packages)
                            (message "mjr-install-mjr-packages: Install package: %s" pkg)
                            (package-vc-install (pkg-to-pkg-install-kw-list-or-file pkg))))))
          (:reinstall (dolist (pkg sel-packages)
                        (when-let* ((pkg-dsc (package-get-descriptor pkg)))
                          (message "mjr-install-mjr-packages: Delete package: %s" pkg)
                          (package-delete pkg-dsc 't))
                        (message "mjr-install-mjr-packages: Install package: %s" pkg)
                        (package-vc-install (pkg-to-pkg-install-kw-list-or-file pkg))))
          (:delete    (dolist (pkg (reverse sel-packages))
                        (when-let* ((pkg-dsc (package-get-descriptor pkg)))
                          (message "mjr-install-mjr-packages: Delete package: %s" pkg)
                          (package-delete pkg-dsc))))
          (_          (error "mjr-install-mjr-packages: Invalid value for action argument: %s" action)))))
    nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Early customize-set....")
(customize-set-variable 'el-vergo-bin (file-name-concat mjr-dir-pbin "verGo.sh"))  ;; Location for verGo.sh...

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Require....")
(require 'compile)
(require 'paren)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless mjr-jrichli-mode
  (mjr-dotfile-message "DEFUN: mjr-try-theme")
  (defun mjr-try-theme ()
    (if (not (load-theme 'manoj-dark 't))
        (message "mjr-try-theme: Failed to load manoj-dark!")
        (custom-set-faces  '(fixed-pitch                          ((t :inherit default)))
                           '(font-lock-bracket-face               ((t (:inherit fixed-pitch))))
                           '(font-lock-comment-delimiter-face     ((t (:foreground "Orange"))))
                           '(font-lock-comment-face               ((t (:foreground "Chocolate1" :italic n :slant normal))))
                           '(font-lock-delimiter-face             ((t (:inherit fixed-pitch))))
                           '(font-lock-doc-face                   ((t (:foreground "LightCoral" :italic n :slant normal))))
                           ;;'(font-lock-doc-string-face            ((t (:foreground "Plum"))))
                           ;;'(font-lock-doc-markup-face            ((t (:inherit font-lock-doc-string-face))))
                           '(font-lock-escape-face                ((t (:inherit fixed-pitch))))
                           '(font-lock-function-call-face         ((t (:inherit font-lock-function-name-face))))
                           '(font-lock-number-face                ((t (:inherit fixed-pitch))))
                           '(font-lock-operator-face              ((t (:inherit fixed-pitch))))
                           '(font-lock-preprocessor-face          ((t (:foreground "CornFlowerBlue" :italic n :slant normal))))
                           '(font-lock-property-name-face         ((t (:inherit fixed-pitch))))
                           '(font-lock-property-use-face          ((t (:inherit fixed-pitch))))
                           '(font-lock-punctuation-face           ((t (:inherit fixed-pitch))))
                           '(font-lock-reference-face             ((t (:foreground "LightSlateBlue" :bold t))))
                           '(font-lock-regexp-face                ((t (:foreground "red" :bold t :weight bold))))
                           '(font-lock-regexp-grouping-backslash  ((t (:inherit font-lock-regexp-face))))
                           '(font-lock-regexp-grouping-construct  ((t (:inherit font-lock-regexp-face))))
                           '(font-lock-string-face                ((t (:foreground "Salmon"))))
                           '(font-lock-variable-use-face          ((t (:inherit font-lock-variable-name-face))))
                           '(font-lock-warning-face               ((t (:foreground "Pink" :bold t :weight bold))))
                           '(hexl-address-region                  ((t (:inherit fixed-pitch :background "red" ))))
                           '(hexl-ascii-region                    ((t (:inherit fixed-pitch :background "blue" ))))
                           '(sh-heredoc         ((t (:foreground "Yellow3" :bold t :weight bold))))
                           '(sh-escaped-newline ((t (:foreground "black" :background "Khaki" :bold t :weight bold))))
                           '(sh-quoted-exec     ((t (:foreground "DarkOrchid1" :bold t :weight bold))))
                           '(link         ((t (:foreground "cyan1" :underline t :bold t :weight bold))))
                           '(link-visited ((t (:foreground "violet" :underline t :bold t :weight bold ))))
                           '(message-url ((t (:foreground "blue" :bold t :weight bold))))
                           '(org-meta-line             ((t (:foreground "peru" :inherit font-lock-comment-face))))
                           '(org-agenda-date-weekend   ((t (:foreground "LightSkyBlue" :bold t :weight bold))))
                           '(org-block-begin-line      ((t (:background "#151f3f" :inherit org-meta-line :extend t))))
                           '(org-block-end-line        ((t (:background "#151f3f" :inherit org-meta-line :extend t))))
                           '(org-document-info-keyword ((t (:inherit org-meta-line))))
                           '(org-column                ((t (:background "grey30" :slant normal :weight normal))))
                           '(org-column-title          ((t (:background "grey30" :bold t :weight bold :underline t))))
                           '(org-level-1               ((t (:foreground "LightSkyBlue" :bold 't :weight bold))))
                           '(org-level-2               ((t (:foreground "LightGoldenrod" :bold 't :weight bold))))
                           '(org-level-3               ((t (:foreground "Cyan1" :bold 't :weight bold))))
                           '(org-level-4               ((t (:foreground "chocolate1" :bold 't :weight bold))))
                           '(org-level-5               ((t (:foreground "PaleGreen" :bold 't :weight bold))))
                           '(org-level-6               ((t (:foreground "Aquamarine" :bold 't :weight bold))))
                           '(org-level-7               ((t (:foreground "LightSteelBlue" :bold 't :weight bold))))
                           '(org-level-8               ((t (:foreground "LightSalmon" :bold 't :weight bold))))
                           '(org-tag                   ((t (:bold t :weight bold))))
                           '(org-todo                  ((t (:foreground "Pink" :bold t :weight bold))))
                           '(org-warning               ((t (:foreground "Pink" :bold t :weight bold ))))
                           '(outline-1 ((t (:foreground "LightSkyBlue" :bold t :weight bold))))
                           '(outline-2 ((t (:foreground "LightGoldenrod" :bold t :weight bold))))
                           '(outline-3 ((t (:foreground "Cyan1" :bold t :weight bold))))
                           '(outline-4 ((t (:foreground "chocolate1" :bold t :weight bold))))
                           '(outline-5 ((t (:foreground "PaleGreen" :bold t :weight bold))))
                           '(outline-6 ((t (:foreground "Aquamarine" :bold t :weight bold))))
                           '(outline-7 ((t (:foreground "LightSteelBlue" :bold t :weight bold))))
                           '(outline-8 ((t (:foreground "LightSalmon" :bold t :weight bold))))
                           '(border ((t (:foreground "black" :background "gold"))))
                           '(buffer-menu-buffer ((t (:foreground "Gold" :bold t :weight bold))))
                           '(button ((t (:underline nil :foreground "ivory" :background "royal blue" :weight bold :box (:line-width 2 :color "cornflower blue" :style released-button)))))
                           '(slime-repl-prompt-face ((t (:inherit comint-highlight-prompt))))
                           '(slime-repl-input-face  ((t (:inherit comint-highlight-input))))
                           '(slime-repl-output-face ((t (:inherit font-lock-string-face))))
                           '(slime-repl-result-face ((t (:foreground "CadetBlue3"))))
                           '(cursor ((t (:background "red"))))
                           '(calendar-weekday-header ((t (:underline t :bold t :foreground "Purple"))))
                           '(calendar-month-header ((t (:underline t :bold t :foreground "limegreen"))))
                           '(ediff-current-diff-face-A     ((t (:foreground "firebrick" :background "pale green"))))
                           '(ediff-even-diff-face-Ancestor ((t (:foreground "Black" :background "Grey"))))
                           '(ediff-even-diff-face-B        ((t (:foreground "Black" :background "Grey"))))
                           '(ediff-odd-diff-face-A         ((t (:foreground "Black" :background "Grey"))))
                           '(ediff-odd-diff-face-C         ((t (:foreground "Black" :background "Grey"))))
                           '(eshell-ls-archive-face    ((t (:inherit default))))
                           '(eshell-ls-backup-face     ((t (:foreground "IndianRed"))))
                           '(eshell-ls-unreadable-face ((t (:inherit default))))
                           '(eshell-ls-clutter-face    ((t (:inherit default))))
                           '(eshell-ls-executable-face ((t (:foreground "green"))))
                           '(eshell-ls-missing-face    ((t (:background "red"))))
                           '(eshell-ls-picture-face    ((t (:inherit default))))
                           '(eshell-ls-product-face    ((t (:inherit default))))
                           '(eshell-ls-readonly-face   ((t (:inherit default))))
                           '(eshell-ls-directory       ((t (:foreground "SkyBlue" :bold t :weight bold))))
                           '(eshell-ls-symlink-face    ((t (:foreground "Cyan" :bold t :weight bold))))
                           '(eshell-prompt-face        ((t (:foreground "pink" :weight bold))))
                           '(mode-line           ((t (:foreground "Blue4" :background "grey80" :box nil))))
                           '(mode-line-active    ((t (:inherit mode-line))))
                           '(mode-line-inactive  ((t (:inherit mode-line :foreground "grey80" :background "grey20" :box nil))))
                           '(mode-line-buffer-id ((t (:inherit mode-line :foreground "Red1" :bold t :weight bold :box nil))))
                           '(mode-line-highlight ((t (:inherit mode-line :foreground "Red4" :box nil))))
                           '(mode-line-emphasis  ((t (:inherit mode-line :bold t :box nil))))
                           '(mode-line-highlight ((t (:inherit mode-line :bold t :box nil))))
                           '(dired-directory  ((t (:foreground "SkyBlue" :bold t :weight bold))))
                           '(dired-flagged    ((t (:foreground "Red" :bold t :weight bold))))
                           '(dired-header     ((t (:inherit font-lock-type-face))))
                           '(dired-ignored    ((t (:inherit shadow))))
                           '(dired-mark       ((t (:foreground "Purple" :bold t :weight bold))))
                           '(dired-marked     ((t (:foreground "Yellow" :bold t :weight bold))))
                           '(dired-perm-write ((t (:inherit font-lock-comment-delimiter-face))))
                           '(dired-symlink    ((t (:foreground "Cyan"))))
                           '(dired-warning    ((t (:foreground "White" :background "Red" :bold t :weight bold))))
                           '(info-title-1 ((t (:foreground "LightGoldenrod" :bold t :weight bold))))
                           '(info-title-2 ((t (:foreground "Cyan1" :bold t :weight bold))))
                           '(info-title-3 ((t (:foreground "chocolate1" :bold t :weight bold))))
                           '(info-title-4 ((t (:foreground "PaleGreen" :bold t :weight bold))))
                           '(info-header-node ((t (:foreground "LightSkyBlue" :bold t :weight bold))))
                           '(info-menu-star   ((t (:foreground "Red" :bold t :weight bold))))
                           '(info-menu-header ((t (:foreground "Red" :bold t :weight bold))))
                           '(ido-first-match ((t (:foreground "OliveDrab1" ))))
                           '(ido-only-match  ((t (:foreground "Green" :bold t :weight bold))))
                           '(woman-bold    ((t (:foreground "Gold" :bold t :weight bold))))
                           '(woman-italic  ((t (:foreground "LightBlue" :underline t))))
                           '(woman-unknown ((t (:foreground "Black" :background "Pink"))))
                           '(Man-overstrike ((t (:foreground "Gold" :bold t :weight bold))))
                           '(Man-underline  ((t (:foreground "LightBlue" :underline t))))
                           '(Man-reverse    ((t (:foreground "Black" :background "Pink"))))
                           '(widget ((t (:foreground "black" :background "Gray80"))))
                           '(header-line ((t (:box (:line-width -1 :color "grey20" :style released-button) :background "grey20" :foreground "grey90"))))
                           '(ibuffer-dired-buffer-face ((t (:foreground "mediumspringgreen" :weight bold))))
                           '(font-latex-sectioning-0-face ((t (:foreground "Gold" :bold t :weight bold))))
                           '(font-latex-sectioning-1-face ((t (:foreground "Gold" :bold t :weight bold))))
                           '(font-latex-sectioning-2-face ((t (:foreground "Gold" :bold t :weight bold))))
                           '(font-latex-sectioning-3-face ((t (:foreground "Gold" :bold t :weight bold))))
                           '(font-latex-sectioning-4-face ((t (:foreground "Gold" :bold t :weight bold))))
                           '(font-latex-sectioning-5-face ((t (:foreground "Gold" :bold t :weight bold))))
                           '(font-latex-slide-title-face ((t (:bold t :weight bold :inherit font-lock-type-face))))
                           '(display-time-mail-face ((t (:inherit mode-line-emphasis :foreground "Red"))))
                           '(linum ((t (:inherit (shadow default) :foreground "deep pink"))))
                           '(line-number ((t (:inherit (shadow default) :foreground "deep pink" :background "grey15"))))
                           '(line-number-current-line ((t (:inherit (shadow default) :foreground "deep pink" :background "grey10")))))))
  ;;; Setup theme upon startup
  (mjr-dotfile-message "PROGRESS: Apply theme")
  (mjr-try-theme))

;; Zap broken :inherit attribute
;; (let ((faces (face-list)))
;;   (dolist (face faces)
;;     (let ((inh (face-attribute face :inherit)))
;;       (unless (memq inh faces)
;;         (set-face-attribute face nil :inherit nil)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Autoloads for things in init file...")

(autoload 'thing-at-point-looking-at   "thingatpt"  "Return non-nil if point is in or just after a match for REGEXP." t)
(autoload 'thing-at-point              "thingatpt"  "Return string for thing at point."                               t)
(autoload 'image-mode-as-text          "image-mode" "Load image as text")
(autoload 'maxima-single-string-wait   "maxima"     "Send a string to maxima")
(autoload 'maxima-last-output-noprompt "maxima"     "Get last maxima result as a string")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: General defuns....")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-keymap-global-set-if-fbound")
(defun mjr-keymap-global-set-if-fbound (key symb)
  (when (fboundp symb)
    (keymap-global-set key symb)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-keymap-local-set-if-fbound")
(defun mjr-keymap-local-set-if-fbound (key symb)
  (when (fboundp symb)
    (keymap-local-set key symb)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-abbreviate-path")
(defun mjr-abbreviate-path (pathstring)
  "Try really hard to abbreviate a path for prompts."
  ;; Replace windows stuff with unix stuff
  (setq pathstring (string-replace           "\\"                                        "/"                   pathstring))
  (setq pathstring (replace-regexp-in-string "^c:/"                                      "/"                   pathstring))
  ;; Make sure pathstring ends with a /
  (unless (string-match-p "/$" pathstring)
    (setq pathstring (concat pathstring "/")))
  ;; Home directories
  (let ((un (cond (mjr-richmit-mode "richmit")
                  (mjr-jrichli-mode "jrichli")
                  (t                (user-real-login-name)))))
    (setq pathstring (replace-regexp-in-string (concat "^/msys64/home/" un "/")          "~/"                  pathstring))  ;; MSYS2 Home
    (setq pathstring (replace-regexp-in-string (concat "^/Users/" un "/")                "^/"                  pathstring))  ;; Windows Home
    (setq pathstring (replace-regexp-in-string (concat "^/home/" un "/")                 "~/"                  pathstring))) ;; UNIX/Linux/WSL Home
  ;; Windows directories
  (setq pathstring (replace-regexp-in-string "^~/winDocs/"                               "^/Documents/"        pathstring)) ;; Link
  (setq pathstring (replace-regexp-in-string "^~/winDown/"                               "^/Downloads/"        pathstring)) ;; Link
  (setq pathstring (replace-regexp-in-string "^~/winPics/"                               "^/Pictures/"         pathstring)) ;; Link
  (setq pathstring (replace-regexp-in-string "^~/winHome/"                               "^/"                  pathstring)) ;; Link
  ;; These all have links in the base of each home directory.  So think of them all as ~/.
  (setq pathstring (replace-regexp-in-string "^\\^/MJR/"                                 "~/MJR/"              pathstring))
  (setq pathstring (replace-regexp-in-string "^\\^/world/"                               "~/world/"            pathstring))
  (setq pathstring (replace-regexp-in-string "^\\^/core/"                                "~/core/"             pathstring))
  ;; Abreviate directoreis in world & core where I spend a lot of time
  (setq pathstring (replace-regexp-in-string "^~/MJR/world/"                             "~/world/"            pathstring))
  (setq pathstring (replace-regexp-in-string "^~/MJR/core/"                              "~/core/"             pathstring))
  ;; Deeper paths I frequent.
  (setq pathstring (replace-regexp-in-string "^~/world/my_prog/"                         "~~/my_prog/"         pathstring))
  (setq pathstring (replace-regexp-in-string "^~/world/dotfiles/"                        "~~/dotfiles/"        pathstring))
  (setq pathstring (replace-regexp-in-string "^~/core/codeBits/"                         "~~/codeBits/"        pathstring))
  (setq pathstring (replace-regexp-in-string "^~/MJR/WWW/"                               "~~/WWW/"             pathstring))
  (setq pathstring (replace-regexp-in-string "^~/WWW/site/SS/"                           "~~/WWW-SS/"          pathstring))
  pathstring)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mjr-dired-find-and-replace (from to use-strings-p use-folded-case-p)
  "Like dired-do-find-regexp-and-replace but with options for fixed strings (vs regexp) and fixed-case.
When using strings, you don't get the standard UI."
  (interactive (list nil nil (not (member (read-char-from-minibuffer "String or Regexp? (s/r): " '(82 114 83 115)) '(82 114))) (y-or-n-p "Folded case?") ))
  (let ((case-fold-search  use-folded-case-p)
        (search-upper-case use-folded-case-p))
    (if use-strings-p
        (let ((from_v (or from (read-string "Query replace in marked files: " )))
              (to_v   (or to   (read-string "Query replace in marked files a with: " ))))
          (dired-do-find-regexp-and-replace (regexp-quote from_v) (string-replace "\\" "\\\\" to_v)))
        (if (and from to)
            (dired-do-find-regexp-and-replace from to)
            (call-interactively #'dired-do-find-regexp-and-replace)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mjr-dired-find (searchthing use-strings-p use-folded-case-p)
  "Like dired-do-find-regexp but with options for fixed strings (vs regexp) and fixed-case."
  (interactive (list nil (not (member (read-char-from-minibuffer "String or Regexp? (s/r): " '(82 114 83 115)) '(82 114))) (y-or-n-p "Folded case?") ))
  (let ((case-fold-search  use-folded-case-p)
        (search-upper-case use-folded-case-p))
    (if use-strings-p
        (let ((searchthing (or searchthing (read-string "Search marked files (string): " ))))
          (dired-do-find-regexp (regexp-quote searchthing)))
        (if searchthing
            (dired-do-find-regexp searchthing)
            (call-interactively #'dired-do-find-regexp)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mjr-dired-insert-subdir (dir &optional buffer)
  "Insert DIR into dired buffer.
Unlike `dired-insert-subdir', prompt for a sub-directory when called interactively.  This allows deeply deeply nested sub-directories to be inserted.
When prompting for a directory and the point is on a directory line, the directory on the line will be the initial starting point for the query."
  (interactive (let* ((da-buf (if (eq major-mode 'dired-mode)
                                  (current-buffer)
                                  (let ((is-dired-mode (lambda (x)
                                                         (when-let* ((b (get-buffer (if (stringp x) x (car x)))))
                                                           (with-current-buffer b
                                                             (eq major-mode 'dired-mode))))))
                                    (get-buffer (if (and (boundp 'ido-everywhere) ido-everywhere)
                                                    (ido-read-buffer "Dired buffer: " nil 't is-dired-mode)
                                                    (read-buffer     "Dired buffer: " nil 't is-dired-mode))))))
                      (s-dir  (with-current-buffer da-buf
                                (or (when-let* ((point-dir (dired-get-filename nil t))
                                                (          (file-directory-p point-dir)))
                                      point-dir)
                                    (mjr-buffer-directory)))))
                 (list (if (and (boundp 'ido-everywhere) ido-everywhere)
                           (ido-read-directory-name "Subdirectory: " s-dir)
                           (read-directory-name     "Subdirectory: " s-dir))
                       da-buf)))
  (with-current-buffer buffer
    (unless (eq major-mode 'dired-mode)
      (error "mjr-dired-insert-subdir: Not in a dired buffer!"))
    (dired-insert-subdir dir)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mjr-dired-flag-latex-junk (&optional zap-extra-hard)
  "Flag LaTeX temp files/directories for deletion.
With prefix argument, also mark ps, html, dvi, and ps files.
Also see `mjr-dired-flag-junk' as well."
  (interactive "P")
  (unless (string-equal (symbol-name major-mode) "dired-mode")
    (error "mjr-dired-flag-latex-junk-files: Must be in dired-mode to use this function!"))
  (let* ((dired-marker-char dired-del-marker)
         (ext-to-zap        (append '("snm" "vrb" "nav" "tex~" "bak" "tex.bak" "lg" "idv" "aux" "toc" "log" "out" "hlog")
                                    (when zap-extra-hard '("html" "pdf" "dvi" "ps"))))
         (re-to-zap         (mapcar (lambda (ex) (concat "^.+\\." ex "$")) ext-to-zap)))
    (dired-mark-if (let ((fn (dired-get-filename t t)))
                     (when (and fn (file-exists-p fn))
                       (if (looking-at-p dired-re-dir)
                           (string-equal (file-name-nondirectory fn) "auto")
                           (and (file-exists-p (concat (file-name-base fn) ".tex"))
                                (cl-find-if (lambda (re) (string-match re fn)) re-to-zap)))))
                   "LaTeX temp file")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar mjr-dired-flag-junk '("^NUL$"
                              "/NUL$"       ;; Multi-director dired version of previous regexp
                              ".+~$"
                              ".+\\.bak$"
                              ".+\\.bak[0-9]$"
                              ".+\\.xvpics$"
                              "^#.+#$"
                              "/#[^/]+#$"   ;; Multi-director dired version of previous regexp
                              "^\\.#.+$"
                              "/\\.#[^/]+$" ;; Multi-director dired version of previous regexp
                              ))
(defun mjr-dired-flag-junk ()
  "Flag junk files for deletion.
Also see `mjr-dired-flag-latex-junk' as well."
  (interactive)
  (unless (string-equal (symbol-name major-mode) "dired-mode")
    (error "mjr-dired-flag-junk: Must be in dired-mode to use this function!"))
  (dired-mark-files-regexp (concat "\\(" (string-join mjr-dired-flag-junk "\\|") "\\)") dired-del-marker))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar mjr-dired-mark-code-extensions '("asm" "bat" "bas" "c" "cmake" "cpp" "hpp" "cxx" "hxx" "el" "elisp"
                                         "f03" "f08" "f90" "f95" "f77" "f" "go" "gplt" "sed" "h" "hh" "inc"
                                         "java" "js" "lisp" "m2" "make" "makefile" "mk" "mrscpi" "ninja"
                                         "org" "pas" "pl" "py" "pov" "r" "rb" "sh" "md"
                                         "jdebug" "jdebug.user" "s"
                                         "sql" "tex" "txt" "vbs" "vrml" "xml" "yaml"))
(defvar mjr-dired-mark-code-filenames '("makefile" "CMakeLists.txt" "CMakePresets.json" "ninja.build"))
(defun mjr-dired-mark-code ()
  "Mark (or unmark with prefix argument) source code."
  (interactive)
  (unless (string-equal (symbol-name major-mode) "dired-mode")
    (error "mjr-dired-mark-code: Must be in dired-mode to use this function!"))
  (dired-mark-files-regexp (concat "\\("
                                   ;; File extentions
                                   "\\("
                                   (regexp-opt (mapcar (lambda (x) (concat "." x)) mjr-dired-mark-code-extensions) t)
                                   "$\\)"
                                   "\\|"
                                   ;; Full file names
                                   "\\(^"
                                   (regexp-opt mjr-dired-mark-code-filenames 't)
                                   "$\\)"
                                   "$\\)")
                           (when current-prefix-arg ?\s)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mjr-dired-maybe-insert-marked ()
  "Insert all marked directories."
  (interactive)
  (when-let* ((marked-files (dired-get-marked-files)))
    (dolist (filen marked-files)
      (when (file-directory-p filen)
        (dired-maybe-insert-subdir filen)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless mjr-jrichli-mode
  (mjr-dotfile-message "DEFUN: mjr-init-check")
  (defun mjr-init-check ()
    "Run this before doing a `byte-compile-file' on init to avoid warnings about undefined stuff."
    (interactive)
    (require  'eshell)
    (require  'ibuffer)
    (require  'bookmark)
    (require  'cc-mode)
    (require  'em-term)
    (require  'em-hist)
    (require  'em-dirs)
    (require  'solar)
    (require  'ediff)
    (require  'slime)
    (require  'fortran)
    (require  'ispell)
    (require  'sh-script)
    (require  'org)
    (require  'imaxima)
    (require  'perl-mode)
    (require  'js)
    (require  'gnutls)
    (require  'cc-mode)
    (require  'tex-mode)
    (require  'sendmail)
    (require  'ffap)
    (require  'octave)
    (require  'net-utils)
    (require  'gud)
    (require  'gdb-mi)
    (require  'cmake-mode)
    (require  'server)
    (require  'ispell)
    (require  'vc)
    (require  'vc-dir)
    (require  'cc-mode)
    (when (get-buffer "*Compile-Log*")
      (kill-buffer "*Compile-Log*"))
    (let ((byte-compile-warnings t))
      (byte-compile-file (file-name-concat mjr-home "world/dotfiles/.emacs.d/init.el--SS-X-X-X-X")))
    (switch-to-buffer "*Compile-Log*")
    (delete-other-windows)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-query-replace-fixed-case")
(defun mjr-query-replace-fixed-case ()
  "Same as `query-replace', but with fixed case"
  (interactive)
  (let ((case-fold-search  nil)
        (search-upper-case nil))
    (call-interactively #'query-replace)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-query-replace-regexp-fixed-case")
(defun mjr-query-replace-regexp-fixed-case ()
  "Same as `query-replace-regexp', but with fixed case"
  (interactive)
  (let ((case-fold-search  nil)
        (search-upper-case nil))
    (call-interactively #'query-replace-regexp)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-occur-non-ascii")
(defun mjr-occur-non-ascii ()
  "Find non-ASCII characters in active buffer."
  (interactive)
  (occur "[^[:ascii:]]"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-github")
(defun mjr-github ()
  "Open up github in browser.
If the CWD is part of a github repo with a remote origin, then the repo page will be opened directly.  Otherwise it will just go to my profile page."
  (interactive)
  (browse-url (mjr-github-url)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-recentf-find-file")
(defun mjr-recentf-find-file (&optional use-recentf-buffer)
  "Load a recient file"
  (interactive "P")
  (if use-recentf-buffer
      (recentf-open-files)
      (when-let* ((file-list  (cl-remove-if-not (lambda (f) (and (file-exists-p f)
                                                                 (file-name-nondirectory f)))
                                                (cl-remove-duplicates recentf-list
                                                                      :test #'string=)))
                  (file-abrvs (cl-remove-duplicates (mapcar (lambda (f) (cons (mjr-abbreviate-path f) f)) file-list)
                                                    :test (lambda (x y) (string= (car x) (car y)))))
                  (file       (if (and (boundp 'ido-everywhere) ido-everywhere)
                                  (ido-completing-read "Recent file: " (mapcar #'car file-abrvs) nil t)
                                  (completing-read     "Recent file: " (mapcar #'car file-abrvs) nil t))))
        (find-file (cdr (assoc-string file file-abrvs))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (eq system-type 'windows-nt)
  (mjr-dotfile-message "PROGRESS: Setup fonts for windows")
  (defvar mjr-windows-display-dpi nil         "Display DPI at last run of mjr-windows-font-set")
  (defvar mjr-windows-font-family "Consolas"  "Font used by mjr-windows-font-set.  Good options: /Consolas/, /Courier New/, /Lucida Console/")
  (defvar mjr-windows-font-size   120         "Font size at last run of mjr-windows-font-set.  Initial value used last resort size.")
  (mjr-dotfile-message "DEFUN: mjr-windows-font-set")
  (defun mjr-windows-font-set (&optional new-size)
    "On Windows: This function will set the font size.
Without an argument, it will guess the correct size based on:
  * A list of recognized resolutions & display sizes (on windows the display size is the smaller of two mirrored displays)
  * Else if the function previously set the size & the dpi has changed, then scale by DPI delta
  * Else if the function has never been run, then just use the value set in mjr-windows-font-size"
    (interactive)
    (let* ((display-fingerprints '(("2400x1600x303x202"  . 155)  ;; Surface Pro Studio Laptop Full Resolution at 100% scale
                                   ("1920x1280x303x202"  . 124)  ;; Surface Pro Studio Laptop Full Resolution at 125% scale
                                   ("1600x1067x303x202"  . 108)  ;; Surface Pro Studio Laptop Full Resolution at 150% scale
                                   ("1371x914x303x202"   .  90)  ;; Surface Pro Studio Laptop Full Resolution at 175% scale
                                   ("1200x800x303x202"   .  78)  ;; Surface Pro Studio Laptop Full Resolution at 200% scale
                                   ("3840x2160x941x529"  . 110)  ;; Dell U4320Q (43 inch) Monitor
                                   ("3840x2160x303x170"  . 110)  ;; Dell U4320Q mirrored on Surface Pro Studio Laptop at 100% scale native windows
                                   ("3840x2160x1016x571" . 110)  ;; Dell U4320Q mirrored on Surface Pro Studio Laptop at 100% scale under WSL2
                                   ("3420x2280x260x173"  . 162)  ;; Surface Pro Tablet Full Resolution at 100% scale
                                   ("2736x1824x260x173"  . 136)  ;; Surface Pro Tablet Full Resolution at 125% scale
                                   ("2280x1520x260x173"  . 120)  ;; Surface Pro Tablet Full Resolution at 150% scale
                                   ("1954x1303x260x173"  . 110)  ;; Surface Pro Tablet Full Resolution at 175% scale
                                   ("1710x1140x260x173"  .  90)  ;; Surface Pro Tablet Full Resolution at 200% scale
                                   ))
           (display-fingerprint  (format "%dx%dx%dx%d" (display-pixel-width) (display-pixel-height) (display-mm-width) (display-mm-height)))
           (display-pref-fs      (cdr (assoc display-fingerprint display-fingerprints)))
           (now-dpi              (round (* 25.4 (/ (display-pixel-height) (display-mm-height)))))
           (dpi-changed-p        (and mjr-windows-display-dpi (< 0.01 (abs (- now-dpi mjr-windows-display-dpi)))))
           (dpi-adj              (if dpi-changed-p (/ (float now-dpi) mjr-windows-display-dpi) 1))
           (now-siz              (or new-size
                                     display-pref-fs
                                     (if (null mjr-windows-display-dpi)
                                         mjr-windows-font-size
                                         (round (* mjr-windows-font-size dpi-adj)))))
           (how-set              (cond (new-size                       "explicit size set")
                                       (display-pref-fs                "display recognized")
                                       (dpi-changed-p                  (format "display DPI changed from %d to %d" mjr-windows-display-dpi now-dpi))
                                       ((null mjr-windows-display-dpi) "wild guess at startup")
                                       (t                              "for no good reason at all"))))
      (set-face-attribute 'default nil :family mjr-windows-font-family :height now-siz)
      (setq mjr-windows-display-dpi now-dpi
            mjr-windows-font-size   now-siz)
      (message "mjr-windows-font-set: Windows font size set to %d because %s" now-siz how-set)))
  ;; Initial setup
  (mjr-windows-font-set)
  ;; Reset fonts when we go full screen
  (when (eq system-type 'windows-nt)
    (advice-add 'toggle-frame-fullscreen :before #'mjr-windows-font-set)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (eq system-type 'gnu/linux)
  (mjr-dotfile-message "PROGRESS: Setup fonts for linux")
  (if (and (file-exists-p "/proc/version")
           (with-temp-buffer
             (insert-file-contents "/proc/version")
             (goto-char (point-min))
             (search-forward "microsoft" nil t)))
      ;; On windows WSL we just set the font at startup.
      (cond ((find-font (font-spec :name "Hack"))                  (set-face-attribute 'default nil :font "Hack"                  :height 120))
            ((find-font (font-spec :name "Inconsolata"))           (set-face-attribute 'default nil :font "Inconsolata"           :height 128))
            ((find-font (font-spec :name "DejaVu Sans Mono Book")) (set-face-attribute 'default nil :font "DejaVu Sans Mono Book" :height 130)))
      ;; On generic linux...  This is a hack to work on RPI 4 running FHD at around 30 inches.
      (cond ((find-font (font-spec :name "Hack"))                  (set-face-attribute 'default nil :font "Hack"                  :height 100))
            ((find-font (font-spec :name "DejaVu Sans Mono Book")) (set-face-attribute 'default nil :font "DejaVu Sans Mono Book" :height 110))
            ((find-font (font-spec :name "Liberation Mono"))       (set-face-attribute 'default nil :font "Liberation Mono"       :height 100))
            ((find-font (font-spec :name "Inconsolata"))           (set-face-attribute 'default nil :font "Inconsolata"           :height 130)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-insert-char-ruler")
(defun mjr-insert-char-ruler (&optional rule-length)
  "Insert a ruler into the buffer.
Ruler marks:
  * # - 10 character marks
  * | - The fill-column
Interactive Prefix Argument:
  * NONE   - Set length to fill-column if it exists, otherwise window width
  * C-u    - Set length to window width
  * C-u #  - Use the *positive* prefix numeric argument as the width
  * M-#    - Same"
  (interactive (list (cond ((null current-prefix-arg)  (if (and (boundp 'fill-column) (integerp fill-column)) fill-column (window-width)))
                           ((listp current-prefix-arg) (window-width))
                           ('t                         (prefix-numeric-value current-prefix-arg)))))
  (let* ((tmp         (or rule-length (window-width)))
         (rule-length (if (= tmp (* 10 (/ tmp 10)))
                          tmp
                          (* 10 (+ 1 (/ tmp 10)))))
         (rule-mark   "#")
         (fill-mark   "|")
         (start-str   (if (and (boundp 'comment-start) comment-start)
                          (format "%s" comment-start)
                          "#"))
         (start-len   (length start-str))
         (end-str     (if (boundp  'comment-end)
                          (format "%s" comment-end)
                          ""))
         (rule-strs   (cl-loop for line from 1 upto 5
                               collect (with-output-to-string
                                         (cl-loop for i from 1 upto rule-length
                                                  for j = (mod i 10)
                                                  do (if (<= i start-len)
                                                         (when (= i 1)
                                                           (princ start-str))
                                                         (cl-case line
                                                           (1     (princ (if (zerop j) rule-mark " ")))
                                                           ((4 5) (princ (cond ((and (boundp 'fill-column) (integerp fill-column) (= i fill-column)) fill-mark)
                                                                               ((zerop j)                                                            rule-mark)
                                                                               (t                                                                    " "))))
                                                           (2     (cond ((= j 0) (princ rule-mark))
                                                                        ((< j 5) (princ " "))
                                                                        ((= j 5) (princ (format "%03d" (+ i 5))))
                                                                        ((> j 7) (princ " "))))
                                                           (3     (princ (format "%d" (mod i 10)))))))))))
    (if (equal major-mode 'eshell-mode)
        (apply #'concat (mapcar (lambda (x) (concat x "\n")) rule-strs))
        (progn (move-end-of-line 1)
               (newline)
               (dolist (str rule-strs)
                 (insert str)
                 (newline))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-ascii-table")
(defun mjr-ascii-table ()
  "Pop up a buffer with an ASCI table in it"
  (interactive)
  (let ((ascii-buffer (generate-new-buffer "*ascii-table*")))
    (with-current-buffer ascii-buffer
      (set-buffer-file-coding-system 'utf-8-unix)
      (erase-buffer)
      (cl-loop with cs = '("NUL" "SOH" "STX" "ETX" "EOT" "NEQ" "ACK" "BEL" "BS "
                           "HT " "LF " "VT " "NP " "CR " "SO " "SI " "DLE" "DC1"
                           "DC2" "DC3" "DC4" "NAK" "SYN" "ETB" "CAN" "EM " "SUB"
                           "ESC" "FS " "GS " "RS " "US " "SP")
               with i = 0
               for r from 0 upto (1- 16)
               do (cl-loop for c from 0 upto (1- 8)
                           do (setf i (+ r (* c 16)))
                           do (insert (format (if (< c 6) " |%3d %2x " " |%4d %2x ") i i))
                           do (cond ((< i 33)  (insert (elt cs i)))
                                    ((> i 126) (insert "DEL"))
                                    ((= c 2)   (progn (insert-char i) (insert " ")))
                                    ((> c 6)   (progn (insert-char i) (insert "  ")))
                                    ('t        (insert-char i))))
               do (insert " | \n"))
      (goto-char (point-min)))
    (switch-to-buffer ascii-buffer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-describe-region-or-char")
(defun mjr-describe-region-or-char ()
  "Provide info about region or char under point.

Intended to be bound to M-=.  When mark=point or no mar, call describe-char.  Otherwise call count-words-region."
  (interactive)
  (if (and (region-active-p) (not (= (point) (mark))))  ;; One char region is processed as no region
      (call-interactively #'count-words-region)
      (call-interactively #'describe-char)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-unfill")
(defun mjr-unfill ()
  "Unfill paragraph or region."
  (interactive "*")
  (let ((fill-column most-positive-fixnum))
    (fill-paragraph nil (region-active-p))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-date")
(defun mjr-date (&optional date-stamp-format date-to-use time-zone)
  "Insert the date at the point when called interactively

If called interactively a date/time stamp is inserted at the point using a format determined by the prefix argument:

  |-------------+---------------+-----------------------+---------+--------------------+------------------------------------------|
  | Numeric ARG | keys          | Date Format           | Zone    | Description        |                                          |
  |-------------+---------------+-----------------------+---------+--------------------+------------------------------------------|
  |          -5 | M-- 5   C-c d | %Y%m%d%H%M%S          | UTC     |                    | Frequently used for file names           |
  |          -4 | M-- 4   C-c d | %Y-%m-%dT%H:%M:%SZ    | UTC     | ISO 8601 date&time | sitemap, XML, SLQ (%z is +HHMM or -HHMM) |
  |          -3 | M-- 3   C-c d | %Y-%m-%d %H:%M:%S UTC | UTC     |                    |                                          |
  |          -2 | M-- 2   C-c d | %Y-%m-%d %H:%M:%S     | UTC     |                    |                                          |
  |          -1 | M-- 1   C-c d | %Y-%m-%d %H:%M        | UTC     |                    |                                          |
  |           0 | M-0           | %Y-%m-%d              | DEFAULT | Query for date     |                                          |
  |         nil | C-c d         | %Y-%m-%d              | DEFAULT | ISO 8601 date      |                                          |
  |           1 | M-1     C-c d | %Y-%m-%d %H:%M        | DEFAULT |                    |                                          |
  |           2 | M-2     C-c d | %Y-%m-%d %H:%M:%S     | DEFAULT |                    |                                          |
  |           3 | M-3     C-c d | %Y-%m-%d %H:%M:%S %z  | DEFAULT |                    |                                          |
  |           4 | C-u     C-c d | %Y-%m-%dT%H:%M:%S%z   | DEFAULT | ISO 8601 date&time | sitemap, XML, SLQ (%z is +HHMM or -HHMM) |
  |           5 | M-5     C-c d | %Y%m%d%H%M%S          | DEFAULT |                    | Frequently used for file names           |
  |           6 | M-5     C-c d | %s                    | DEFAULT | UNIX               | Seconds since 1970-01-01 00:00:00 Z      |
  |-------------+---------------+-----------------------+---------+--------------------+------------------------------------------|

When not called interactively, this function returns the time as a string."
  (interactive (let ((rpfx current-prefix-arg)
                     (npfx (prefix-numeric-value current-prefix-arg)))
                 (list (or (when rpfx
                             (cdr (assoc npfx
                                         '((-5 . "%Y%m%d%H%M%S")
                                           (-4 . "%Y-%m-%dT%H:%M:%S%z")
                                           (-3 . "%Y-%m-%d %H:%M:%S %z")
                                           (-2 . "%Y-%m-%d %H:%M:%S")
                                           (-1 . "%Y-%m-%d %H:%M")
                                           ( 0 . "%Y-%m-%d")
                                           ( 1 . "%Y-%m-%d %H:%M")
                                           ( 2 . "%Y-%m-%d %H:%M:%S")
                                           ( 3 . "%Y-%m-%d %H:%M:%S %z")
                                           ( 4 . "%Y-%m-%dT%H:%M:%S%z")
                                           ( 5 . "%Y%m%d%H%M%S")
                                           ( 6 . "%s")))))
                           "%Y-%m-%d")
                       (if (zerop npfx)
                           (let ((current-prefix-arg nil)) ;; Must protect org-read-date from prefix argument
                             (org-read-date 't 't))
                           (current-time))
                       (if (cl-minusp npfx)
                           "UTC"))))
  (let* ((dtu  (or date-to-use (current-time)))
         (dfm  (if (stringp date-stamp-format) date-stamp-format "%Y-%m-%dT%H:%M:%S%z"))
         (dstr (replace-regexp-in-string "+0000" "Z" (format-time-string dfm dtu time-zone) t t)))
    (if (called-interactively-p 'interactive)
        (insert dstr)
        dstr)))

;; Makes mjr-date work with delete-selection-mode
(put 'mjr-date 'delete-selection
     (lambda ()
       (not (run-hook-with-args-until-success
             'self-insert-uses-region-functions))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "DEFUN: mjr-rotate-replace")
(defun mjr-rotate-replace (rotate-list &optional match-what)
  "Parallel search and replace strings (name inspired by ROTATEF function).
ROTATE-LIST is a list of strings.  String n'th is replaced with n+1'th, with the final string being replaced by the first.
MATCH-WHAT argument determines what to match (word, symbol, and string).  NIL means string.
When run interactively MATCH-WHAT is set via the prefix arg: 1=>query, 4=>word, 16=>symbol, 32=>string
Operation is limited to region if a region is active."
  (interactive (list (let ((c 1)
                           (s nil))
                       (while (let ((in-str (read-string (format "Enter string or [enter] -- String(%d) : " c))))
                                (cl-incf c)
                                (unless (string-equal "" in-str)
                                  (push in-str s))))
                       (if (> (length s) 1)
                           s
                           (error "mjr-rotate-replace: Must provide at least two strings!!")))
                     (let* ((npfx (prefix-numeric-value current-prefix-arg)))
                       (cond ((>= npfx  32) "string")
                             ((>= npfx  16) "symbol")
                             ((>= npfx   4) "word")
                             ((>= npfx   1) (if (and (boundp 'ido-everywhere) ido-everywhere)
                                                (ido-completing-read "Match Type: "                           '("word" "symbol" "string") nil 't)
                                                (completing-read     "Match Type (word, symbol, or string): " '("word" "symbol" "string") nil 't "word")))))))
  (unless (listp rotate-list)
    (error "mjr-rotate-replace: rotate-list argument must be a list!!!"))
  (when (cl-some (lambda (x) (not (stringp x))) rotate-list)
    (error "mjr-rotate-replace: rotate-list argument must be a list of strings!!!"))
  (let ((rl-len (length rotate-list)))
    (when (< rl-len 2)
      (error "mjr-rotate-replace: rotate-list argument must contain at least two strings!!!"))
    (let ((paren (when match-what
                   (if (not (stringp match-what))
                       (error "mjr-rotate-replace: match-what argument must be NIL or a string!!!")
                       (let ((n (cl-position match-what '("word" "symbol" "string") :test #'string-equal)))
                         (if (not n)
                             (error "mjr-rotate-replace: match-what argument is a string, but not valid (word, symbol, string)!!!")
                             (elt (list 'words 'symbols nil) n)))))))
      (save-excursion
        (let* ((reg-min  (if (and (mark) (or (null transient-mark-mode) (region-active-p)))
                             (region-beginning)
                             (point)))
               (reg-max  (if (and (mark) (or (null transient-mark-mode) (region-active-p)))
                             (region-end)
                             (point-max))))
          (goto-char reg-min)
          (while (re-search-forward (regexp-opt rotate-list paren) reg-max 't)
            (replace-match (elt rotate-list (mod (1+ (cl-position (match-string-no-properties 0) rotate-list :test #'string-equal)) rl-len)))))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Generic Global Emacs Config Stuff...")

(when mjr-jrichli-mode
  ;; scroll one line at a time
  (setq scroll-step 1))
(when mjr-jrichli-mode
  ;; Don't scroll jump when you hit edges of the window
  (setq scroll-conservatively 10000))
(if mjr-jrichli-mode
    ;; Don't wrap long lines.
    (setq-default truncate-lines nil)
    ;; Wrap long lines.
    (setq-default truncate-lines 'true))

;; Don't do stupid stuff on enter
(electric-indent-mode -1)
;; Make the buffer name column width wider (default is 19)
(setq Buffer-menu-name-width 40)
;; No popups
(setq use-dialog-box nil)
;; Turn on S-arrows for window selection
(windmove-default-keybindings)
;; kill stuff in a read only buffer
(setq kill-read-only-ok t)
;; Want local variables to work;;
(setq enable-local-eval t)
;; No startup message
(setq inhibit-startup-message t)
;; No message in echo area
(setq inhibit-startup-echo-area-message "MJR")
;; No message in *scratch* buffer
(setq initial-scratch-message nil)
;; Make apros Work hard.
(setq apropos-do-all t)
;; Want the region to be highlighted
(setq transient-mark-mode 'true)
;; Make mouse select, clipboard, and yank buffer sane
(setq select-active-regions   'only)
;; Non-nil -> cut/paste uses primary selection (os depend ant)
(if mjr-jrichli-mode
    (setq select-enable-primary nil)
    (setq select-enable-primary 't))
;; Highlight the search strings
(setq search-highlight t)
;; Highlight query replace
(setq query-replace-highlight t)
;; Want quite errors
(setq visible-bell t)
;; Tab must be 4 spaces.
(setq-default tab-width 4)
;; Insert spaces instead of tabs
(setq-default indent-tabs-mode nil)
;; Give up on an autosave after 5 sec
(setq auto-save-timeout 5)
;; Always put a final newline in a file
(setq require-final-newline t)
;; Don't ask when we revert-buffer
(setq revert-without-query '(".*"))
;; Keep the compilation window from growing on large displays
(setq compilation-window-height 12)
;; Ask before save
(setq compilation-ask-about-save t)
;; Let us have minibuffers within minibufers
(unless mjr-jrichli-mode
  (setq enable-recursive-minibuffers t))
;; Show matching parens
(show-paren-mode 1)
;; Put file size in mode line
(size-indication-mode)
;; Title the frame so the window manager can find Emacs correctly
(setq frame-title-format "GNU Emacs: %b")
;; Turn off menus, tool bars, and scroll bars
(if (not mjr-jrichli-mode) (menu-bar-mode -1)   (menu-bar-mode 1)  )
(if (not mjr-jrichli-mode) (tool-bar-mode -1)   (tool-bar-mode 1)  )
(when (boundp #'scroll-bar-mode)
  (if (not mjr-jrichli-mode) (scroll-bar-mode -1) (scroll-bar-mode 1)))
;; Novice override stuff.  Allow these commands.
(unless mjr-jrichli-mode
  (put 'eval-expression  'disabled nil)
  (not mjr-jrichli-mode) (put 'upcase-region    'disabled nil)
  (not mjr-jrichli-mode) (put 'downcase-region  'disabled nil)
  (not mjr-jrichli-mode) (put 'narrow-to-region 'disabled nil))
;; Set the colors
;; (set-background-color "white")
;; (set-foreground-color "black")
;; (set-cursor-color "red")
;; (set-border-color "black")
;; (set-mouse-color "black")
;; Set up default window selection keys (S-arrows)
;; Global font lock mode
(global-font-lock-mode 1)
;; Do *not* automatically save abbrev files
(setq save-abbrevs nil)
;; Make buffer pull down menu list all buffers
(setq buffers-menu-max-size nil)
;; Set the mark ring size
(setq mark-ring-max 64)
;; Only split vertically
(setq split-width-threshold nil)
;; Keep SQL buffers in the current window
(add-to-list 'same-window-buffer-names "*SQL*")
;; Setup various handy auto-mode-alist items
(add-to-list 'auto-mode-alist '("\\.m$"                     . octave-mode))         ;; Octave-mode with .m
(add-to-list 'auto-mode-alist '("\\.sql.m4$"                . sql-mode))            ;; SQL with m4
(add-to-list 'auto-mode-alist '("\\.txt.m4$"                . text-mode))           ;; Text with m4
(add-to-list 'auto-mode-alist '("\\.elisp$"                 . emacs-lisp-mode))     ;; Emacs lisp code
(add-to-list 'auto-mode-alist '("\\.clisp$"                 . lisp-mode))           ;; SLIME-lisp-mode
(add-to-list 'auto-mode-alist '("\\.[fF]95$"                . f90-mode))            ;; Use f90 mode with fortran 1995
(add-to-list 'auto-mode-alist '("\\.[fF]0[38]$"             . f90-mode))            ;; Use f90 mode with fortran 2003 and 2008
(add-to-list 'auto-mode-alist '("\\.[mM][oO][dD]$"          . f90-mode))            ;; Use f90 mode with fortran modules
(add-to-list 'auto-mode-alist '("\\.[fF]200[38]$"           . f90-mode))            ;; Use f90 mode with fortran 2003 and 2008
(add-to-list 'auto-mode-alist '("\\.[fF]77$"                . fortran-mode))        ;; Use fortran mode for f77
(add-to-list 'auto-mode-alist '("\\.[fF][oO][rR]$"          . fortran-mode))        ;; Use fortran mode for f77
(add-to-list 'auto-mode-alist '("^/tmp/pico\\.[0-9][0-9]*$" . mail-mode))           ;; alpine tmp files -- use mail-mode
(add-to-list 'auto-mode-alist '("tmp/mutt/\\.*mutt"         . mail-mode))           ;; mutt tmp files -- use mail-mode
(add-to-list 'auto-mode-alist '("\\.svg$"                   . image-mode-as-text))  ;; Prevent SVG rendering on load
(add-to-list 'auto-mode-alist '("\\.vt[up]"                 . xml-mode))            ;; VTK polydata & unstructured-grid are XML
(add-to-list 'auto-mode-alist '("\\.gdb$"                   . gdb-script-mode))     ;; GDB script files

;; Fringe on the right only
(when (boundp #'fringe-mode)
  (fringe-mode '(0 . 8)))
;; prettify-symbols in prog-mode.el
;; (setq prettify-symbols-unprettify-at-point 't)
;; (global-prettify-symbols-mode t)
(when (eq system-type 'windows-nt)
  (when-let* ((shell-path (cl-find-if #'file-exists-p (list "c:/msys64/usr/bin/bash.exe"))))
    (setq shell-file-name          shell-path)
    (setq explicit-shell-file-name shell-path)
    (setq explicit-bash.exe-args '("--noediting" "--login" "-i"))))
;; In *scratch* buffers, print everything
(setq eval-expression-print-length nil
      eval-expression-print-level  nil)
;; Set the modeline
(setq-default eol-mnemonic-unix "/LF ")
(setq-default eol-mnemonic-dos  "/CRLF ")
(setq-default eol-mnemonic-mac  "/CR ")
(setq-default mode-line-format
              '((:eval (let* ((core-ml-string (format-mode-line '("%e "
                                                                  mode-line-mule-info
                                                                  mode-line-client
                                                                  mode-line-modified
                                                                  mode-line-remote
                                                                  " "
                                                                  (:eval (if (mode-line-window-selected-p)
                                                                             (propertize (buffer-name) 'face '(:foreground "red1" :background "grey80"))
                                                                             (propertize (buffer-name) 'face '(:foreground "pink" :background "grey20"))))
                                                                  "   "
                                                                  "%p/%I L:%l C:%c"
                                                                  " P:"
                                                                  (:eval (format "%d" (point)))
                                                                  " "
                                                                  (:eval (propertize (if (boundp 'vc-mode)
                                                                                         (if vc-mode
                                                                                             vc-mode
                                                                                             (propertize "!VC" 'help-echo "No version control detected" ))
                                                                                         (propertize "VC?" 'help-echo "ERROR: Unable to detect version control"))
                                                                                     'face (list :foreground (if (mode-line-window-selected-p) "blue" "lightseagreen"))))
                                                                  "  "
                                                                  mode-line-modes)))
                              (date-string    (format-time-string " %Y-%m-%d %H:%M " (current-time)))
                              (space-left     (- (window-total-width) (string-width core-ml-string) (string-width date-string))))
                         (if (> space-left 3)
                             (concat core-ml-string (make-string (- space-left 1) ?-) date-string)
                             core-ml-string)))
                "%-"))
;; Always ask to quit
(setq confirm-kill-emacs #'yes-or-no-p)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: net-utils")
(with-eval-after-load "net-utils"
  (mjr-dotfile-message "POST-INIT: EVAL-AFTER: net-utils")
  (when-let* ((tmp (cl-find-if (lambda (x) (locate-file x exec-path (list ".exe" ""))) (list "nslookup" "host" "dig"))))
    (setq dns-lookup-program tmp)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: ffap")
(autoload 'ffap-guess-file-name-at-point "ffap" "Try to get a file name at point."                                    t)
(autoload 'ffap-url-p                    "ffap" "If STRING looks like an URL, return it (maybe improved), else nil."  t)
(autoload 'ffap                          "ffap" "Find FILENAME, guessing a default from text around point."           t)
(autoload 'ffap-copy-string-as-kill      "ffap" "Call function ffap-string-at-point, and copy result to kill-ring."   t)
(with-eval-after-load "ffap"
  (mjr-dotfile-message "POST-INIT: EVAL-AFTER: ffap")
  (setq ffap-url-regexp "\\(zotero:\\|mailto:\\|file:\\|ftp\\|http\\|https://\\)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (eq system-type 'windows-nt)
  (mjr-dotfile-message "PKG SETUP: man on windows.")
  (with-eval-after-load "man"
    (mjr-dotfile-message "EVAL-AFTER: man")
    ;; First the MANPATH needs to be set before man:
    (advice-add 'man :before (lambda (MAN-ARGS) (setenv "MANPATH" "/usr/share/man:/mingw64/share/man")))
    ;; Second, the result from Man-shell-file-name needs to be something like /msys64/usr/bin/bash instead of /bin/sh.
    (advice-add 'Man-shell-file-name :override (lambda () "/msys64/usr/bin/bash"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: elisp-mode")
(with-eval-after-load "elisp-mode"
  (mjr-dotfile-message "EVAL-AFTER: elisp-mode")
  (setq emacs-lisp-docstring-fill-column 't))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: ediff")
(with-eval-after-load "ediff-init"
  (mjr-dotfile-message "EVAL-AFTER: ediff")
  ;; No frame for control buffer
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  ;; split window horizontally for diff
  (setq ediff-split-window-function 'split-window-horizontally)
  ;; split window vertically for merge
  (setq ediff-merge-split-window-function 'split-window-vertically)
  ;; Make foreground faces white or black
  (set-face-foreground ediff-current-diff-face-A           "White")
  (set-face-foreground ediff-current-diff-face-Ancestor    "White")
  (set-face-foreground ediff-current-diff-face-B           "White")
  (set-face-foreground ediff-current-diff-face-C           "White")
  (set-face-foreground ediff-fine-diff-face-A              "White")
  (set-face-foreground ediff-fine-diff-face-Ancestor       "White")
  (set-face-foreground ediff-fine-diff-face-B              "White")
  (set-face-foreground ediff-fine-diff-face-C              "White")
  (set-face-foreground ediff-even-diff-face-A              "Black")
  (set-face-foreground ediff-even-diff-face-Ancestor       "Black")
  (set-face-foreground ediff-even-diff-face-B              "Black")
  (set-face-foreground ediff-even-diff-face-C              "Black")
  (set-face-foreground ediff-odd-diff-face-A               "Black")
  (set-face-foreground ediff-odd-diff-face-Ancestor        "Black")
  (set-face-foreground ediff-odd-diff-face-B               "Black")
  (set-face-foreground ediff-odd-diff-face-C               "Black"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: vc")
;; Use ediff for = binding
(with-eval-after-load "vc-hooks"
  (mjr-dotfile-message "EVAL-AFTER: vc")
  (keymap-set vc-prefix-map "=" 'vc-ediff)
  ;; No confirmation for C-x v v and C-x v i, and C-x v u
  (setq vc-suppress-confirm 't)
  ;; Create messages for VC command output
  (setq vc-command-messages 't)
  ;; Create messages for VC command output
  (setq ediff-keep-variants nil)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: vc-dir")
;; Use ediff for = binding
(with-eval-after-load "vc-dir"
  (mjr-dotfile-message "EVAL-AFTER: vc-dir")
  (keymap-set vc-dir-mode-map "=" 'vc-ediff)
  (keymap-set vc-dir-mode-map "s" 'mjr-github))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: rmail")
(with-eval-after-load "rmail"
  (mjr-dotfile-message "EVAL-AFTER: rmail!")
  (let ((sepath (cl-find-if #'file-exists-p '("/Users/Shared/mail/"))))
    (when sepath
      (setq rmail-secondary-file-directory sepath)))
  (setq rmail-secondary-file-regexp "\\."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: browse-url")
;; Need this if we support %B in mjr-thingy-lookeruper
;;(autoload 'browse-url-encode-url "browse-url" "Escape annoying characters in URL that will confuse a web browser." t)
(with-eval-after-load "browse-url"
  (mjr-dotfile-message "EVAL-AFTER: browse-url!")
  ;; Use firefox
  (setq browse-url-handlers
        (list (cons "hyperspec"                  #'eww-browse-url)
              (cons "/SS/exampleCode/ruby"       #'eww-browse-url)
              (cons "/SS/exampleCode/AUPG"       #'eww-browse-url)
              (cons "/SS/exampleCode/blas"       #'eww-browse-url)
              (cons "/SS/exampleCode/boost"      #'eww-browse-url)
              (cons "/SS/exampleCode/cfitsio"    #'eww-browse-url)
              (cons "/SS/exampleCode/cpp"        #'eww-browse-url)
              (cons "/SS/exampleCode/curl"       #'eww-browse-url)
              (cons "/SS/exampleCode/DB"         #'eww-browse-url)
              (cons "/SS/exampleCode/F77"        #'eww-browse-url)
              (cons "/SS/exampleCode/fltk"       #'eww-browse-url)
              (cons "/SS/exampleCode/Fortran"    #'eww-browse-url)
              (cons "/SS/exampleCode/glut"       #'eww-browse-url)
              (cons "/SS/exampleCode/GMP"        #'eww-browse-url)
              (cons "/SS/exampleCode/GSL"        #'eww-browse-url)
              (cons "/SS/exampleCode/HDF5"       #'eww-browse-url)
              (cons "/SS/exampleCode/mpi"        #'eww-browse-url)
              (cons "/SS/exampleCode/NetCDF"     #'eww-browse-url)
              (cons "/SS/exampleCode/openssl"    #'eww-browse-url)
              (cons "/SS/exampleCode/postscript" #'eww-browse-url)
              (cons "/SS/exampleCode/R"          #'eww-browse-url)
              (cons "/SS/exampleCode/random"     #'eww-browse-url)
              (cons "/SS/exampleCode/ruby"       #'eww-browse-url)
              (cons "/SS/exampleCode/sqlite"     #'eww-browse-url)
              (cons "/SS/exampleCode/vtk"        #'eww-browse-url)
              (cons "."                          (if (eq system-type 'windows-nt)
                                                     #'browse-url-default-browser
                                                     #'browse-url-firefox))))
  ;; Put stuff in a new window
  (setq browse-url-new-window-flag 't)
  ;; Really don't put things in new tabs!!
  (setq browse-url-firefox-new-window-is-tab nil)
  ;;Set the browser appropriately
  (unless (eq system-type 'windows-nt)
    (when (file-exists-p (file-name-concat mjr-dir-pbin "browser"))
      (setq browse-url-firefox-program (file-name-concat mjr-dir-pbin "browser")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: epa-file")
(with-eval-after-load "epa-file"
  (mjr-dotfile-message "EVAL-AFTER: epa-file!")
  (when (eq system-type 'windows-nt)
    (when-let* ((gpgpath (cl-find-if (lambda (p) (and (stringp p) (file-exists-p p)))
                                     (list (when mjr-win-home (file-name-concat mjr-win-home "/AppData/Local/GnuPG/bin"))
                                           "C:/PROGRA~2/GnuPG/bin"
                                           "C:/PROGRA~1/GnuPG/bin"
                                           "C:/msys64/usr/bin"))))
      (customize-set-variable 'epg-gpg-program (file-name-concat gpgpath "/gpg.exe"))
      (when (string-match "PROGRA" gpgpath)
        (mjr-dotfile-message "EVAL-AFTER: epa-file: Update path for GPG!")
        (setenv "PATH" (file-name-concat gpgpath ":" (getenv "PATH")))
        (setq exec-path (append (list gpgpath) exec-path))))))
(require 'epa-file nil :noerror)
(with-eval-after-load "epg"
  (mjr-dotfile-message "EVAL-AFTER: epg!")
  (when (eq system-type 'windows-nt)
    (when-let* ((gpgpath (cl-find-if (lambda (p) (and (stringp p) (file-exists-p p)))
                                     (list (when mjr-win-home (file-name-concat mjr-win-home "/AppData/Local/GnuPG/bin"))
                                           "C:/PROGRA~2/GnuPG/bin"
                                           "C:/PROGRA~1/GnuPG/bin"
                                           "C:/msys64/usr/bin"))))
      (customize-set-variable 'epg-gpg-program (file-name-concat gpgpath "/gpg.exe")))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (require 'time nil :noerror)
  (mjr-dotfile-message "PKG SETUP: time")
  ;; Put time and date in mode line
  (setq display-time-mail-string "") ;; Get rid of mail indicator in mode line
  (setq display-time-day-and-date 't)
  (setq display-time-format "%Y-%m-%d %I:%M%p")
  (display-time)
  ;; Configure the cities I like for (world-clock )
  (setq world-clock-list '(("America/Los_Angeles"  "Los Angeles")
                           ("America/Denver"       "Denver")
                           ("America/Chicago"      "Dallas")
                           ("America/New_York"     "New York")
                           ("Europe/London"        "London")
                           ("Europe/Paris"         "Paris")
                           ("Asia/Dubai"           "Dubai")
                           ("Asia/Calcutta"        "Bangalore")
                           ("Asia/Tokyo"           "Tokyo"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: server")
(with-eval-after-load "server"
  (mjr-dotfile-message "EVAL-AFTER: server")
  ;; Set a default name for the server each emacs instance will create
  (setq server-name (format "mjr-emacs-server-%d" (emacs-pid))))
(autoload 'server-running-p "server" "Test whether server NAME is running." t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless mjr-jrichli-mode
  (mjr-dotfile-message "PKG SETUP: global-display-line-numbers-mode")
  (customize-set-variable  'global-display-line-numbers-mode nil)
  (customize-set-variable  'display-line-numbers-widen       't)
  (dolist (m '(ess-mode-hook
               text-mode-hook
               pov-mode-hook
               prog-mode-hook))
    (add-hook m (lambda ()
                  (mjr-dotfile-message "HOOK: +display-line-numbers-mode(%s)" major-mode)
                  (display-line-numbers-mode 1))))
  (dolist (m '(lisp-interaction-mode-hook))
    (add-hook m (lambda ()
                  (mjr-dotfile-message "HOOK: -display-line-numbers-mode(%s)" major-mode)
                  (display-line-numbers-mode -1)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: cmake")
(autoload 'cmake-mode "cmake-mode" "CMake mode" t)
(with-eval-after-load "cmake-mode"
  (mjr-dotfile-message "EVAL-AFTER: cmake!")
  (add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-mode))
  (add-to-list 'auto-mode-alist '("CMakeLists.txt\\'" . cmake-mode))
  (keymap-set cmake-mode-map "C-c C-c" 'mjr-compile))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: dired")
(with-eval-after-load "dired"
  (mjr-dotfile-message "EVAL-AFTER: dired!")
  (add-hook 'dired-mode-hook
            (lambda ()
              (mjr-dotfile-message "HOOK: diredc-mode-hook")
              (mjr-keymap-local-set-if-fbound "ESC Q"  'mjr-dired-find-and-replace)
              (mjr-keymap-local-set-if-fbound "ESC A"  'mjr-dired-find)
              (mjr-keymap-local-set-if-fbound "C-c j"  'mjr-dired-flag-junk)
              (mjr-keymap-local-set-if-fbound "I"      'mjr-dired-maybe-insert-marked)
              (mjr-keymap-local-set-if-fbound "ESC i"  'mjr-dired-insert-subdir)
              (when (boundp 'ido-enable-replace-completing-read)
                (setq ido-enable-replace-completing-read nil))))  ;; If ido is loaded, make sure we don't use it in dired
  (keymap-set dired-mode-map "<mouse-3>" (lambda (event)
                                           (interactive "e" dired-mode)
                                           (dired-mouse-find-file event 'dired-maybe-insert-subdir 'dired-maybe-insert-subdir)))
  (keymap-set dired-mode-map "<mouse-2>" 'dired-mouse-find-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: sh-mode")
(with-eval-after-load "sh-script"
  (mjr-dotfile-message "EVAL-AFTER: sh-script!")
  (add-hook 'sh-mode-hook (lambda ()
                            (mjr-dotfile-message "HOOK: sh-mode-hook")
                            (setq sh-basic-offset 2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: image")
(with-eval-after-load "image"
  (mjr-dotfile-message "EVAL-AFTER: image!")
  (keymap-set image-map "q" (lambda () (interactive) (kill-buffer nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: term/ansi-term")
(with-eval-after-load "term"
  (mjr-dotfile-message "EVAL-AFTER: term!")
  ;; Note eshell-destroy-buffer-when-process-dies set to non-NIL will kill term sessions when over, but we want more.  What we do here is pause before
  ;; we destroy a term buffer if it has existed for 1 second or less.
  (advice-add 'term-handle-exit :after (lambda (&rest rest) (let ((dt buffer-display-time)
                                                                  (ct (current-time)))
                                                              (when (or (null dt) (and (= (cl-first ct) (cl-first dt))
                                                                                       (<= (abs (- (cl-second ct) (cl-second dt))) 1)))
                                                                (read-char "Press any key to exit terminal buffer."))
                                                              (kill-buffer)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: eshell")
(with-eval-after-load "em-term"
  (mjr-dotfile-message "EVAL-AFTER: em-term!")
  (unless (eq system-type 'windows-nt)
    (mapc (lambda (i) (add-to-list 'eshell-visual-commands i)) '("t" "tn" "td" "tnn" "stmux" "stmux.sh"
                                                                 "hexDump.rb" "hexDump"
                                                                 "byteAnalysis.rb" "byteAnalysis"
                                                                 "getSecret.sh" "getSecret"
                                                                 "hlflt.rb" "hlflt"
                                                                 "logTail.rb" "logTail"))
    (mapcar (lambda (i) (add-to-list 'eshell-visual-subcommands i)) '(("git" "help" "log" "l" "ll" "d" "diff" "show")))))

(with-eval-after-load "esh-mode"
  (mjr-dotfile-message "EVAL-AFTER: esh-mode!")
  (defun mjr-eshell-insert-last-word (n)
    (interactive "p")
    (insert (car (reverse (split-string (eshell-previous-input-string (- n 1)))))))
  ;; apply to each-type functions
  (defun mjr-eshell-apply (args error-label minimum-arg-count maximum-arg-count func-action func-validate)
    "Apply a LISP function to arguments from an eshell/*-type function"
    (let* ((exp-args   (mapcar (lambda (x) (expand-file-name (format "%s" x))) (flatten-tree args)))
           (arg-count  (length exp-args)))
      (cond ((> minimum-arg-count arg-count) (format "ERROR: %s: Not enough arguments!" error-label))
            ((< maximum-arg-count arg-count) (format "ERROR: %s: Too many arguments!" error-label))
            ('t                              (progn (if exp-args
                                                        (let ((tmp (cl-find-if-not func-validate exp-args)))
                                                          (if tmp
                                                              (format "ERROR: %s: Invalid argument: %S" error-label tmp)
                                                              (progn (mapc func-action exp-args)
                                                                     nil)))
                                                        (progn (funcall func-action nil)
                                                               nil)))))))
  (defun eshell/emacs    (&rest args) (mjr-eshell-apply args "eshell/emacs"   1 5 #'find-file                                                #'file-exists-p))
  (defun eshell/em       (&rest args) (mjr-eshell-apply args "eshell/em"      1 5 #'find-file                                                #'file-exists-p))
  (defun eshell/vi       (&rest args) (mjr-eshell-apply args "eshell/vi"      1 5 #'find-file                                                #'file-exists-p))
  (defun eshell/vim      (&rest args) (mjr-eshell-apply args "eshell/vim"     1 5 #'find-file                                                #'file-exists-p))
  (defun eshell/edit     (&rest args) (mjr-eshell-apply args "eshell/edit"    1 5 #'find-file                                                #'file-exists-p))
  (defun eshell/less     (&rest args) (mjr-eshell-apply args "eshell/less"    1 5 #'view-file                                                #'file-exists-p))
  (defun eshell/more     (&rest args) (mjr-eshell-apply args "eshell/more"    1 5 #'view-file                                                #'file-exists-p))
  (defun eshell/view     (&rest args) (mjr-eshell-apply args "eshell/view"    1 5 #'view-file                                                #'file-exists-p))
  (defun eshell/dired    (&rest args) (mjr-eshell-apply args "eshell/dired"   0 1 (lambda (f) (dired (or f (mjr-buffer-directory))))         #'file-directory-p))
  (defun eshell/vc-ediff (&rest args) (mjr-eshell-apply args "eshell/vcediff" 1 1 (lambda (f) (find-file f) (call-interactively #'vc-ediff)) #'file-exists-p))
  ;; Aliases
  (defalias 'eshell/lsc 'eshell/ls)
  (defalias 'eshell/c   'eshell/compile)
  ;; Other functions
  (defun eshell/cdrd ()
    "Change directory into the git root or CMake root for this directory"
    (let* ((buf-dir (mjr-buffer-directory))
           (rot-dir (or (locate-dominating-file buf-dir ".git")
                        (locate-dominating-file buf-dir "CMakeLists.txt"))))
      (unless rot-dir
        (error "eshell/cdrd: Couldn't figure out project root dir"))
      (eshell/cd rot-dir)))
  (defun eshell/clear (&rest args)
    "Run `erase-buffer' on eshell buffer."
    (let ((inhibit-read-only t))
      (erase-buffer)
      (eshell-send-input)))
  ;; Settings
  (setq eshell-scroll-to-bottom-on-input 'this)
  (setq eshell-cmpl-cycle-completions nil)
  (setq eshell-history-size 1048576)
  (setq eshell-history-append 't)
  ;; Hook
  (add-hook 'eshell-mode-hook
            (function (lambda ()
                        (mjr-dotfile-message "HOOK: eshell-mode-hook")
                        ;;(mjr-try-theme)  ;; Duno why, but eshell needs to have the theme reapplied after it starts...
                        (setq pcomplete-cycle-completions nil)
                        (keymap-set eshell-hist-mode-map "<up>"             'previous-line)
                        (keymap-set eshell-hist-mode-map "<down>"           'next-line)
                        (keymap-set eshell-mode-map      "<mouse-2>"        (lambda ()
                                                                              "Paste at the end of the buffer -- i.e. end of current command line."
                                                                              (interactive)
                                                                              (goto-char (point-max)) (yank)))
                        (keymap-set eshell-mode-map      "M-."              'mjr-eshell-insert-last-word)
                        (keymap-set eshell-mode-map      "C-c M-o"          (lambda ()
                                                                              "Clear all contents of eshell buffer"
                                                                              (interactive)
                                                                              (let ((inhibit-read-only t))
                                                                                (erase-buffer)
                                                                                (eshell-send-input))))
                        (keymap-set eshell-mode-map      "C-p"            'eshell-previous-input)
                        (keymap-set eshell-mode-map      "C-n"            'eshell-next-input)
                        (keymap-set eshell-mode-map      "C-c s"          (lambda (pfx)
                                                                            "If inside eshell and called with no prefix, then bring up menu of other eshells to switch to..."
                                                                            (interactive "P")
                                                                            (if pfx
                                                                                (mjr-eshell pfx)
                                                                                (mjr-eshell (list 4)))))
                        (keymap-set eshell-mode-map      "C-<return>"     (lambda ()
                                                                            "Insert a space and the active region or ffap-string-at-point at the end of the eshell prompt."
                                                                            (interactive)
                                                                            (if (use-region-p)
                                                                                (kill-ring-save 0 0 't)
                                                                                (ffap-copy-string-as-kill))
                                                                            (goto-char (point-max))
                                                                            (insert " " (car kill-ring))))
                        (keymap-set eshell-mode-map      "ESC C-<return>" (lambda ()
                                                                            "Insert a space and the active region or ffap-string-at-point at the end of the eshell prompt and then evaluate command line."
                                                                            (interactive)
                                                                            (if (use-region-p)
                                                                                (kill-ring-save 0 0 't)
                                                                                (ffap-copy-string-as-kill))
                                                                            (goto-char (point-max))
                                                                            (insert " " (car kill-ring))
                                                                            (eshell-send-input)))
                        (keymap-set eshell-mode-map      "<mouse-3>"      (lambda (e)
                                                                            "Insert a space and the active region or ffap-string-at-point at the end of the eshell prompt."
                                                                            (interactive "e")
                                                                            (let* ((da-tgt (nth 5 (car (cdr e))))
                                                                                   (da-str (if (and (region-active-p) (<= (region-beginning) da-tgt) (>= (region-end) da-tgt))
                                                                                               (buffer-substring-no-properties (region-beginning) (region-end))
                                                                                               (progn (goto-char da-tgt)
                                                                                                      (ffap-string-at-point "file")))))
                                                                              (when (and da-str (stringp da-str))
                                                                                (goto-char (point-max))
                                                                                (insert " " da-str)
                                                                                (goto-char da-tgt)
                                                                                (message "Inserted: '%s'" da-str)))))
                        (unless (server-running-p)
                          (server-start))
                        (when (eq system-type 'windows-nt)
                          (setenv "GIT_PAGER" "cat"))
                        (setenv "PAGER" "cat")
                        (setenv "EDITOR" (format "emacsclient -f %s" server-name)))))
  ;; Prompt
  (defun mjr-custom-eshell-prompt ()
    (concat (mjr-abbreviate-path (eshell/pwd)) " $ "))
  (setq eshell-prompt-function 'mjr-custom-eshell-prompt))
;; shebang fix for windows.
(if (eq system-type 'windows-nt)
    (with-eval-after-load "esh-ext"
      (mjr-dotfile-message "EVAL-AFTER: esh-ext!")
      (defun mjr-eshell-shebang-fixer (eshell-script-interpreter-result)
        "Magically fix shebang lines that reference a missing executable by looking really hard to find one that will work."
          (if (or (null eshell-script-interpreter-result) (not (listp eshell-script-interpreter-result)))
              eshell-script-interpreter-result
              (let ((bang1 (car eshell-script-interpreter-result)))
                (if (or (not (stringp bang1)) (file-exists-p bang1))
                    eshell-script-interpreter-result
                    (let* ((bang1-exe        (concat bang1 ".exe"))
                           (bang1-com        (concat bang1 ".com"))
                           (intrpf           (file-name-nondirectory bang1))
                           (intrpf-exe       (concat intrpf ".exe"))
                           (intrpf-com       (concat intrpf ".com"))
                           (on-windows       (eq system-type 'windows-nt))
                           (likely-path-win  '("c:/msys64/usr/local/bin/" "c:/msys64/ucrt64/bin/" "c:/msys64/mingw64/bin/" "c:/msys64/mingw32/bin/" "c:/msys64/usr/bin/"))
                           (likely-path-unix '("/bin/" "/usr/bin/" "/usr/local/bin/"))
                           (bang1-improved   (if on-windows
                                                 (or (locate-file intrpf-exe likely-path-win)   ;; On windows -- Look for .EXE version of file in coninical paths
                                                     (locate-file intrpf     likely-path-win)   ;; On windows -- Look for given file in coninical paths
                                                     (locate-file intrpf-com likely-path-win)   ;; On windows -- Look for .COM version of file in coninical paths
                                                     (executable-find intrpf)                   ;; On windows -- look in $PATH
                                                     (if (file-exists-p bang1-exe) bang1-exe)   ;; On windows -- See if it exists if we just add .EXE
                                                     (if (file-exists-p bang1-com) bang1-com))  ;; On windows -- See if it exists if we just add .COM
                                                 (or (locate-file intrpf likely-path-unix)      ;; Not on windows -- look in coninical paths
                                                     (executable-find intrpf)))))               ;; Not on windows -- look in $PATH
                      (if bang1-improved
                          (progn (message "mjr-eshell-shebang-fixer: Changed shebang '%s' to '%s'" bang1 bang1-improved)
                                 (cons bang1-improved (cdr eshell-script-interpreter-result)))
                          (progn (message "mjr-eshell-shebang-fixer: Could not fix shebang '%s'" bang1)
                                 eshell-script-interpreter-result)))))))
      (advice-add 'eshell-script-interpreter :filter-return #'mjr-eshell-shebang-fixer)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: mail-mode setup...")
(with-eval-after-load "sendmail"
  (mjr-dotfile-message "EVAL-AFTER: mail-mode!")
  (setq compose-mail-user-agent-warnings nil)
  (add-hook 'mail-mode-hook
            (lambda ()
              (mjr-dotfile-message "HOOK: mail-mode-hook(1)")
              (when (string-equal (substring (buffer-name) 0 5) "mutt-")
                (let ((da-frames (frame-list)))
                  (mail-to)
                  ;;(flyspell-mode)
                  (dolist (da-frame da-frames)
                    (set-frame-position da-frame 1 1)
                    (set-frame-size     da-frame 150 64))))))
  (defface message-even-quoted-text-face
    '((((class color) (min-colors 88) (background light))    :foreground "magenta")
      (((class color) (min-colors 88) (background dark))     :foreground "magenta")
      (((class color) (min-colors 16) (background light))    :foreground "magenta")
      (((class color) (min-colors 16) (background dark))     :foreground "magenta")
      (((class color) (min-colors 8))                        :foreground "magenta")
      (t :inverse-video t))
    "Face for quoted messages at even level"
    :group 'basic-faces)
  (defface message-odd-quoted-text-face
    '((((class color) (min-colors 88) (background light))    :foreground "red")
      (((class color) (min-colors 88) (background dark))     :foreground "red")
      (((class color) (min-colors 16) (background light))    :foreground "red")
      (((class color) (min-colors 16) (background dark))     :foreground "red")
      (((class color) (min-colors 8))                        :foreground "red")
      (t :inverse-video t))
    "Face for quoted messages at odd level"
    :group 'basic-faces)
  (add-hook 'mail-mode-hook
            (lambda ()
              (mjr-dotfile-message "HOOK: mail-mode-hook (2)")
              (font-lock-add-keywords nil
                                      '(("^[ \t]*>[^>\n].*$"          (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>$"                  (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>[^>\n].*$"         (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>$"                 (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>>[^>\n].*$"        (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>>$"                (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>>>[^>\n].*$"       (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>>>$"               (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>>>>[^>\n].*$"      (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>>>>$"              (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>>>>>[^>\n].*$"     (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>>>>>$"             (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>>>>>>[^>\n].*$"    (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>>>>>>$"            (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>>>>>>>[^>\n].*$"   (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>>>>>>>$"           (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>>>>>>>>[^>\n].*$"  (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>>>>>>>>$"          (0 'message-odd-quoted-text-face))
                                        ("^[ \t]*>>>>>>>>>>[^>\n].*$" (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>>>>>>>>>>$"         (0 'message-even-quoted-text-face))
                                        ("^[ \t]*>.*$"                (0 'message-odd-quoted-text-face)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless mjr-jrichli-mode
  (mjr-dotfile-message "PKG SETUP: ESS")  ;; NOTE: We use INFERIOR-R-PROGRAM-NAME for org-mode setup
  (with-eval-after-load "ess-site"
    (mjr-dotfile-message "EVAL-AFTER: ess!")
    (customize-set-variable  'ess-use-flymake nil)
    (customize-set-variable  'ess-fancy-comments nil)
    (customize-set-variable  'ess-history-file nil)
    (setq ess-handy-commands '(("set-width"        . ess-execute-screen-options)
                               ("rdired"           . ess-rdired)
                               ("change-directory" . ess-change-directory)
                               ("help-apropos"     . ess-display-help-apropos)
                               ("help-index"       . ess-display-package-index)
                               ("help-object"      . ess-display-help-on-object)
                               ("search"           . ess-execute-search)
                               ("vignettes"        . ess-display-vignettes)))
    (keymap-set ess-mode-map "_" #'self-insert-command)
    (let ((r-path (el-vergo-car "R" 'DOS)))
      (when r-path
        (setq inferior-ess-r-program r-path)))
    (setq ess-style 'OWN)
    (add-hook 'ess-mode-hook
              (lambda ()
                (mjr-dotfile-message "HOOK: ess-mode-hook")
                (ess-set-style 'OWN)
                (setq ess-indent-offset 2)
                (setq ess-indent-with-fancy-comments nil)
                ))
    (add-hook 'inferior-ess-mode-hook
              (lambda ()
                (mjr-dotfile-message "HOOK: inferior-ess-mode-hook")
                (ess-set-style 'OWN)
                (setq ess-indent-offset 2)
                (setq ess-indent-with-fancy-comments nil))))
  (defun mjr-R ()
    "Fire up an interactive R session -- works hard to get correct working directory"
    (interactive)
    (let ((ess-startup-directory (or (mjr-buffer-directory) default-directory)))
      (call-interactively 'R)))
  (require 'ess-site nil 't))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: octave")
(with-eval-after-load "octave"
  (mjr-dotfile-message "EVAL-AFTER: octave!")
  (setq inferior-octave-startup-args '("-i" "--no-gui"))
  (let ((oct-path (el-vergo-car "octave" 'MIX)))
    (when oct-path
      (setq inferior-octave-program oct-path)))
  (add-hook 'octave-mode-hook
            (lambda () (progn (setq octave-comment-char ?%)
                              (setq comment-start "% ")
                              (setq comment-add 0)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless mjr-jrichli-mode
  (mjr-dotfile-message "PKG SETUP: org-mode setup...")
  (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))  ;; Make sure *.org files use org-mode
  (with-eval-after-load "org"
    (mjr-dotfile-message "EVAL-AFTER: org-mode!")

    (setq org-replace-disputed-keys t)  ;; Don't override S-<arrow> keys

    (unless (require 'htmlize nil :noerror)
      (mjr-dotfile-message "EVAL-AFTER: PKG SETUP: WARNING: Could not load package htmlize in init."))

    (org-babel-do-load-languages 'org-babel-load-languages
                                 (append '(  (awk        . t)
                                             (C          . t)
                                             (css        . t)
                                             (dot        . t)
                                             (emacs-lisp . t)
                                             (eshell     . t)
                                             (eval       . t)
                                             (fortran    . t)
                                             (gnuplot    . t)
                                             (java       . t)
                                             (js         . t)
                                             (julia      . t)
                                             (latex      . t)
                                             (lisp       . t)
                                             (maxima     . t)
                                             (octave     . t)
                                             (perl       . t)
                                             (python     . t)
                                             (R          . t)
                                             (ruby       . t)
                                             (shell      . t)
                                             (calc       . t)
                                             (sql        . t)
                                             (sqlite     . t))
                                         (when (require 'mrscpi-in-emacs nil t)
                                           '((mrscpi     . t)))))

    (defun mjr-org-babel-execute-src-block ()
      "Wrap org-babel-execute-src-block"
      (interactive)
      (let ((org-confirm-babel-evaluate nil))
        (funcall-interactively #'org-babel-execute-maybe)))  ;; Not org-babel-execute-src-block))) so we can evaluate #+CALL: statements too

    (defun mjr-org-babel-execute-subtree ()
      "Wrap org-babel-execute-subtree"
      (interactive)
      (let ((org-confirm-babel-evaluate nil))
        (funcall-interactively #'org-babel-execute-subtree)))

    (defun mjr-org-babel-execute-buffer ()
      "Wrap org-babel-execute-buffer"
      (interactive)
      (let ((org-confirm-babel-evaluate nil))
        (funcall-interactively #'org-babel-execute-buffer)))

    ;; ob-octave runs the octave/matlab process inside a shell.  The command line is in org-babel-octave-shell-command.  It's default is 'octave -1'.  I
    ;; have octave in my bin directory linked to verGo.sh.  In general this works.
    ;; (setq org-babel-octave-shell-command "/msys64/ucrt64/bin/octave.exe -q")

    (setq org-adapt-indentation nil)                          ;; Don't indent by heading level
    (setq org-edit-src-content-indentation 0)                 ;; Don't add a fixed indent inside blocks
    (setq org-src-fontify-natively t)                         ;; Pretty colors
    (setq org-src-tab-acts-natively t)                        ;; tab as in source mode
    (setq org-log-done 'time)                                 ;; Log timestamps on done TODO items
    (setq org-link-descriptive nil)                           ;; Don't do fancy link rendering -- just show the text
    (setq org-startup-indented nil)                           ;; Do Not Indent stuff
    (setq org-startup-folded nil)                             ;; Start with cn-folded view
    (setq org-export-with-sub-superscripts nil)               ;; "_" and "^" are not special
    (setq org-confirm-babel-evaluate 't)                      ;; Ask about evals
    ;;etq org-export-use-babel nil)                           ;; Do NOT eval OR PROCESS HEADER ARGUMENTS on export
    (setq org-html-viewport  '((width "1024")                 ;; Nix the viewport stuff for moble
                               (initial-scale "1")
                               (minimum-scale "")
                               (maximum-scale "")
                               (user-scalable "")))
    (setq org-log-into-drawer "LOGBOOK")                      ;; Put TODO changes and notes in LOGBOOK drawer
    (setq org-agenda-files
          (let* ((tdp (file-name-concat mjr-home "/TODO/")))
            (when (file-directory-p tdp)
              (directory-files tdp 't "\.org$"))))      ;; My generic TODO file
    (setq org-babel-min-lines-for-block-output 0)             ;; Always put babel results in blocks
    (add-hook 'org-mode-hook                                  ;; Get my favorite keys back
              (lambda ()
                (mjr-dotfile-message "HOOK: org-mode-hook")
                (turn-on-font-lock)
                (keymap-local-set "C-c C-v C-b" 'mjr-org-babel-execute-buffer)    ;; use "C-c C-v b" to eval with confirmation prompts
                (keymap-local-set "C-c C-v C-s" 'mjr-org-babel-execute-subtree)   ;; use "C-c C-v s" to eval with confirmation prompts
                (keymap-local-set "C-c C-v C-e" 'mjr-org-babel-execute-src-block) ;; use "C-c C-v e" to eval with confirmation prompts
                ;; Get rid of archive keybindings -- accidentally archiving things is a PITA.
                (keymap-local-unset "C-c $")
                (keymap-local-unset "C-c C-<tab>")
                (keymap-local-unset "C-c C-x C-a")
                (keymap-local-unset "C-c C-x C-s")
                (keymap-local-unset "C-c C-x A")
                (keymap-local-unset "C-c C-x a")
                ))
    ;; Need to set the R path on Windows...
    (if (and (eq system-type 'windows-nt) (boundp 'inferior-R-program-name) inferior-R-program-name)
        (setq org-babel-R-command (concat "'" inferior-R-program-name "' --slave --no-save"))
        (mjr-dotfile-message "EVAL-AFTER: PKG SETUP: ERROR: Could not find R.exe binary for babel in org-mode on Windows"))
    ;; Need to set the julia path on Windows...
    (if (eq system-type 'windows-nt)
        (let ((julia-path (el-vergo-car "julia" 'MIX)))
          (if julia-path
              (setq org-babel-julia-command julia-path)
              (mjr-dotfile-message "EVAL-AFTER: PKG SETUP: ERROR: Could not set org-babel-julia-command in org-mode on Windows"))))
    ;; Need to set the maxima path on Windows...
    (if (eq system-type 'windows-nt)
        (let ((max-path (el-vergo-car "maxima" 'MIX)))
          (if max-path
              (setq org-babel-maxima-command max-path)
              (mjr-dotfile-message "EVAL-AFTER: PKG SETUP: ERROR: Could not find maxima.bat batch file for babel in org-mode on Windows"))))
    ;; Handy export function
    (defun mjr-org-export-der (execute-blocks tangle-blocks export-html export-pdf)
      "Evaluate all code blocks, export to HTML, and tangle current file or all marked files in dired-mode."
      (interactive (if (null current-prefix-arg)
                       (list (y-or-n-p "Evaluate all blocks?")
                             (y-or-n-p "Tangle all blocks?")
                             (y-or-n-p "Export to HTML?")
                             (y-or-n-p "Export to PDF via LaTeX?"))
                       (list 't 't 't 't)))
      (mjr-apply-dired-magic (lambda ()
                                    (when execute-blocks (mjr-org-babel-execute-buffer))
                                    (when tangle-blocks  (org-babel-tangle))
                                    (when export-html    (org-html-export-to-html))
                                    (when export-pdf     (org-latex-export-to-pdf)))))
    ;; Look for org-html-preamble content from the first file found: 1) Look for "org-html-preamble.html" in the $PWD, 2)Look up to 6 levels up the $PWD
    ;; for files named "gbl/org/org-html-preamble_N.html" where N is the depth up the tree - Ex: "../gbl/org/org-html-preamble_1.html",
    ;; "../../gbl/org/org-html-preamble_2.html", etc...  3) Look for mjr-dir-core/core/org-mode/org-html-postamble.html. 4) If no files are found, then
    ;; set preamble to the empty string.
    (setq org-html-preamble (lambda (an-arg) (let* ((basic-fname "org-html-preamble.html")
                                                    (fname-pots  (append (list basic-fname)
                                                                         (cl-loop for idx from 1 upto 6
                                                                                  for fname = (apply #'file-name-concat (append (cl-loop repeat idx
                                                                                                                                         collect "..")
                                                                                                                                (list "gbl"
                                                                                                                                      "org"
                                                                                                                                      (format (string-replace ".html" "_%d.html" basic-fname) idx))))
                                                                                  collect fname)
                                                                         (list (file-name-concat mjr-dir-core "org-mode" basic-fname))))
                                                    (best-fname (cl-find-if #'file-exists-p fname-pots)))
                                               (if best-fname
                                                   (progn (mjr-dotfile-message "EVAL-AFTER: org-mode HTML export using file: %s" best-fname)
                                                          (org-file-contents best-fname))
                                                   ""))))
    ;; Look for org-html-postamble content -- see org-html-preamble above.  One diffrence is the default when no file is found.
    (setq org-html-postamble (lambda (an-arg) (let* ((basic-fname "org-html-postamble.html")
                                                     (fname-pots  (append (list basic-fname)
                                                                          (cl-loop for idx from 1 upto 6
                                                                                   for fname = (apply #'file-name-concat (append (cl-loop repeat idx
                                                                                                                                          collect "..")
                                                                                                                                 (list "gbl"
                                                                                                                                       "org"
                                                                                                                                       (format (string-replace ".html" "_%d.html" basic-fname) idx))))
                                                                                   collect fname)
                                                                          (list (file-name-concat mjr-dir-core "org-mode" basic-fname))))
                                                     (best-fname (cl-find-if #'file-exists-p fname-pots)))
                                                (if best-fname
                                                    (progn (mjr-dotfile-message "EVAL-AFTER: org-mode HTML export using file: %s" best-fname)
                                                           (org-file-contents best-fname))
                                                    "Created by %a <%e>.  Rendered on %T via %c"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: calendar (solar stuff)")
(with-eval-after-load "solar"
  (mjr-dotfile-message "EVAL-AFTER: solar!")
  (calendar-set-date-style 'iso)
  (setq calendar-location-name "Austin, TX")
  (setq calendar-latitude 30.266666)
  (setq calendar-longitude -97.733330))
(with-eval-after-load "cal-dst"
  (mjr-dotfile-message "EVAL-AFTER: cal-dst!")
  (setq calendar-time-zone -360)
  (setq calendar-standard-time-zone-name "CST")
  (setq calendar-daylight-time-zone-name "CDT"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: GUD & GDB setup...")
(with-eval-after-load "gud"
  (mjr-dotfile-message "EVAL-AFTER: gud!"))
(with-eval-after-load "gdb-mi"
  (mjr-dotfile-message "EVAL-AFTER: gdb-mi!"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: aspell setup...")
(with-eval-after-load "ispell"
  (mjr-dotfile-message "EVAL-AFTER: ispell!")
  (let ((aspell-path (cl-find-if #'file-exists-p
                                 (list "c:/msys64/ucrt64/bin/aspell.exe"
                                       "c:/msys64/mingw64/bin/aspell.exe"
                                       "/usr/bin/hunspell"
                                       "/bin/hunspell"
                                       "/usr/local/bin/aspell"
                                       "/opt/local/bin/aspell"
                                       "/bin/aspell"
                                       "/usr/bin/aspell"))))
    (if aspell-path
        (setq-default ispell-program-name aspell-path)
        (setq-default ispell-program-name "ispell"))
    (defun mjr-ispell-accept (start end)
      "Add all the words in the current region to the accepted words list for the local buffer"
      (interactive (if (region-active-p)
                       (list (region-beginning)
                             (region-end))
                       (list (point-min)
                             (point-max))))
      (save-excursion
        (goto-char start)
        (cl-loop with num-added = 0
                 for num-checked from 1
                 for cwok = (ispell-correct-p 't)
                 for cwst = (car (ispell-get-word 't))
                 if (not cwok)
                 do (progn (cl-incf num-added)
                           (cl-pushnew cwst
                                       ispell-buffer-session-localwords
                                       :test #'equal))
                 finally (message "mjr-ispell-accept: Added %d words of %d checked" num-added num-checked)
                 until (>= (point) end))))))
(autoload 'mjr-ispell-accept "ispell" "Add all the words in the current region to the accepted words list for the local buffer" t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: emacs-lisp-mode setup...")
;; Don't indent the third argument if the if form differently...
(put 'if 'lisp-indent-function nil)
(add-hook 'emacs-lisp-mode-hook
          (function (lambda ()
                      (mjr-dotfile-message "HOOK: emacs-lisp-mode-hook")
                      (keymap-local-set "C-c C-c" 'byte-recompile-directory)
                      (keymap-local-set "C-c C-b" 'byte-compile-file))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: c-mode setup...")
(add-hook 'c-initialization-hook
          (lambda ()
            (mjr-dotfile-message "HOOK: c-initialization-hook")
            (c-add-style "MJR"
                         `("k&r"
                           (c-doc-comment-style        . 'javadoc)
                           (c-tab-always-indent        . t)
                           (c-recognize-knr-p          . nil)
                           (c-basic-offset             . 2)
                           (c-comment-only-line-offset . 0)
                           (c-offsets-alist (inclass          . ++)
                                            (namespace-open   . 0)
                                            (namespace-close  . 0)
                                            (innamespace      . 2)
                                            (arglist-close    . c-lineup-close-paren)
                                            (brace-list-close . c-lineup-close-paren)
                                            (brace-list-entry . c-lineup-arglist-intro-after-paren)
                                            (access-label     . -)
                                            (case-label       . +)
                                            (c                . (lambda (langelem) ;; For doxygen do c-lineup-dont-change, else do c-lineup-C-comments
                                                                  (let* ((root-pos (c-langelem-pos langelem))
                                                                         (root-col (c-langelem-col langelem 't))
                                                                         (root-str (substring-no-properties (buffer-substring root-pos
                                                                                                                              (min (+ root-pos 4)
                                                                                                                                   (point-max))))))
                                                                    (if (string-equal root-str "/**\n") ;; Doxygen comments match this EXACT string...
                                                                        (c-lineup-dont-change langelem)
                                                                        (c-lineup-C-comments langelem))))))))
            (add-hook 'c-mode-common-hook
                      (function (lambda ()
                                  (mjr-dotfile-message "HOOK: c-mode-common-hook")
                                  (modify-syntax-entry ?_ "w") ;; Make underscore part of a "word"
                                  (setq c-inhibit-startup-warnings-p   t)
                                  (setq c-echo-syntactic-information-p nil)
                                  (setq c-progress-interval            1)
                                  (c-set-style "MJR")
                                  (keymap-local-set "C-c C-c" 'mjr-compile))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: fortran-mode setup...")
(add-hook 'fortran-mode-hook
          (function (lambda ()
                      (mjr-dotfile-message "HOOK: fortran-mode-hook")
                      (setq comment-start               "c")
                      (modify-syntax-entry ?_ "w") ;; Make underscore part of a "word"
                      (setq fortran-comment-indent-char " ")
                      (setq fortran-blink-matching-if   t)
                      (setq fortran-comment-region      "c     ")
                      (keymap-local-set "C-c C-c" 'mjr-compile))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: f90-mode setup...")
(add-hook 'f90-mode-hook
          (function (lambda ()
                      (mjr-dotfile-message "HOOK: f90-mode-hook")
                      (keymap-local-set "C-c C-c" 'mjr-compile))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "SETUP: Meta Windows TeX Live setup...")
(if (not (eq system-type 'windows-nt))
    (mjr-dotfile-message "Meta Windows TeX Live setup: NOP. Not on windows. ")
    (if (let ((case-fold-search 't))
          (string-match "texlive" (getenv "PATH")))
        (mjr-dotfile-message "Meta Windows TeX Live setup: NOP. PATH appears to already have TeX")
        (let ((texlive-path (cl-find-if #'file-exists-p
                                        (list "C:/texlive/2018/bin/win32/"
                                              "C:/texlive/2017/bin/win32/"))))
          (if (not texlive-path)
              (mjr-dotfile-message "Meta Windows TeX Live setup: NOP. Couldn't find TeX")
              (progn (mjr-dotfile-message "Meta Windows TeX Live setup: Adjusting PATH for TeX")
                     (setenv "PATH" (concat texlive-path ":" (getenv "PATH")))
                     (setq exec-path (append (list texlive-path) exec-path)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: perl-mode setup...")
(add-hook 'perl-mode-hook
          (function (lambda ()
                      (mjr-dotfile-message "HOOK: perl-mode-hook")
                      (setq perl-indent-level 2))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: auctex setup...")
(if (not mjr-jrichli-mode)
    (with-eval-after-load "auctex-autoloads"
      (mjr-dotfile-message "EVAL-AFTER: auctex!")
      (setq font-latex-fontify-script nil))
    (mjr-dotfile-message "PKG SETUP: org-mode: Setup suppressed in pookie-mode"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: TeX-mode setup...")
(if (eq system-type 'windows-nt)
    (add-hook 'TeX-mode-hook
              (function (lambda ()
                          (mjr-dotfile-message "HOOK: TeX-mode-hook")
                          (setq ispell-parser 'nroff)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: latex-mode setup...")
(add-hook 'latex-mode-hook
          (function (lambda ()
                      (mjr-dotfile-message "HOOK: latex-mode-hook")
                      (setq tex-font-script-display 0))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: SPICE Setup...")
(progn
  (define-generic-mode spice-mode
    nil
    nil
    (list
     (cons "^[[:space:]]*\\.[a-zA-Z][^[:space:]]*" '(0 font-lock-keyword-face t))
     (cons (concat "^[[:space:]]*\\."
                   (regexp-opt '("end"
                                 "endc"
                                 "ends"
                                 "control"
                                 "subckt")
                               t))                 '(0  font-lock-preprocessor-face t))
     (cons "^[[:space:]]*\\*.*"                    '(0 font-lock-comment-delimiter-face t))
     )
    '(".lib$" ".cir$" ".net$" ".sub$")
    nil
    "Major mode SPICE netlists"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: Maxima setup...")
(unless mjr-jrichli-mode
  (let ((max-el-path (cl-find-if #'file-exists-p (list "c:/maxima-5.46.0/share/emacs/site-lisp/"
                                                       "c:/maxima-5.45.1/share/emacs/site-lisp/"
                                                       "/usr/local/share/maxima/5.41.0/emacs"
                                                       "/usr/share/maxima/5.41.0/emacs"))))
    (when max-el-path
      (mjr-dotfile-message "PKG SETUP: Maxima: Specific Maxima elisp package: %s" max-el-path)
      (add-to-list 'load-path max-el-path)))
  (mjr-dotfile-message "PKG SETUP: Specific version of maxima.el found...")
  (autoload 'maxima      "maxima" "Run Maxima in a window" t)
  (autoload 'maxima-mode "maxima" "Edit Maxima code" t)
  (add-to-list 'auto-mode-alist '("\\.mac$" . maxima-mode))
  (with-eval-after-load "maxima"
    (mjr-dotfile-message "EVAL-AFTER: maxima!")
    (let ((max-bin-path (cl-find-if #'file-exists-p (list "C:/maxima-5.46.0/bin/maxima.bat"
                                                          "C:/maxima-5.45.1/bin/maxima.bat"
                                                          "C:/maxima-5.42.1/bin/maxima.bat"))))
      (when max-bin-path
        (mjr-dotfile-message "EVAL-AFTER: maxima: Specific Maxima binary found: %s" max-bin-path)
        (setq maxima-command max-bin-path)))
    (add-hook 'inferior-maxima-mode-hook
              (lambda ()
                (mjr-dotfile-message "HOOK: inferior-maxima-mode-hook")
                (font-lock-mode 1)
                (keymap-local-set "TAB" 'inferior-maxima-complete))))
  (with-eval-after-load "imaxima"
    (mjr-dotfile-message "EVAL-AFTER: imaxima!")
    ;; The type size used in LaTeX. Options: 9, 10, 11, 12
    (setq imaxima-pt-size 9)
    ;; Default size of font. Options: "small", "normalsize", "large", "Large", "LARGE", "huge", "Huge"
    (setq imaxima-fnt-size "small")
    ;; Scale all images by this factor. Default: 1.0
    (setq imaxima-scale-factor 2.0)
    ;; Use maxima mode
    (setq imaxima-use-maxima-mode-flag 't))
  (autoload 'imaxima "imaxima" "Maxima mode with typeset results" t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless mjr-jrichli-mode
  (mjr-dotfile-message "PKG SETUP: bookmarks setup...")
  (with-eval-after-load "bookmark"
    (mjr-dotfile-message "EVAL-AFTER: bookmarks!")
    (bookmark-maybe-load-default-file)
    (setq bookmark-save-flag 0) ;; Save bookmark file after each change to the bookmark list.
    ;; Make sure some bookmarks exist and point to the right thing.
    (if (not mjr-jrichli-mode)
        (dolist (bp (list (cons "org"            (file-name-concat mjr-dir-core "org-mode/genericOrgTemplate.org"))               ;; Generic org-mode template
                          (cons "codeBits"       (file-name-concat mjr-dir-core "codeBits/"))                                     ;; Code templates, etc...
                          (cons "lispy-dev"      (file-name-concat mjr-home "world/my_prog/lispStuff/lispy/"))                    ;; *mjrcalc*: Development copy
                          (cons "my_ref"         (file-name-concat mjr-home "world/stuff/my_ref/"))                               ;; Notes: Cheat sheets
                          (cons "computer-notes" (file-name-concat mjr-home "world/stuff/notes/computer/"))                       ;; Notes: Computer stuff
                          (cons "shell-stuff"    (file-name-concat mjr-home "world/stuff/notes/computer/howto-shell_things.org")) ;; Notes: Shell Stuff
                          (cons "cmds"           (file-name-concat mjr-home "world/stuff/notes/computer/shell-history.org"))      ;; Notes: Shell History
                          (cons "git"            (file-name-concat mjr-home "world/stuff/notes/computer/howto-git.org"))          ;; Notes: git stuff
                          (cons "ex-R"           (file-name-concat mjr-home "world/my_prog/learn/ex-R"))                          ;; Reference code: R
                          (cons "ex-ruby"        (file-name-concat mjr-home "world/my_prog/learn/ex-ruby"))                       ;; Reference code: Ruby
                          (cons "dotfiles"       (file-name-concat mjr-home "world/dotfiles/"))                                   ;; Dotfile repo
                          (cons ".emacs"         (file-name-concat mjr-home "world/dotfiles/.emacs.d/init.el--SS-X-X-X-X"))       ;; .emacs file
                          (cons "world"          (file-name-concat mjr-home "world/"))                                            ;; All my stuff. ;)
                          (cons "WWW"            (file-name-concat mjr-home "MJR/WWW/"))                                          ;; Web page
                          (cons "todo"           (file-name-concat mjr-home "MJR/TODO/"))                                         ;; org TODOs
                          (cons "home-win"       (list                                                                            ;; Windows Home directory -- VM/windows
                                                  mjr-win-home                                                                    ;;  Auto-detected on MSYS2
                                                  (file-name-concat mjr-home "/winHome/")))                                       ;;  Link or Dir (MSYS2 on windows & VMs on windows)
                          (cons "home-msys2"     (file-name-concat "C:/msys64/home" (user-real-login-name)))                      ;; MSYS2 home directory
                          (cons "data-arch"      (file-name-concat mjr-home "/MJR/dataArch/"))                                    ;; Data archive
                          (cons "doc2"           (file-name-concat mjr-home "/MJR/reading/Doc2/"))                                ;; Ebook repo #1 (go mag)
                          (cons "doc3"           (file-name-concat mjr-home "/MJR/reading/Doc3/"))                                ;; Ebook repo #2
                          ))
          (let* ((bmk-name             (car bp))
                 (bmk-target-options   (cdr bp))
                 (bmk-target-validated (if (stringp bmk-target-options)
                                           (if (file-exists-p bmk-target-options) bmk-target-options)
                                           (cl-find-if (lambda (p) (and (stringp p) (file-exists-p p))) bmk-target-options)))
                 (bmk-target-expanded (and bmk-target-validated (expand-file-name bmk-target-validated))))
            (if (and bmk-name bmk-target-expanded)
                (let ((bmkl (list bmk-name (cons 'filename bmk-target-expanded))))
                  (if (assoc bmk-name bookmark-alist)
                      (setcdr (assoc bmk-name bookmark-alist) bmkl)
                      (add-to-list 'bookmark-alist bmkl))))))
        (mjr-dotfile-message "PKG SETUP: bookmarks: SKIP: Pookie mode"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless mjr-jrichli-mode
  (mjr-dotfile-message "PKG SETUP: hyperspec...")
  (with-eval-after-load "hyperspec"
    (mjr-dotfile-message "EVAL-AFTER: hyperspec!")
    (let ((spec-to-use (cl-find-if #'file-exists-p
                                   (list "/usr/share/doc/hyperspec/"
                                         "/Users/Shared/Doc2/software-dev/LISP/hyperspec/"
                                         "/media/sf_D_DRIVE/Doc2/software-dev/LISP/hyperspec/"
                                         "/Users/richmit/MJR/Reading/Doc2/software-dev/LISP/hyperspec/"
                                         "d:/Doc2/software-dev/LISP/hyperspec/"
                                         "/opt/local/share/doc/lisp/HyperSpec-7-0/HyperSpec/"))))
      (if spec-to-use
          (setq common-lisp-hyperspec-root (concat "file://" spec-to-use))
          (mjr-dotfile-message "EVAL-AFTER: hyperspec: WARNING: Using remote hyperspec: %s"
                   (setq common-lisp-hyperspec-root "http://www.lispworks.com/reference/HyperSpec/"))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless  mjr-jrichli-mode
  (mjr-dotfile-message "PKG SETUP: SLIME...")
  (if (require 'slime-autoloads nil :noerror)
      (with-eval-after-load "slime"
        (mjr-dotfile-message "EVAL-AFTER: slime!")
        (defun mjr-slime-selector-or-run-slime (start-if-not-running)
          "Run slime-selector if we have an active connection, otherwise run slime"
          (interactive "P")
          (if (not (zerop (length slime-net-processes)))
              (slime-selector)
              (if start-if-not-running
                  (slime)
                  (message "mjr-slime-selector-or-run-slime: SLIME is not running.  Run with prefix to start."))))
        (defun mjr-find-symbol-def ()
          "Use slime-edit-definition if connected to slime, or slime-edit-definition-with-etags otherwise"
          (interactive)
          (if (not (zerop (length slime-net-processes)))
              (call-interactively #'slime-edit-definition)
              (progn (message "mjr-find-symbol-def: SLIME is not running.  Falling back to ETAGS")
                     (call-interactively #'slime-edit-definition-with-etags))))
        ;; Find lisp binary, and set any required environment vairables
        (let ((lisp-ver-ret (el-vergo "lisp" 'DOS)))
          (if lisp-ver-ret
              (progn (dolist (vsd (cdr lisp-ver-ret))
                       (let ((eq-loc (string-search "=" vsd)))
                         (when eq-loc
                           (let ((v-name (substring vsd 0 eq-loc))
                                 (v-valu (substring vsd (1+ eq-loc))))
                             (setenv v-name v-valu)))))
                     (setq inferior-lisp-program (car lisp-ver-ret)))
              (mjr-dotfile-message "EVAL-AFTER: WARNING: No working lisp found")))
        (slime-setup '(slime-repl)) ; Setup (use SLIME-REPL)
        ;;(setq slime-repl-auto-right-margin 't)
        (setq lisp-simple-loop-indentation  1
              lisp-loop-keyword-indentation 6
              lisp-loop-forms-indentation   6)
        (setq slime-net-coding-system 'utf-8-unix)
        (add-hook 'lisp-mode-hook
                  (lambda ()
                    (mjr-dotfile-message "HOOK: lisp-mode-hook")
                    (setq slime-net-coding-system 'utf-8-unix)))
        ;;(keymap-set slime-mode-map "\M-." 'find-tag)
        ;; M-x slime-who-calls       Show function callers.
        ;; M-x slime-who-references  Show references to global variable.
        ;; REPL bindings
        (keymap-set slime-repl-mode-map "M-."    'mjr-find-symbol-def)
        (keymap-set slime-repl-mode-map "C-p"    'slime-repl-backward-input)        ;; Previous history on C-p
        (keymap-set slime-repl-mode-map "C-n"    'slime-repl-forward-input)         ;; Previous history on C-p
        (keymap-set slime-repl-mode-map "C-c r"  'mjr-slime-selector-or-run-slime)  ;; Slime Selector
        ;; CODE bindings
        (keymap-set slime-mode-map "M-."         'mjr-find-symbol-def)
        (keymap-set slime-mode-map "C-c r"       'mjr-slime-selector-or-run-slime)  ;; Slime Selector
        ;; GLOBAL bindings
        (global-set-key (kbd "C-c r")     'mjr-slime-selector-or-run-slime))
      (mjr-dotfile-message "PKG SETUP: SLIME Not Found...")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (require 'ido nil :noerror)
  (mjr-dotfile-message "PKG SETUP: ido...")
  (if mjr-jrichli-mode
      (setq ido-use-filename-at-point nil)                                              ;; Disable ffap in pookie mode
      (setq ido-use-filename-at-point 'guess))                                          ;; Enable ffap in non-pookie mode
  (setq ido-auto-merge-work-directories-length -1)                                      ;; Don't switch to other directories if file not found
  (setq ido-use-url-at-point nil)                                                       ;; Don't look for URLs at point
  (dolist (directory-re '("\\`RCS/"                                                     ;; Set ignore directory list
                          "\\`auto/"
                          "\\`\\.git/"))
    (add-to-list 'ido-ignore-directories directory-re))
  (dolist (ext '("fasl" "ufasl" "fas" "lib" "o"                                         ;; File extensions to ignore -- ido-ignore-extensions no workie for me
                 "dvi" "asd" "so"
                 "aux" "bbl" "bcf" "blg" "log"
                 "out" "run.xml"))
    (add-to-list 'ido-ignore-files (concat "\\." ext "$")))
  (dolist (file-re '("\\`RCS/"                                                          ;; Some files to ignore
                     "\\`\\.git/"
                     "\\`\\.DS_Store"
                     "\\`a\\.out"))
    (add-to-list 'ido-ignore-files file-re))
  (dolist (buffer-re '("\\`\\*ESS\\*"                                                   ;; Some buffers to ignore
                       "\\`\\*slime-events\\*"
                       "\\`\\*Apropos\\*"
                       "\\`\\*Completions\\*"
                       "\\`\\*vc\\*"
                       "\\`\\*slime-compilation\\*"
                       "\\`\\*changes to.*\\*"
                       "\\`\\*log-edit-files\\*"
                       "\\`\\*Org-Babel Error Output\\*"
                       "\\`\\*inferior-lisp\\*"
                       "\\`\\*Warning\\*"))
    (add-to-list 'ido-ignore-buffers buffer-re))
  (setq ido-file-extensions-order '(".org" ".lisp" ".R" ".rb" ".tex" ".txt"             ;; Order to list files only differing by extension
                                    ".hpp" ".cpp" ".h" ".c" ".asd" ".log"))
  (setq ido-enable-flex-matching t)                                                     ;; List everything that matches input (not just at start)
  (if (not mjr-jrichli-mode)
      (setq ido-everywhere t))                                                          ;; Turn it on everyplace
  (if mjr-jrichli-mode
      (ido-mode 'buffers)                                                               ;; pookie mode: Start ido mode for buffers only
      (ido-mode 1))                                                                     ;; non-pookie mode: Start ido mode for buffers and files
  (defun mjr-wack-back-to-slash ()                                                      ;; Zap everything backward till a "/" character
    "Zap characters backward till a slash(/) character"
    (interactive)
    (goto-char (point-max))
    (let ((sp (point))
          (ep (progn (search-backward "/")
                     (forward-char)
                     (point))))
      (unless (= sp ep)
        (kill-region sp ep))))
  (keymap-set ido-common-completion-map "M-<backspace>" #'mjr-wack-back-to-slash) ;; Bind mjr-wack-back-to-slash
  (keymap-set ido-common-completion-map "M-<DEL>"       #'mjr-wack-back-to-slash))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (require 'package nil :noerror)
  (mjr-dotfile-message "PKG SETUP: package...")
  (and 't  (add-to-list 'package-archives '("melpa"        . "http://melpa.org/packages/")        t))
  (and nil (add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/") t))
  (package-initialize))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mjr-install-missing-packages (package-list)
  "Install my missing packages."
  (when-let ((missing-package-list (cl-remove-if #'package-installed-p package-list)))
    (when (y-or-n-p "Install missing packages? ")
      (ignore-errors (package-refresh-contents))
      (dolist (package-name missing-package-list)
        (unless (ignore-errors (package-install package-name))
          (message "mjr-install-favorite-packages: Package %s was not installed.  Installing now." package-name))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: hs-minor-mode")
(with-eval-after-load "hideshow"
  (mjr-dotfile-message "EVAL-AFTER: hs-minor-mode!")
  (add-hook 'c-mode-common-hook   'hs-minor-mode)
  (add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
  (add-hook 'fortran-mode-hook    'hs-minor-mode)
  (add-hook 'java-mode-hook       'hs-minor-mode)
  (add-hook 'lisp-mode-hook       'hs-minor-mode)
  (add-hook 'perl-mode-hook       'hs-minor-mode)
  (defun mjr-hs-toggle ()
    "Prefix arg determines action: No prefix => toggle hide for current block; otherwise, hide everything if arg is 4, else show everything."
    (interactive)
    (hs-minor-mode 1) ;; Turn on minor mode just in case it's off
    (if current-prefix-arg
        (if (= (prefix-numeric-value current-prefix-arg) 4)
            (hs-hide-all)
            (hs-show-all))
        (hs-toggle-hiding)))
  (global-set-key (kbd "C-c h") 'mjr-hs-toggle))
(require 'hideshow)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless mjr-jrichli-mode
  (mjr-dotfile-message "PKG SETUP: yasnippet")
  (let ((yasnippet-snip-path (cl-remove-if-not #'file-exists-p (list (file-name-concat mjr-dir-core   "/yasnippets")
                                                                     (file-name-concat mjr-dir-core   "/yasnippet")))))
    (when yasnippet-snip-path
      (mjr-dotfile-message "PKG SETUP: yasnippet snippet directory found... %s" yasnippet-snip-path)
      (with-eval-after-load "yasnippet"
        (mjr-dotfile-message "EVAL-AFTER: yasnippet!")
        ;; Call yas-expand or yas-insert-snippet depending on if region is active
        (defun mjr-expand ()
          "If no region is active, use yas-expand to attempt yasnippet expansion; otherwise call yas-insert-snippet."
          (interactive)
          (unless (cl-find 'fundamental-mode minor-mode-list)       ;; Always load these
            (yas-activate-extra-mode 'fundamental-mode))
          (when (cl-find major-mode '(f90-mode c++-mode org-mode))  ;; Modes where I use LaTeX
            (yas-activate-extra-mode 'latex-mode))
          (if (and transient-mark-mode (region-active-p))
              (funcall-interactively #'yas-insert-snippet)
              (unless (funcall-interactively #'yas-expand)
                (funcall-interactively #'yas-insert-snippet))))
        ;; Use ido instead of dropdown...
        (setq yas-prompt-functions '(yas-maybe-ido-prompt yas-completing-prompt yas-no-prompt))
        ;; Fix the snipped dirs
        (setq yas-snippet-dirs yasnippet-snip-path)
        ;; Nix the default tab binding..
        (keymap-set yas-minor-mode-map  "<tab>" nil)
        (keymap-set yas-minor-mode-map  "TAB"   nil)
        ;; Add in-key-map binding for my own expand
        (keymap-set yas-minor-mode-map "ESC ESC TAB" 'mjr-expand)
        ;; Add global binding for my own expand
        (mjr-keymap-global-set-if-fbound "C-c m" 'mjr-expand)
        ;; How we get some global templates
        (add-hook 'yas-minor-mode-hook
                  (lambda ()
                    (mjr-dotfile-message "HOOK: yas-minor-mode-hook")
                    (yas-activate-extra-mode 'fundamental-mode)))
        ;; Make yas work everyplace
        (yas-global-mode 1))
      (require 'yasnippet nil 't))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: comint")
(with-eval-after-load "comint"
  (mjr-dotfile-message "EVAL-AFTER: comint!")
  (add-hook 'comint-mode-hook
            (lambda ()
              (mjr-dotfile-message "HOOK: comint-mode-hook")
              (keymap-local-set "C-p" 'comint-previous-input)
              (keymap-local-set "C-n" 'comint-next-input))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: dos-w32")
(with-eval-after-load "dos-w32"
  (mjr-dotfile-message "EVAL-AFTER: dos-w32!")
  ;; I use a bash shell not DOS.  On DOS the value should be "NUL", but for base I need to reset it back to "/dev/null"
  (setq null-device "/dev/null"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: javascript")
(with-eval-after-load "js"
  (mjr-dotfile-message "EVAL-AFTER: javascript")
  (setq js-indent-level 2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: ibuffer")
(declare-function ibuffer-current-buffer "ibuffer" (&optional MUST-BE-LIVE))
(with-eval-after-load "ibuffer"
  (mjr-dotfile-message "EVAL-AFTER: ibuffer")
  (setq ibuffer-expert 't)
  (setq ibuffer-display-summary nil)
  (defun ibuffer-visit-buffer (&optional single)
    "Override ibuffer-visit-buffer to make it go away when we visit a buffer."
    (interactive "P")
    (let ((buf (ibuffer-current-buffer t)))
      (kill-buffer (current-buffer))
      (switch-to-buffer buf)
      (when single
        (delete-other-windows)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: recentf")
(recentf-mode 1)
(setq recentf-max-menu-items 40)
(setq recentf-max-saved-items 2000)
(run-at-time nil (* 5 60) 'recentf-save-list)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless (or t
            mjr-jrichli-mode
            (version< emacs-version "29.1")
            (not (require 'treesit nil :noerror))
            (not (treesit-available-p)))
  (mjr-dotfile-message "PKG SETUP: tree-sitter")
  ;; sh-mode -> bash-ts-mode is a bug.  Should switch to bash-ts-mode in a hook after determining the language.  I always use bash, so not high priority.
  (let ((tree-db-list '((bash        ("https://github.com/tree-sitter/tree-sitter-bash")                                 (sh-mode         . bash-ts-mode))
                        (c           ("https://github.com/tree-sitter/tree-sitter-c")                                    (c-mode          . c-ts-mode))
                        (cmake       ("https://github.com/uyha/tree-sitter-cmake")                                       (cmake-mode      . cmake-ts-mode))
                        (cpp         ("https://github.com/tree-sitter/tree-sitter-cpp")                                  (c++-mode        . c++-ts-mode))
                        (css         ("https://github.com/tree-sitter/tree-sitter-css")                                  (css-mode        . css-ts-mode))
                        (html        ("https://github.com/tree-sitter/tree-sitter-html")                                 nil)
                        (java        ("https://github.com/tree-sitter/tree-sitter-java")                                 (java-mode       . java-ts-mode))
                        (javascript  ("https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")            (javascript-mode . js-ts-mode))
                        (make        ("https://github.com/alemuller/tree-sitter-make")                                   (json-mode       . json-ts-mode))
                        (python      ("https://github.com/tree-sitter/tree-sitter-python")                               (python-mode     . python-ts-mode))
                        (ruby        ("https://github.com/tree-sitter/tree-sitter-ruby")                                 (ruby-mode       . ruby-ts-mode))
                        (rust        ("https://github.com/tree-sitter/tree-sitter-rust")                                 (rust-mode       . rust-ts-mode))
                        (typescript  ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src") (typescript-mode . typescript-ts-mode))
                        (yaml        ("https://github.com/ikatyang/tree-sitter-yaml")                                    (yaml-mode       . yaml-ts-mode)))))
    ;; Configure treesit-language-source-alist with languages we use and grammer source URLs
    (setq treesit-language-source-alist
          (mapcar (lambda (x) (append (list (car x)) (nth 1 x)))
                  tree-db-list))
    ;; Install missing grammers the languages we use
    (mapc #'treesit-install-language-grammar
          (cl-remove-if #'treesit-language-available-p
                        (mapcar #'car
                                tree-db-list)))
    ;; Remap modes to use ts when we can
    (mapc (lambda (x) (add-to-list 'major-mode-remap-alist x))
          (mapcar (lambda (x) (nth 2 x))
                  (cl-remove-if-not (lambda (x) (and (nth 2 x) (treesit-language-available-p (nth 0 x))))
                                    tree-db-list)))
    ;; Special support for wacky c++/c mixed mode
    (when (and (treesit-language-available-p 'cpp) (treesit-language-available-p 'c))
      (add-to-list 'major-mode-remap-alist
                   '(c-or-c++-mode . c-or-c++-ts-mode)))
    ;; Lots of colors!
    (customize-set-variable 'treesit-font-lock-level 4)
    ;; Javascript setup
    (add-hook 'js-ts-mode-hook
              (lambda ()
                (mjr-dotfile-message "HOOK: js-ts-mode-hook (indent)")
                (customize-set-variable 'js-indent-level 2)))
    ;; Java setup
    (add-hook 'java-ts-mode-hook
              (lambda ()
                (mjr-dotfile-message "HOOK: java-ts-mode-hook (indent)")
                (customize-set-variable 'java-ts-mode-indent-offset 2)))
    ;; C & C++ indentation
    (when (or (treesit-language-available-p 'cpp) (treesit-language-available-p 'c))
      (defun mjr-c-ts-indent-rules (mode)
        "Mitch's C++/C Indent rules -- Pretty much K&R except where noted."
        (let ((rules `((c-ts-mode--for-each-tail-body-matcher prev-line c-ts-mode-indent-offset)
                       ((parent-is "translation_unit") column-0 0)
                       ((query "(ERROR (ERROR)) @indent") column-0 0)
                       ((node-is ")") parent 0)                                                            ;; MJR: Line up closing ) with opening
                       ((and (node-is "}")                                                                 ;; MJR: Line up closing } for assignments
                             (or (parent-is "enumerator_list")
                                 (parent-is "initializer_list"))) parent 0)
                       ((node-is "]") parent-bol 0)
                       ((node-is "else") parent-bol 0)
                       ((node-is "case") parent-bol c-ts-mode-indent-offset)                               ;; MJR: Case gets indent
                       ((node-is "preproc_arg") no-indent)
                       ((and (parent-is "comment")
                             c-ts-common-looking-at-star) c-ts-common-comment-start-after-first-star -1)
                       (c-ts-common-comment-2nd-line-matcher c-ts-common-comment-2nd-line-anchor 1)
                       ((parent-is "comment") prev-adaptive-prefix 0)
                       ((node-is "labeled_statement") standalone-parent 0)
                       ((parent-is "labeled_statement") c-ts-mode--standalone-grandparent c-ts-mode-indent-offset)
                       ((node-is "preproc") column-0 0)
                       ((node-is "#endif") column-0 0)
                       ((match "preproc_call" "compound_statement") column-0 0)
                       ((n-p-gp nil "preproc" "translation_unit") column-0 0)
                       ((and no-node
                             (parent-is ,(rx (or "\n" "preproc")))) c-ts-mode--standalone-parent-skip-preproc c-ts-mode--preproc-offset)
                       ((match nil ,(rx "preproc_" (or "if" "elif")) nil 3 3) c-ts-mode--standalone-parent-skip-preproc c-ts-mode-indent-offset)
                       ((match nil "preproc_ifdef" nil 2 2) c-ts-mode--standalone-parent-skip-preproc c-ts-mode-indent-offset)
                       ((match nil "preproc_else" nil 1 1) c-ts-mode--standalone-parent-skip-preproc c-ts-mode-indent-offset)
                       ((parent-is "preproc") c-ts-mode--anchor-prev-sibling 0)
                       ((parent-is "function_definition") parent-bol 0)
                       ((parent-is "conditional_expression") first-sibling 0)
                       ((parent-is "assignment_expression") parent-bol c-ts-mode-indent-offset)
                       ((parent-is "concatenated_string") first-sibling 0)
                       ((parent-is "comma_expression") first-sibling 0)
                       ((parent-is "init_declarator") parent-bol c-ts-mode-indent-offset)
                       ((parent-is "parenthesized_expression") first-sibling 1)
                       ((parent-is "argument_list") first-sibling 1)
                       ((parent-is "parameter_list") first-sibling 1)
                       ((parent-is "binary_expression") parent 0)
                       ((query "(for_statement initializer: (_) @indent)") parent-bol 5)
                       ((query "(for_statement condition: (_) @indent)") parent-bol 5)
                       ((query "(for_statement update: (_) @indent)") parent-bol 5)
                       ((query "(call_expression arguments: (_) @indent)") parent c-ts-mode-indent-offset)
                       ((parent-is "call_expression") parent 0)
                       ((node-is "}") standalone-parent 0)
                       ,@(when (eq mode 'cpp)
                           '(((node-is "access_specifier") parent-bol c-ts-mode-indent-offset)             ;; MJR: indent things like public: & private:
                             ((parent-is "declaration_list") parent-bol 4)))                               ;; MJR: Indent 2x for member class decl
                       ((match nil "initializer_list" nil 1 1) parent-bol c-ts-mode-indent-offset)
                       ((parent-is "initializer_list") c-ts-mode--anchor-prev-sibling 0)
                       ((match nil "enumerator_list" nil 1 1) standalone-parent c-ts-mode-indent-offset)
                       ((parent-is "enumerator_list") c-ts-mode--anchor-prev-sibling 0)
                       ((match nil "field_declaration_list" nil 1 1) standalone-parent c-ts-mode-indent-offset)
                       ((parent-is "field_declaration_list") c-ts-mode--anchor-prev-sibling 0)
                       ((or (match nil "compound_statement" nil 1 1)
                            (match null "compound_statement")) standalone-parent c-ts-mode-indent-offset)
                       ((parent-is "compound_statement") c-ts-mode--anchor-prev-sibling 0)
                       ((node-is "compound_statement") standalone-parent c-ts-mode-indent-offset)
                       ((match "expression_statement" nil "body") standalone-parent c-ts-mode-indent-offset)
                       ((parent-is "if_statement") standalone-parent c-ts-mode-indent-offset)
                       ((parent-is "for_statement") standalone-parent c-ts-mode-indent-offset)
                       ((parent-is "while_statement") standalone-parent c-ts-mode-indent-offset)
                       ((parent-is "do_statement") standalone-parent c-ts-mode-indent-offset)
                       ((parent-is "case_statement") standalone-parent c-ts-mode-indent-offset)
                       ,@(when (eq mode 'cpp)
                           `(((node-is "field_initializer_list") parent-bol ,c-ts-mode-indent-offset))))))
          `((,mode ,@rules))))
      (when (treesit-language-available-p 'c)
        (add-hook 'c-ts-mode-hook
                  (lambda ()
                    (mjr-dotfile-message "HOOK: c-ts-mode-hook (indent)")
                    (setq treesit-simple-indent-rules (mjr-c-ts-indent-rules 'c)))))
      (when (treesit-language-available-p 'cpp)
        (add-hook 'c++-ts-mode-hook
                  (lambda ()
                    (mjr-dotfile-message "HOOK: c++-ts-mode-hook (indent & C-c C-c)")
                    (setq treesit-simple-indent-rules (mjr-c-ts-indent-rules 'cpp))
                    (keymap-local-set "C-c C-c" 'mjr-compile)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Setup global aliases....")

(defalias 'sipell                      'ispell)                         ;; typo optimization
(defalias 'sipell-comments-and-strings 'ispell-comments-and-strings)    ;; better name + typo optimization

(defalias 'ipsell                      'ispell)                         ;; typo optimization
(defalias 'ipsell-comments-and-strings 'ispell-comments-and-strings)    ;; typo optimization

(defalias 'code-indent                 'indent-region)                  ;; better name

(defalias 'irb                         'inf-ruby)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Setup global keys....")

;; Git rid of the suspend
(global-set-key (kbd "C-z")       nil)
(global-set-key (kbd "C-x C-z")   nil)

;; Island keys
(global-set-key (kbd "C-<right>") 'forward-word)
(global-set-key (kbd "C-<left>")  'backward-word)
(global-set-key (kbd "M-<right>") 'forward-sexp)
(global-set-key (kbd "M-<left>")  'backward-sexp)
(global-set-key (kbd "<del>")     'delete-char)

;; Mouse left and right on MX mouse
(global-set-key (kbd "<mouse-6>") 'scroll-right)
(global-set-key (kbd "<mouse-7>") 'scroll-left)

;; Thumb buttons on 3dc mouse
(global-set-key (kbd "<mouse-4>") 'previous-buffer)
(global-set-key (kbd "<mouse-5>") 'next-buffer)

;; Override C-x C-b
;;lobal-set-key (kbd "C-x C-b")   'buffer-menu)
(global-set-key (kbd "C-x C-b")   'ibuffer)

;; kill ring yank menu
(global-set-key "\C-cy" (lambda () (interactive) (popup-menu 'yank-menu)))

;; For split keyboards...
(global-set-key (kbd "C-t")       'yank)

;; Start Slime or run slime-selector  --  R is for REPL.
(unless mjr-jrichli-mode
  (when (require 'slime-autoloads nil :noerror)
    (if (functionp 'mjr-slime-selector-or-run-slime)
        (global-set-key (kbd "C-c r") 'mjr-slime-selector-or-run-slime)
        (global-set-key (kbd "C-c r") (lambda (p) (interactive "P") (if p (slime) (message "SLIME not loaded.  Run again with prefix arg to start SLIME")))))))

(when mjr-jrichli-mode
  (global-set-key (kbd "C-c x")     (lambda () (interactive) (kill-buffer) (delete-frame)))) ;; Close buffer and delete frame

;; Random key bindings
(mjr-keymap-global-set-if-fbound "C-x r a"     'append-to-register)
(mjr-keymap-global-set-if-fbound "ESC ESC q"   'mjr-unfill)
(mjr-keymap-global-set-if-fbound "ESC ESC g"   'goto-line)
(mjr-keymap-global-set-if-fbound "ESC ESC ;"   'mjr-quick-code-comment)
(mjr-keymap-global-set-if-fbound "ESC ESC :"   'mjr-eval-meta)
(mjr-keymap-global-set-if-fbound "ESC ESC %"   'mjr-query-replace-fixed-case)
(mjr-keymap-global-set-if-fbound "ESC ESC C-%" 'mjr-query-replace-regexp-fixed-case)
(mjr-keymap-global-set-if-fbound "ESC ="       'mjr-describe-region-or-char)
(mjr-keymap-global-set-if-fbound "C-x C-r"     'mjr-recentf-find-file) ;;; Normally this is open read only.
(keymap-global-set               "M-<f11>"     'toggle-frame-fullscreen)
(keymap-global-set               "<f11>"       'toggle-frame-fullscreen)

;; C-c letter bindings
;;eymap-global-set "C-c a"       ;; FREE
(mjr-keymap-global-set-if-fbound "C-c b"       'mjr-select-window)
(mjr-keymap-global-set-if-fbound "C-c c"       'mjr-compile)
(mjr-keymap-global-set-if-fbound "C-c d"       'mjr-dired-for-buffer)
(mjr-keymap-global-set-if-fbound "C-c e"       'mjr-open-cwd)
(mjr-keymap-global-set-if-fbound "C-c f"       'mjr-follow-mode)
(keymap-global-set               "C-c g"       'vc-dir-root)
;;eymap-global-set               "C-c h"       HS-MINOR-MODE
(keymap-global-set               "C-c i"       'ispell)
(keymap-global-set               "C-c j"       'delete-indentation)    ;;; In dired this gets a local key binding
;;eymap-global-set               "C-c k"       ;; FREE
(mjr-keymap-global-set-if-fbound "C-c l"       'mjr-thingy-lookeruper)
;;eymap-global-set               "C-c m"       YASNIPPET EXPAND
(mjr-keymap-global-set-if-fbound "C-c n"       'mjr-scratch)
;;eymap-global-set               "C-c o"       ;; FREE
(mjr-keymap-global-set-if-fbound "C-c p"       'mjr-preview)
;;eymap-global-set               "C-c q"       ;; FREE
;;eymap-global-set               "C-c r"       SLIME SELECTOR
(mjr-keymap-global-set-if-fbound "C-c s"       'mjr-eshell)
(mjr-keymap-global-set-if-fbound "C-c t"       'mjr-date)
;;eymap-global-set               "C-c u"       ;; FREE
(mjr-keymap-global-set-if-fbound "C-c v"       'mjr-view-file-or-url-at-point)
(mjr-keymap-global-set-if-fbound "C-c w"       'mjr-arrange-windows)
;;jr-keymap-global-set-if-fbound "C-c x"       ;; FREE
(keymap-global-set               "C-c y"       (lambda () (interactive) (popup-menu 'yank-menu)))
(mjr-keymap-global-set-if-fbound "C-c z"       'mjr-window-zoom)

;; Not global, but the mini-buffer is kinda everyplace...
(keymap-set minibuffer-local-map "C-p" 'previous-history-element)
(keymap-set minibuffer-local-map "C-n" 'next-history-element)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Emacs Customization System....")

(customize-set-variable  'shell-command-dont-erase-buffer             'beg-last-out)  ;; Just keep tacking on shell-command output, but put point at top of last command output
(customize-set-variable  'fortran-blink-matching-if                   t)
(customize-set-variable  'TeX-auto-untabify                           t)
(customize-set-variable  'delete-selection-mode                       t)
(customize-set-variable  'indicate-buffer-boundaries                  'right)
(customize-set-variable  'indicate-empty-lines                        t)
(customize-set-variable  'Man-notify-method                           'pushy)
(customize-set-variable  'LaTeX-item-indent                           0)
(customize-set-variable  'TeX-PDF-mode                                t)
(customize-set-variable  'TeX-auto-save                               t)
(customize-set-variable  'mouse-wheel-follow-mouse                    t)
(customize-set-variable  'mouse-autoselect-window                     t)
(customize-set-variable  'TeX-parse-self                              t)
(customize-set-variable  'ansi-color-faces-vector                     [default default default italic underline success warning error])
(customize-set-variable  'ansi-color-names-vector                     ["#212526" "#ff4b4b" "#b4fa70" "#fce94f" "#729fcf" "#e090d7" "#8cc4ff" "#eeeeec"])
(customize-set-variable  'safe-local-variable-values                  '((org-confirm-babel-evaluate)
                                                                        (Syntax . ANSI-Common-LISP)
                                                                        (org-html-link-org-files-as-html)))
(customize-set-variable  'async-shell-command-buffer                  'new-buffer)
(customize-set-variable  'async-shell-command-display-buffer          nil)
(customize-set-variable  'doc-view-cache-directory                    "~/tmp/doc-view-cache/")
(customize-set-variable  'package-gnupghome-dir                       "/home/richmit/.emacs.d/elpa/gnupg")  ;; If we use the MSYS2 GPG, then we use an MSYS2 path!!!
(customize-set-variable  'gdb-many-windows                            t) ;; Open gdb with lots of windows.
(customize-set-variable  'gdb-restore-window-configuration-after-quit 'if-gdb-many-windows)
(customize-set-variable  'gdb-default-window-configuration-file       "gdb-window-config-asm")
(customize-set-variable  'gdb-display-io-buffer                       nil)

(customize-set-variable  'compilation-scroll-output t) ;; Scroll to end
(customize-set-variable  'compilation-skip-threshold 2) ;; Skip warnings and info

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: mjr-code-tools")
(with-eval-after-load "mjr-code-tools"
  (mjr-dotfile-message "EVAL-AFTER: mjr-code-tools")
  (customize-set-variable 'mjr-quick-code-comment-who (cond (mjr-richmit-mode "MJR")
                                                            (mjr-jrichli-mode "JLR")))
  (customize-set-variable 'mjr-fix-c-includes-der-db (concat mjr-dir-core "/codeBits/cheaderSTD.txt"))
  (customize-set-variable 'mjr-add-header-der-templates (concat (file-name-concat mjr-dir-core "codeBits/templates/")))
  (customize-set-variable 'mjr-add-header-der-licenses (concat (file-name-concat mjr-dir-core "codeBits/licenseFiles/")))
  (customize-set-variable 'mjr-add-header-der-login-name (cond (mjr-richmit-mode "richmit")
                                                               (mjr-jrichli-mode "jrichli")))
  (customize-set-variable 'mjr-add-header-der-legal-name (cond (mjr-richmit-mode "Mitchell Jay Richling")
                                                               (mjr-jrichli-mode "Janie Richling")))
  (customize-set-variable 'mjr-add-header-der-git-email (when mjr-richmit-mode "https://www.mitchr.me/"))
  (customize-set-variable 'mjr-github-url-default "https://github.com/richmit/"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: mjr-compile")
(with-eval-after-load "mjr-compile"
  (mjr-dotfile-message "EVAL-AFTER: mjr-compile")
  (customize-set-variable 'mjr-compile-parallelism 8))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: mjr-preview")
(with-eval-after-load "mjr-preview"
  (mjr-dotfile-message "EVAL-AFTER: mjr-preview")
  (customize-set-variable 'mjr-preview-render-org-html-header-file (file-name-concat mjr-dir-core "org-mode/preview-config.org")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: mjr-eval")
(with-eval-after-load "mjr-eval"
  (mjr-dotfile-message "EVAL-AFTER: mjr-eval")
  (customize-set-variable 'mjr-eval-meta-use-read-answer t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: mjr-embedded-debug")
(with-eval-after-load "mjr-embedded-debug"
  (mjr-dotfile-message "EVAL-AFTER: mjr-embedded-debug")
  (customize-set-variable 'emdbg-gdb-remote-window-config (when (file-exists-p "~/.emacs.d/gdb-window-config-remote")))
  (customize-set-variable 'emdbg-gdb-remote-bins
                          (list (cons "openocd"           (lambda () (el-vergo-or-path       "openocd")))
                                (cons "jlink-gdb-server"  (lambda () (el-vergo-or-path       "JLinkGDBServerCL")))     ;; (emdbg-stm32-cbm-lookup "jlink-gdbserver")
                                (cons "stlink-gdb-server" (lambda () (emdbg-stm32-cbm-lookup "stlink-gdbserver")))     ;; (el-vergo-path "ST-LINK_gdbserver")
                                (cons "gdb"               (lambda () (emdbg-stm32-cbm-lookup "arm-none-eabi-gdb")))    ;; (el-vergo-path "arm-none-eabi-gdb")
                                (cons "stm32-programmer"  (lambda () (emdbg-stm32-cbm-lookup "programmer" "FQFN")))))) ;; (el-vergo-path "STM32CubeProgrammer")

;; (customize-set-variable 'emdbg-gdb-remote-cube-wrap-bins '(("gdb"               . "arm-none-eabi-gdb")
;;                                                            ("stlink-gdb-server" . "stlink-gdbserver")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: mjr-zotero")
(with-eval-after-load "mjr-zotero"
  (mjr-dotfile-message "EVAL-AFTER: mjr-zotero")
  (customize-set-variable 'mjr-zotero-db-cache-search-auto-refresh t)
  (customize-set-variable 'mjr-zotero-local-api-verbose nil)
  (customize-set-variable 'mjr-zotero-connector-verbose nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PKG SETUP: mrscpi-in-emacs")
(when mjr-richmit-mode
   (with-eval-after-load "mrscpi-in-emacs"
     (customize-set-variable 'mrscpi-in-emacs-bin-path (expand-file-name "~/bin/mrSCPI.rb"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load custom-file))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Personal Package Install....")
(cond (mjr-jrichli-mode (mjr-install-mjr-packages :missing :github '(mjr-buffer-directory mjr-apply-dired-magic el-vergo mjr-show-buffer mjr-eval mjr-numbers-in-column mjr-thingy-lookeruper)))
      (mjr-richmit-mode (mjr-install-mjr-packages :missing :git))
      (t                (mjr-install-mjr-packages :missing :github)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Third Party Package Install....")
(cond (mjr-jrichli-mode (mjr-install-missing-packages '(org htmlize yasnippet)))
      (mjr-richmit-mode (mjr-install-missing-packages '(julia-mode 
                                                        cmake-mode
                                                        auctex
                                                        org htmlize 
                                                        inf-ruby
                                                        slime
                                                        yasnippet 
                                                        ess-view ess-R-data-view
                                                        powershell 
                                                        pov-mode 
                                                        gnuplot-mode))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Package Install....")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(mjr-dotfile-message "PROGRESS: Init file finished loading....")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
