;;; test-format.el --- Tests regarding formatting  -*- lexical-binding: t; -*-

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


;;;; Smart quotes

(ert-deftest ox-huguito/no-smart-quotes ()
  "Does not activate smart quotes."
  (org-test-with-temp-text "
#+title: Some title

Here's some 'quotes'.
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Here's some 'quotes'"))))))

;;;; Special strings

(ert-deftest ox-huguito/no-special-strings ()
  "Does not interpret special strings."
  (org-test-with-temp-text "
#+title: Some title

Some -- special --- strings...
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "Some -- special --- strings..."))))))

;;;; Subscripts and superscripts

(ert-deftest ox-huguito/sub-superscripts-with-curly-brackets ()
  "Only interprets subcripts and superscripts if surrounded by curly brackets."
  (org-test-with-temp-text "
#+title: Some title

H_2O H_{2}O m^2 m^{2}
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "H\\_2O H<sub>2</sub>O m^2 m<sup>2</sup>"))))))


(provide 'test-format)

;;; test-format.el ends here
