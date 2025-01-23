;;; test-headlines.el --- Tests regarding headlines  -*- lexical-binding: t; -*-

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


;;;; Headline levels

(ert-deftest ox-huguito/headline-levels ()
  "Exports headlines up to H6."
  (org-test-with-temp-text "
#+title: Some title

* Level 2
** Level 3
*** Level 4
**** Level 5
***** Level 6
****** Level 7
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "## Level 2"))
        (should (search-forward "### Level 3"))
        (should (search-forward "#### Level 4"))
        (should (search-forward "##### Level 5"))
        (should (search-forward "###### Level 6"))
        (should (search-forward "1.  Level 7"))))))

(ert-deftest ox-huguito/headline-levels-custom ()
  "Exports headlines up to custom level."
  (org-test-with-temp-text "
#+title: Some title

* Level 2
** Level 3
1.  Level 4
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-headline-levels 3))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "## Level 2"))
        (should (search-forward "### Level 3"))
        (should (search-forward "1.  Level 4"))))))

(ert-deftest ox-huguito/toplevel-hlevel ()
  "Starts headlines at level 2."
  (org-test-with-temp-text "
#+title: Some title

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "## Some heading"))))))

(ert-deftest ox-huguito/toplevel-hlevel-custom ()
  "Starts headlines at custom level."
  (org-test-with-temp-text "
#+title: Some title

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-toplevel-hlevel 1))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "# Some heading"))))))

;;;; Table of contents

(ert-deftest ox-huguito/no-toc ()
  "Does not generate a table of contents."
  (org-test-with-temp-text "
#+title: Some title

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "# Table of contents"))))))


(provide 'test-headlines)

;;; test-headlines.el ends here
