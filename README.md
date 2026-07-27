# mjr-vergo

<!-- SHELLO: sed -n "/;;; Commentary:/,/;;; Code:/p" mjr-vergo.el | head -n -2 | tail -n '+3' | sed 's/^;*//'
-->

 mjr-vergo provides a very simple Emacs interface to the verGo.sh shell script (https://github.com/richmit/verGo).

 While the verGo.sh shell script is focused on running applications, the mjr-vergo Emacs package is focused on reporting on applications (executable and
 environment variables).  I make extensive use of mjr-vergo in my Emacs dot file to locate various applications.

 If we run verGo.sh from the command line looking for lisp with my dotfiles, we get something like this:

      $ verGo.sh -noErrors -noRun -prtCmd -prtVar -prtFmt RAW lisp

      /c/Program Files/Steel Bank Common Lisp/sbcl.exe
      SBCL_HOME=C:\\Program Files\\Steel Bank Common Lisp\\

 I ran this on Windows inside an MSYS2 (https://www.msys2.org/) shell environment to illustrate some of the complexity verGo.sh & mjr-vergo deal with.  The
 first line is the location of the executable.  Note the characteristic "/c/" full path name.  The second line is an environment variable that must be set
 in order for this application to run.  Note the Windows style path required because the value is going to be consumed by a Windows SCBL binary.

 Inside of Emacs we can do something very similar:

      (mjr-vergo "lisp" 'RAW)

      ("/c/Program Files/Steel Bank Common Lisp/sbcl.exe" 
       "SBCL_HOME=C:\Program Files\Steel Bank Common Lisp\")

 mjr-vergo returns a list.  The first element is the executable and the remaining are environment variables.  Note the 'RAW argument.  By default mjr-vergo
 produces 'MIX type executable path names because most of the time in Emacs we need platform specific paths for binaries -- i.e. even if Emacs is running on
 MSYS2, it uses windows style paths to run commands instead of MSYS2 bash style paths.  Here is an example:

      (mjr-vergo "lisp")
      ("C:/Program Files/Steel Bank Common Lisp/sbcl.exe" 
       "SBCL_HOME=C:\Program Files\Steel Bank Common Lisp\")

 The easiest way to install mjr-vergo is to pull it directly from github:

      (package-vc-install (list 'mjr-vergo
                           :url "https://github.com/richmit/mjr-vergo"
                           :rev 'newest))

 You can also just down load the primary lisp file, load it into a buffer, and then run 'M-x package-install-from-buffer'.
