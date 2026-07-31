;;; el-vergo.el --- verGo.sh wrapper. -*- lexical-binding:t; coding: utf-8; mode:emacs-lisp; fill-column:158 -*-

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

;; Author:      Mitch Richling <https://www.mitchr.me>
;; Version:     0.22
;; Keywords:    verGo
;; URL:         https://github.com/richmit/el-vergo

;; This file is not part of Emacs

;;; Commentary:
;;
;; Official Repository: https://github.com/richmit/el-vergo
;;
;; `el-vergo' provides a very simple Emacs interface to the verGo.sh shell script (https://github.com/richmit/verGo).
;;
;; While the verGo.sh shell script is focused on running applications, the `el-vergo' Emacs package is focused on reporting on applications (executable and
;; environment variables).  I make extensive use of `el-vergo' in my Emacs dotfiles to locate various extneral tools.
;;
;; If we run verGo.sh from the command line looking for Lisp with my dotfiles, we get something like this:
;;
;;      $ verGo.sh -noErrors -noRun -prtCmd -prtVar -prtFmt RAW lisp
;;
;;      /c/Program Files/Steel Bank Common Lisp/sbcl.exe
;;      SBCL_HOME=C:\\Program Files\\Steel Bank Common Lisp\\
;;
;; I ran this on Windows inside an MSYS2 (https://www.msys2.org/) shell environment to illustrate some of the complexity verGo.sh & `el-vergo' deal with.
;; The first line is the location of the executable.  Note the characteristic "/c/" full path name.  The second line is an environment variable that must be
;; set in order for this application to run.  Note the Windows style path required because the value is going to be consumed by a Windows SCBL binary.
;;
;; Inside of Emacs we can do something very similar:
;;
;;      (el-vergo "lisp" 'RAW)
;;
;;      ("/c/Program Files/Steel Bank Common Lisp/sbcl.exe"
;;       "SBCL_HOME=C:\Program Files\Steel Bank Common Lisp\")
;;
;; `el-vergo' returns a list.  The first element is the executable and the remaining are environment variables.  Note the 'RAW argument.  By default
;; `el-vergo' produces 'MIX type executable path names because most of the time in Emacs we need platform specific paths for binaries -- i.e. even if Emacs
;; is running on MSYS2, it uses windows style paths to run commands instead of MSYS2 bash style paths.  Here is an example:
;;
;;      (el-vergo "lisp")
;;
;;      ("C:/Program Files/Steel Bank Common Lisp/sbcl.exe"
;;       "SBCL_HOME=C:\Program Files\Steel Bank Common Lisp\")
;;
;; The easiest way to install `el-vergo' is to pull it directly from github:
;;
;;      (package-vc-install (list 'el-vergo
;;                           :url "https://github.com/richmit/el-vergo"
;;                           :rev 'newest))
;;
;; You can also just download the primary lisp file, load it into a buffer, and then run 'M-x package-install-from-buffer'.

;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;###autoload
(defgroup el-vergo nil
  "Access verGo.sh from Emacs."
  :group 'external
  :group 'environment)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;###autoload
(defcustom el-vergo-bin (locate-file "verGo.sh" exec-path)
  "File to use for vreGo.sh."
  :type 'file
  :group 'el-vergo)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;###autoload
(defun el-vergo (app &optional path-format)
  "Use verGo.sh to find a binary and environment variables (list of strings).

Arguments:
  - PATH-FORMAT .. A symbol matching one of the values verGo.sh accepts for -prtFmt command line option
                   If this argument is missing, or invalid, then 'MIX is used.
  - APP .......... A string containing the application to search for

Return:
  - NIL is returned if anything goes wrong -- no errors are raised.
  - A list with the first element being the path to the applicaiton and remaining values being
    environment variables."
  (when-let* ((path-format (or (car (member path-format '(RAW UNIX WIN DOS MIX)))
                               'MIX))
              (ver-go-bin  el-vergo-bin)
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
(defun el-vergo-ok ()
  "Return non-NIL if `el-vergo-bin' seems to be a valid file.
Recommended way to tell if vergo is available:
   (and (featurep 'el-vergo)
        (el-vergo-ok))"
  (and (boundp 'el-vergo-bin)
       (stringp el-vergo-bin)
       (file-exists-p el-vergo-bin)
       (or (eq system-type 'windows-nt)
           (file-executable-p el-vergo-bin))))

(provide 'el-vergo)

;;; el-vergo.el ends here
