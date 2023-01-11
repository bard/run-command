;;; run-command.el --- Run an external command from a context-dependent list -*- lexical-binding: t -*-

;; Copyright (C) 2020-2023 Massimiliano Mirra

;; Author: Massimiliano Mirra <hyperstruct@gmail.com>
;; URL: https://github.com/bard/emacs-run-command
;; Version: 0.1.0
;; Package-Requires: ((emacs "27.1"))
;; Keywords: processes

;; This file is not part of GNU Emacs

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Leave Emacs less.  Relocate those frequent shell commands to configurable,
;; dynamic, context-sensitive lists, and run them at a fraction of the
;; keystrokes with autocompletion.

;;; Code:

(require 'run-command-core)
(require 'run-command-selector-helm)
(require 'run-command-selector-ivy)
(require 'run-command-selector-completing-read)
(require 'run-command-runner-term)
(require 'run-command-runner-compile)
(require 'run-command-runner-vterm)
(require 'run-command-runner-eat)

;; Entry point

;;###autoload
(defun run-command ()
  "Pick a command from a context-dependent list, and run it.

The command list is generated by running the functions configured in
`run-command-recipes'."
  (interactive)
  (run-command--check-experiments)
  (when (not run-command-recipes)
    (error "[run-command] Please customize `run-command-recipes' in order to use `run-command'"))
  
  (let ((run-command-default-runner
         (or run-command-default-runner
             (pcase run-command-run-method
               ('compile 'run-command-runner-compile)
               ('term 'run-command-runner-term)
               ('vterm 'run-command-runner-vterm)
               (_ (error "[run-command] Unrecognized run method: %s"
                         run-command-completion-method)))))

        (run-command-selector
         (pcase run-command-completion-method
           ('auto
            (cond ((and (boundp 'helm-mode) helm-mode)
                   'run-command-selector-helm)
                  ((and (boundp 'ivy-mode) ivy-mode)
                   'run-command-selector-ivy)
                  (t 'run-command-selector-completing-read)))
           ('helm 'run-command-selector-helm)
           ('ivy 'run-command-selector-ivy)
           ('completing-read 'run-command-selector-completing-read)
           (_ (error "[run-command] Unrecognized completion method: %s"
                     run-command-completion-method)))))
    
    (funcall run-command-selector run-command-recipes)))

;;; Meta

(provide 'run-command)

;;; run-command.el ends here
