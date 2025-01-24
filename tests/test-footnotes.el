;;; test-footnotes.el --- Tests regarding footnotes  -*- lexical-binding: t; -*-

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


;;;; Code

(ert-deftest ox-huguito/footnotes-numeric-ordered ()
  "Exports numeric footnotes that were ordered."
  (org-test-with-temp-text "
#+title: Some title

Some text[fn:1] and some more text[fn:2].

[fn:1] Some footnote.

[fn:2] Some other footnote.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some text[^1] and some more text[^2]."))
        (should (search-forward "## Footnotes"))
        (should (search-forward "[^1]: Some footnote."))
        (should (search-forward "[^2]: Some other footnote."))))))

(ert-deftest ox-huguito/footnotes-numeric-unordered ()
  "Reorders numeric footnotes that were not ordered."
  (org-test-with-temp-text "
#+title: Some title

Some text[fn:2] and some more text[fn:1].

[fn:1] Some other footnote.

[fn:2] Some footnote.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some text[^1] and some more text[^2]."))
        (should (search-forward "## Footnotes"))
        (should (search-forward "[^1]: Some footnote."))
        (should (search-forward "[^2]: Some other footnote."))))))

(ert-deftest ox-huguito/footnotes-alpha-ordered ()
  "Exports alpha footnotes that were ordered."
  (org-test-with-temp-text "
#+title: Some title

Some text[fn:foo] and some more text[fn:bar].

[fn:foo] Some footnote.

[fn:bar] Some other footnote.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some text[^foo] and some more text[^bar]."))
        (should (search-forward "## Footnotes"))
        (should (search-forward "[^foo]: Some footnote."))
        (should (search-forward "[^bar]: Some other footnote."))))))

(ert-deftest ox-huguito/footnotes-alpha-unordered ()
  "Reorders alpha footnotes that were not ordered."
  (org-test-with-temp-text "
#+title: Some title

Some text[fn:bar] and some more text[fn:foo].

[fn:foo] Some other footnote.

[fn:bar] Some footnote.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some text[^bar] and some more text[^foo]."))
        (should (search-forward "## Footnotes"))
        (should (search-forward "[^bar]: Some footnote."))
        (should (search-forward "[^foo]: Some other footnote."))))))

(ert-deftest ox-huguito/footnotes-inline-anonymous ()
  "Reorders anonymous inline footnotes."
  (org-test-with-temp-text "
#+title: Some title

Some text[fn:: Some footnote.] and some more text[fn:: Some other footnote.].
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some text[^1] and some more text[^2]."))
        (should (search-forward "## Footnotes"))
        (should (search-forward "[^1]: Some footnote."))
        (should (search-forward "[^2]: Some other footnote."))))))

(ert-deftest ox-huguito/footnotes-inline-named ()
  "Reorders named inline footnotes."
  (org-test-with-temp-text "
#+title: Some title

Some text[fn:foo: Some footnote.] and some more text[fn:bar: Some other footnote.].
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some text[^foo] and some more text[^bar]."))
        (should (search-forward "## Footnotes"))
        (should (search-forward "[^foo]: Some footnote."))
        (should (search-forward "[^bar]: Some other footnote."))))))

(ert-deftest ox-huguito/footnotes-consecutive-separator ()
  "Adds a separator between consecutive footnotes."
  (org-test-with-temp-text "
#+title: Some title

Some text[fn:1][fn:2].

[fn:1] Some footnote.

[fn:2] Some other footnote.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some text[^1]^, ^[^2]."))
        (should (search-forward "## Footnotes"))
        (should (search-forward "[^1]: Some footnote."))
        (should (search-forward "[^2]: Some other footnote."))))))

(ert-deftest ox-huguito/footnotes-without-headline ()
  "Does not add a headline to the footnotes section if `huguito-footnotes-headline' is nil."
  (org-test-with-temp-text "
#+title: Some title

Some text[fn:1].

[fn:1] Some footnote.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-footnotes-headline nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some text[^1]."))
        (should-error (search-forward "## Footnotes"))))))


(provide 'test-footnotes)

;;; test-footnotes.el ends here
