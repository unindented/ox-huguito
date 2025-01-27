;;; test-lists.el --- Tests regarding lists  -*- lexical-binding: t; -*-

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

(ert-deftest ox-huguito/unordered-list-dashes ()
  "Exports an unordered list."
  (org-test-with-temp-text "
#+title: Some title

- Item 1
- Item 2
  - Item 2.1
    - Item 2.1.1
  - Item 2.2
- Item 3
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "-   Item 1"))
        (should (search-forward "-   Item 2"))
        (should (search-forward "    -   Item 2.1"))
        (should (search-forward "        -   Item 2.1.1"))
        (should (search-forward "    -   Item 2.2"))
        (should (search-forward "-   Item 3"))))))

(ert-deftest ox-huguito/unordered-list-pluses ()
  "Exports an unordered list."
  (org-test-with-temp-text "
#+title: Some title

+ Item 1
+ Item 2
  + Item 2.1
    + Item 2.1.1
  + Item 2.2
+ Item 3
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "-   Item 1"))
        (should (search-forward "-   Item 2"))
        (should (search-forward "    -   Item 2.1"))
        (should (search-forward "        -   Item 2.1.1"))
        (should (search-forward "    -   Item 2.2"))
        (should (search-forward "-   Item 3"))))))

(ert-deftest ox-huguito/ordered-list ()
  "Exports an ordered list."
  (org-test-with-temp-text "
#+title: Some title

1. Item 1
2. Item 2
  1. Item 2.1
    1. Item 2.1.1
  2. Item 2.2
3. Item 3
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "1.  Item 1"))
        (should (search-forward "2.  Item 2"))
        (should (search-forward "    1.  Item 2.1"))
        (should (search-forward "        1.  Item 2.1.1"))
        (should (search-forward "    2.  Item 2.2"))
        (should (search-forward "3.  Item 3"))))))

(ert-deftest ox-huguito/mixed-list ()
  "Exports an ordered list."
  (org-test-with-temp-text "
#+title: Some title

1. Item 1
2. Item 2
  + Item 2.1
    - Item 2.1.1
  + Item 2.2
3. Item 3
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "1.  Item 1"))
        (should (search-forward "2.  Item 2"))
        (should (search-forward "    -   Item 2.1"))
        (should (search-forward "        -   Item 2.1.1"))
        (should (search-forward "    -   Item 2.2"))
        (should (search-forward "3.  Item 3"))))))

(ert-deftest ox-huguito/definition-list ()
  "Exports a definition list."
  (org-test-with-temp-text "
#+title: Some title

- Foo :: Item 1
- Bar :: Item 2
- Baz :: Item 3
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Foo"))
        (should (search-forward ":   Item 1"))
        (should (search-forward "Bar"))
        (should (search-forward ":   Item 2"))
        (should (search-forward "Baz"))
        (should (search-forward ":   Item 3"))))))

(ert-deftest ox-huguito/task-list ()
  "Exports a task list."
  (org-test-with-temp-text "
#+title: Some title

- [-] Call people
  - [ ] Peter
  - [X] Sarah
  - [ ] Sam
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "-   [-] Call people"))
        (should (search-forward "    -   [ ] Peter"))
        (should (search-forward "    -   [X] Sarah"))
        (should (search-forward "    -   [ ] Sam"))))))


(provide 'test-lists)

;;; test-lists.el ends here
