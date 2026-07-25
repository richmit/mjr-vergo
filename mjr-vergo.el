;; mjr-vergo --- Provide verGo.sh in Emacs. -*-coding: utf-8 lexical-binding:t mode:emacs-lisp -*-

;; Copyright (C) 2026-2026 First Last me@mitchr.me

;; Author:      Mitch Richling
;; Version:     0.12
;; Keywords:    verGo
;; URL:         https://github.com/richmit/mjr-vergo

;; This file is not part of Emacs

;;; Install:
;; See the README: https://github.com/richmit/mjr-vergo/

;;; Commentary:
;; See the README: https://github.com/richmit/mjr-vergo/

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;###autoload
(defgroup mjr-vergo nil
  "Access verGo.sh from emacs."
  :group 'external
  :group 'environment)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;###autoload
(defcustom mjr-vergo-bin (locate-file "verGo.sh" exec-path)
  "File to use for vreGo.sh"
  :type 'file
  :group 'mjr-vergo)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;###autoload
(defun mjr-vergo (app &optional path-format)
  "Use verGo.sh to find a binary and environment variables (list of strings).
If path-format is invalid or missing, then `MIX' is used.
NIL is returned if anything goes wrong -- no errors are raised."
  (when-let* ((path-format (or (car (member path-format '(RAW UNIX WIN DOS MIX)))
                               'MIX))
              (ver-go-bin  mjr-vergo-bin)
              (            (file-exists-p ver-go-bin))
              (            (stringp app))
              (            (not (string-empty-p app)))
              (cmd         (concat ver-go-bin " -noErrors -noRun -prtCmd -prtVar -prtFmt " (upcase (symbol-name path-format)) " -app " app))
              (res-raw     (shell-command-to-string cmd))
              (res-trm     (string-trim res-raw))
              (ret         (split-string res-trm "\n"))
              (            (listp ret))
              (exe-path    (car ret))
              (            (stringp exe-path))
              (            (not (string-empty-p exe-path)))
              (            (or (and (eq system-type 'windows-nt) (or (eq path-format 'RAW) (eq path-format 'UNX)))
                               (file-executable-p exe-path))))
    ret))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;###autoload
(defun mjr-vergo-ok ()
  "Return non-NIL if mjr-vergo-bin seems to be a valid file.
Recommended way to tell if vergo is available:
   (and (featurep 'mjr-vergo)
        (mjr-vergo-ok))"
  (and (boundp 'mjr-vergo-bin)
       (stringp mjr-vergo-bin)
       (file-exists-p mjr-vergo-bin)
       (or (eq system-type 'windows-nt)
           (file-executable-p mjr-vergo-bin))))

(provide 'mjr-vergo)

;;; filename ends here
