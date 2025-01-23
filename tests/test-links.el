;;; test-links.el --- Tests regarding links  -*- lexical-binding: t; -*-

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


;;;; Link

(ert-deftest ox-huguito/link-prefix ()
  "Translates link with `file:' prefix to `.org' file into link to `.md' file."
  (org-test-with-temp-text "
#+title: Some title

Link to [[file:file.org][my file]]
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Link to [my file](file.md)"))))))

(ert-deftest ox-huguito/link-no-prefix ()
  "Translates link without prefix to `.org' file into link to `.md' file."
  (org-test-with-temp-text "
#+title: Some title

Link to [[./file.org][my file]]
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "[my file](./file.md)"))))))


(provide 'test-links)

;;; test-links.el ends here
