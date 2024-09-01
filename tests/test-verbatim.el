;;; test-verbatim.el --- Tests regarding code and verbatim elements  -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Daniel Perez Alvarez

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


;;;; Verbatim

(ert-deftest ox-huguito/verbatim ()
  "Surrounds verbatim elements with backticks."
  (org-test-with-temp-text "
#+title: Some title

Some =text=.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some `text`."))))))

(ert-deftest ox-huguito/verbatim-with-kbd ()
  "Surrounds verbatim elements with `kbd' tags if `with-verbatim' is `kbd'."
  (org-test-with-temp-text "
#+title: Some title

Some =text=.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-with-verbatim 'kbd))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some <kbd>text</kbd>."))))))

(ert-deftest ox-huguito/verbatim-with-kbd-options ()
  "Surrounds verbatim elements with `kbd' tags if `with-verbatim' is `kbd'."
  (org-test-with-temp-text "
#+title: Some title
#+options: verbatim:kbd

Some =text=.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some <kbd>text</kbd>."))))))

(ert-deftest ox-huguito/verbatim-with-samp ()
  "Surrounds verbatim elements with `samp' tags if `with-verbatim' is `samp'."
  (org-test-with-temp-text "
#+title: Some title

Some =text=.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-with-verbatim 'samp))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some <samp>text</samp>."))))))

(ert-deftest ox-huguito/verbatim-with-samp-options ()
  "Surrounds verbatim elements with `samp' tags if `with-verbatim' is `samp'."
  (org-test-with-temp-text "
#+title: Some title
#+options: verbatim:samp

Some =text=.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some <samp>text</samp>."))))))


(provide 'test-verbatim)

;;; test-verbatim.el ends here
