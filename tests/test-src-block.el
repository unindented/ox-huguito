;;; test-src-block.el --- Tests regarding source blocks  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Daniel Perez Alvarez

;; Author: Daniel Perez Alvarez <daniel@unindented.org>

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free Software
;; Foundation, either version 3 of the License, or (at your option) any later
;; version.

;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
;; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
;; details.

;; You should have received a copy of the GNU General Public License along with
;; GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(require 'ox-huguito)


;;;; Src block

(ert-deftest ox-huguito/src-block-without-language ()
  "Surrounds source code with backticks."
  (org-test-with-temp-text "
#+title: Some title

#+begin_src
console.log('Hello world!');
#+end_src
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "```\nconsole.log('Hello world!');\n```\n"))))))

(ert-deftest ox-huguito/src-block-with-language ()
  "Adds language to backticks."
  (org-test-with-temp-text "
#+title: Some title

#+begin_src javascript
console.log('Hello world!');
#+end_src
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "```javascript\nconsole.log('Hello world!');\n```"))))))

(ert-deftest ox-huguito/src-block-with-mapped-language ()
  "Maps language if necessary."
  (org-test-with-temp-text "
#+title: Some title

#+begin_src conf-toml
enabled = true
#+end_src
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "```toml\nenabled = true\n```"))))))

(ert-deftest ox-huguito/src-block-with-mapped-language-custom ()
  "Maps language if necessary."
  (org-test-with-temp-text "
#+title: Some title

#+begin_src foo
OHAI
#+end_src
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-src-block-languages '(("foo" . "bar"))))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "```bar\nOHAI\n```"))))))


(provide 'test-src-block)

;;; test-src-block.el ends here
