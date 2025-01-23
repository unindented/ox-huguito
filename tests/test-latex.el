;;; test-latex.el --- Tests regarding LaTeX  -*- lexical-binding: t; -*-

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


;;;; LaTeX fragments

(ert-deftest ox-huguito/latex-fragment-no-display-parentheses ()
  "Uses `\\(' and `\\)' as delimiters for LaTeX fragments not in display mode."
  (org-test-with-temp-text "
#+title: Some title

\\( e^{i\\pi} + 1 = 0 \\)
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "\\( e^{i\\pi} + 1 = 0 \\)"))))))

(ert-deftest ox-huguito/latex-fragment-no-display-dollars ()
  "Uses `\\(' and `\\)' as delimiters for LaTeX fragments not in display mode."
  (org-test-with-temp-text "
#+title: Some title

$e^{i\\pi} + 1 = 0$
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "\\( e^{i\\pi} + 1 = 0 \\)"))))))

(ert-deftest ox-huguito/latex-fragment-no-display-with-latex-nil ()
  "Does not output LaTeX fragments if `with-latex' is nil."
  (org-test-with-temp-text "
#+title: Some title

$e^{i\\pi} + 1 = 0$
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-export-with-latex nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "\\( e^{i\\pi} + 1 = 0 \\)"))))))

(ert-deftest ox-huguito/latex-fragment-display-square-brackets ()
  "Uses `\\[' and `\\]' as delimiters for LaTeX fragments in display mode."
  (org-test-with-temp-text "
#+title: Some title

\\[
\\frac{n!}{k!(n-k)!} = \\binom{n}{k}
\\]
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "\\[\n\\frac{n!}{k!(n-k)!} = \\binom{n}{k}\n\\]"))))))

(ert-deftest ox-huguito/latex-fragment-display-dollars ()
  "Uses `\\[' and `\\]' as delimiters for LaTeX fragments in display mode."
  (org-test-with-temp-text "
#+title: Some title

$$
\\frac{n!}{k!(n-k)!} = \\binom{n}{k}
$$
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "\\[\n\\frac{n!}{k!(n-k)!} = \\binom{n}{k}\n\\]"))))))

(ert-deftest ox-huguito/latex-fragment-display-with-latex-nil ()
  "Does not output LaTeX fragments if `with-latex' is nil."
  (org-test-with-temp-text "
#+title: Some title

$$
\\frac{n!}{k!(n-k)!} = \\binom{n}{k}
$$
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-export-with-latex nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "\\[\n\\frac{n!}{k!(n-k)!} = \\binom{n}{k}\n\\]"))))))


(provide 'test-latex)

;;; test-latex.el ends here
