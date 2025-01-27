;;; all-tests.el --- Tests for ox-huguito.el  -*- lexical-binding: t; -*-

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

(require 'package)

(setq package-user-dir (file-truename (concat default-directory ".packages")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(require 'vc-git)

(let ((ox-huguito-git-root (file-truename (vc-git-root default-directory))))
  (package-install-file (expand-file-name "ox-huguito.el" ox-huguito-git-root)))

(require 'test-code)
(require 'test-footnotes)
(require 'test-format)
(require 'test-front-matter)
(require 'test-headlines)
(require 'test-latex)
(require 'test-links)
(require 'test-lists)
(require 'test-src-block)
(require 'test-verbatim)

;;; all-tests.el ends here
