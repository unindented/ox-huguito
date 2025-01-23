;;; test-front-matter.el --- Tests regarding front-matter  -*- lexical-binding: t; -*-

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


;;;; Title

(ert-deftest ox-huguito/front-matter-title ()
  "Front-matter includes title."
  (org-test-with-temp-text "
#+title: Some title

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\ntitle = \"Some title\"\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-title-bold ()
  "Front-matter includes title with bold."
  (org-test-with-temp-text "
#+title: Some title with *bold*

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\ntitle = \"Some title with **bold**\"\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-title-italics ()
  "Front-matter includes title with italics."
  (org-test-with-temp-text "
#+title: Some title with /italics/

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\ntitle = \"Some title with *italics*\"\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-title-link ()
  "Front-matter converts title with a link into regular text."
  (org-test-with-temp-text "
#+title: Some title with [[http://example.com][a link]]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\ntitle = \"Some title with a link\"\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-without-title ()
  "Front-matter does not include title if `with-title' is nil."
  (org-test-with-temp-text "
#+title: Some title

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-export-with-title nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "+++\ntitle ="))))))


;;;; Date

(ert-deftest ox-huguito/front-matter-date ()
  "Front-matter includes date."
  (org-test-with-temp-text "
#+date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\ndate = 2024-08-16T07:16:00-07:00\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-date-format ()
  "Front-matter formats date according to `org-huguito-date-timestamp-format'."
  (org-test-with-temp-text "
#+date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-date-timestamp-format "%F"))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\ndate = 2024-08-16\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-date-with-date-nil ()
  "Front-matter does not include date if `with-date' is nil."
  (org-test-with-temp-text "
#+date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-export-with-date nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "+++\ndate ="))))))


;;;; Last modified

(ert-deftest ox-huguito/front-matter-last-modified ()
  "Front-matter includes last modified."
  (org-test-with-temp-text "
#+last_modified: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\nlastmod = 2024-08-16T07:16:00-07:00\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-last-modified-format ()
  "Front-matter formats last modified according to `org-huguito-date-timestamp-format'."
  (org-test-with-temp-text "
#+last_modified: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-date-timestamp-format "%F"))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\nlastmod = 2024-08-16\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-last-modified-with-date-nil ()
  "Front-matter does not include last modified if `with-date' is nil."
  (org-test-with-temp-text "
#+last_modified: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-export-with-date nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "+++\nlastmod ="))))))


;;;; Publish date

(ert-deftest ox-huguito/front-matter-publish-date ()
  "Front-matter includes publish date."
  (org-test-with-temp-text "
#+publish_date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\npublishDate = 2024-08-16T07:16:00-07:00\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-publish-date-format ()
  "Front-matter formats publish date according to `org-huguito-date-timestamp-format'."
  (org-test-with-temp-text "
#+publish_date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-date-timestamp-format "%F"))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\npublishDate = 2024-08-16\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-publish-date-with-date-nil ()
  "Front-matter does not include publish date if `with-date' is nil."
  (org-test-with-temp-text "
#+publish_date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-export-with-date nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "+++\npublishDate ="))))))


;;;; Expiry date

(ert-deftest ox-huguito/front-matter-expiry-date ()
  "Front-matter includes expiry date."
  (org-test-with-temp-text "
#+expiry_date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\nexpiryDate = 2024-08-16T07:16:00-07:00\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-expiry-date-format ()
  "Front-matter formats expiry date according to `org-huguito-date-timestamp-format'."
  (org-test-with-temp-text "
#+expiry_date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-huguito-date-timestamp-format "%F"))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\nexpiryDate = 2024-08-16\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-expiry-date-with-date-nil ()
  "Front-matter does not include expiry date if `with-date' is nil."
  (org-test-with-temp-text "
#+expiry_date: [2024-08-16 Fri 07:16]

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-export-with-date nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "+++\nexpiryDate ="))))))


;;;; Tags

(ert-deftest ox-huguito/front-matter-filetags ()
  "Front-matter includes tags."
  (org-test-with-temp-text "
#+filetags: :emacs:hugo:org:

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\ntags = [\"emacs\", \"hugo\", \"org\"]\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-filetags-case ()
  "Front-matter respects the case of tags."
  (org-test-with-temp-text "
#+filetags: :Emacs:Hugo:Org:

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should (search-forward "+++\ntags = [\"Emacs\", \"Hugo\", \"Org\"]\n+++\n\n"))))))

(ert-deftest ox-huguito/front-matter-filetags-with-tags-nil ()
  "Front-matter does not include tags if `with-tags' is nil."
  (org-test-with-temp-text "
#+filetags: :emacs:hugo:org:

* Some heading
"
    (let ((export-buffer "*Test Export*")
          (org-export-show-temporary-export-buffer nil)
          (org-export-with-tags nil))
      (org-export-to-buffer 'huguito export-buffer)
      (with-current-buffer export-buffer
        (goto-char (point-min))
        (should-error (search-forward "+++\ntags ="))))))


(provide 'test-front-matter)

;;; test-front-matter.el ends here
