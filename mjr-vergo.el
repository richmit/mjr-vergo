;; mjr-vergo.el --- verGo.sh wrapper. -*- lexical-binding:t; coding: utf-8; mode:emacs-lisp; fill-column:158 -*-

;; Copyright (c) 2026-2026 Mitch Richling <https://www.mitchr.me>.  All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
;;
;; 1. Redistributions of source code must retain the above copyright notice, this list of conditions, and the following disclaimer.
;;
;; 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions, and the following disclaimer in the documentation
;;    and/or other materials provided with the distribution.
;;
;; 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without
;;    specific prior written permission.
;;
;; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;; SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
;; TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

;; Author:      Mitch Richling
;; Version:     0.18
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
