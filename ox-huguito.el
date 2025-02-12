;;; ox-huguito.el --- Small Hugo Markdown backend for Org export engine  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Daniel Perez Alvarez

;; Author: Daniel Perez Alvarez <daniel@unindented.org>
;; Created: 19 Aug 2024
;; Version: 0.0.1
;; Keywords: outlines, hypermedia, text
;; Homepage: https://github.com/unindented/ox-huguito
;; Package-Requires: ((emacs "27.1")
;;                    (org "9.3")
;;                    (tomelr "0.4.3"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This library implements a Markdown backend (Hugo flavor) for Org
;; exporter, based on `md' backend.  See Org manual for more
;; information.

;;; Code:

(require 'org-macs)
(org-assert-version)

(require 'cl-lib)
(require 'ox-md)
(require 'ox-publish)

(require 'tomelr)



;;; User-configurable variables

(defgroup org-export-huguito nil
  "Options specific to Hugo Markdown export backend."
  :tag "Org Huguito Markdown"
  :group 'org-export)

(defcustom org-huguito-footnote-format "[^%s]"
  "The format for the footnote reference.
%s will be replaced by the footnote reference itself."
  :group 'org-export-huguito
  :type 'string)

(defcustom org-huguito-footnote-separator "^, ^"
  "Text used to separate footnotes."
  :group 'org-export-huguito
  :type 'string)

(defcustom org-huguito-footnotes-headline t
  "Non-nil means add a headline above the footnotes section."
  :group 'org-export-huguito
  :type 'boolean)

;;;; Front-matter

(defcustom org-huguito-date-timestamp-format "%FT%T%z"
  "Timestamp format string to use for DATE, LAST_MODIFIED, PUBLISH_DATE,
and EXPIRY_DATE keywords.

The format string, when specified, only applies if date consists in a
single timestamp.  Otherwise its value will be ignored.

See `format-time-string' for details on how to build this string."
  :group 'org-export-huguito
  :type 'string)

;;;; Headline

(defcustom org-huguito-headline-levels 5
  "The last level which is still exported as a headline.

Inferior levels will usually produce itemize or enumerate lists when
exported, but backend behavior may differ.

This option can also be set with the OPTIONS keyword, e.g. \"H:2\"."
  :group 'org-export-general
  :type 'integer
  :safe #'integerp)

(defcustom org-huguito-toplevel-hlevel 2
  "Heading level to use for level 1 Org headings.

If this is 1, headline levels will be preserved on export.  If this is
2, top level Org headings will be exported to level 2 Markdown headings,
level 2 Org headings will be exported to level 3 Markdown headings, and
so on.

By default starts at level 2, which better matches Hugo's defaults."
  :group 'org-export-huguito
  :type 'integer)

;;;; Src block

(defcustom org-huguito-src-block-languages
  '(("conf-toml" . "toml"))
  "Alist mapping source block language names to values supported by
Chroma (the syntax highlighter used by Hugo)."
  :group 'org-export-huguito
  :type '(alist :key-type (string :tag "Source block language name")
                :value-type (string :tag "Chroma language name")))

;;;; Verbatim

(defcustom org-huguito-with-verbatim nil
  "Non-nil means wrap verbatim elements in HTML tags.

This can have three different values:
nil     Do not wrap in HTML tags, just backticks.
`kbd'   Wrap in `kbd' tags.
`samp'  Wrap in `samp' tags.

This option can also be set with the OPTIONS keyword,
e.g. \"verbatim:kbd\"."
  :group 'org-export-huguito
  :type '(choice
          (const :tag "Backticks" nil)
          (const :tag "With `kbd' tags" kbd)
          (const :tag "With `samp' tags" samp)))



;;; Define backend

(org-export-define-derived-backend 'huguito 'md
  :menu-entry
  '(?g "Export to Hugo Markdown"
       ((?G "To temporary buffer"
            (lambda (a s v b) (org-huguito-export-as-md a s v)))
        (?g "To file" (lambda (a s v b) (org-huguito-export-to-md a s v)))
        (?o "To file and open"
            (lambda (a s v b)
              (if a (org-huguito-export-to-md t s v)
                (org-open-file (org-huguito-export-to-md nil s v)))))))
  :translate-alist
  '((footnote-reference . org-huguito-footnote-reference)
    (inner-template . org-huguito-inner-template)
    (item . org-huguito-item)
    (latex-fragment . org-huguito-latex-fragment)
    (src-block . org-huguito-src-block)
    (template . org-huguito-template)
    (verbatim . org-huguito-verbatim))
  :options-alist
  '( ; (:property keyword option default behavior)
    (:with-latex nil "tex" org-export-with-latex) ; Override HTML definition
    (:with-smart-quotes nil "'" nil) ; Goldmark takes care of this
    (:with-special-strings nil "-" nil) ; Goldmark takes care of this
    (:with-sub-superscript nil "^" '{}) ; Require curly brackets to avoid ambiguity
    (:with-toc nil "toc" nil) ; Table of contents not supported for now
    (:with-verbatim nil "verbatim" org-huguito-with-verbatim)
    (:headline-levels nil "H" org-huguito-headline-levels) ; Export up to H6
    (:md-toplevel-hlevel nil nil org-huguito-toplevel-hlevel) ; Start at 2 by default
    (:huguito-footnote-format nil nil org-huguito-footnote-format)
    (:huguito-footnote-separator nil nil org-huguito-footnote-separator)
    (:huguito-footnotes-headline nil nil org-huguito-footnotes-headline)
    (:huguito-last-modified "LAST_MODIFIED" nil nil parse)
    (:huguito-publish-date "PUBLISH_DATE" nil nil parse)
    (:huguito-expiry-date "EXPIRY_DATE" nil nil parse)
    (:huguito-date-timestamp-format nil nil org-huguito-date-timestamp-format)
    (:huguito-src-block-languages nil nil org-huguito-src-block-languages)))



;;; Public functions

(defun org-huguito-title-backend (parent &rest transcoders)
  "Return an export backend appropriate for titles.

By default, the backend removes footnote references and targets.  It
also changes links and radio targets into regular text.

PARENT is an export backend the returned backend should inherit from.

TRANSCODERS optional argument, when non-nil, specifies additional
transcoders.  A transcoder follows the pattern (TYPE . FUNCTION) where
type is an element or object type and FUNCTION the function transcoding
it."
  (declare (indent 1))
  (org-export-create-backend
   :parent parent
   :transcoders
   (append transcoders
           `((footnote-reference . ,#'ignore)
             (link . ,(lambda (l c i)
                        (or c
                            (org-export-data
                             (org-element-property :raw-link l)
                             i))))
             (radio-target . ,(lambda (_r c _) c))
             (target . ,#'ignore)))))



;;; Internal functions

(defun org-huguito--fix-timezone-in-date (date-time)
  "Fix timezone in DATE-TIME to follow RFC 3339 format.
DATE-TIME is a date/time formatted as a string."
  (replace-regexp-in-string
   "\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)\\'" "\\1:\\2"
   date-time))

;; Source: https://git.savannah.gnu.org/cgit/emacs/org-mode.git/tree/lisp/ox.el
(defun org-huguito--get-date (property info &optional fmt)
  "Return date PROPERTY for the current document.

INFO is a plist used as a communication channel.  FMT, when non-nil, is
a time format string that will be applied on the date if it consists in
a single timestamp object.  It defaults to
`org-huguito-date-timestamp-format' when nil.

A proper date can be a secondary string, a string or nil.  It is meant
to be translated with `org-export-data' or alike."
  (let ((date (plist-get info property))
        (fmt (or fmt (plist-get info :huguito-date-timestamp-format))))
    (cond ((not date) nil)
          ((and fmt
                (not (cdr date))
                (org-element-type-p (car date) 'timestamp))
           (org-format-timestamp (car date) fmt))
          (t date))))

(defun org-huguito--footnote-label (label)
  "Normalize a footnote LABEL.
If the label is not a number, keep it. Otherwise, discard it, as the
footnotes get re-numbered by `org-export-get-footnote-number'."
  (when (not (and (stringp label)
                  (equal label (number-to-string (string-to-number label)))))
    label))

(defun org-huguito--footnote-formatted (footnote info)
  "Formats a single footnote entry FOOTNOTE.
FOOTNOTE is a cons cell of the form (number . definition).  INFO is a
plist with contextual information."
  (pcase footnote
    (`(,n ,label ,def)
     (let ((normalized-label (org-huguito--footnote-label label)))
       (format "%s: %s\n"
               (format (plist-get info :huguito-footnote-format) 
                       (or normalized-label n))
               (org-trim (org-export-data def info)))))))

(defun org-huguito--footnotes-section (info)
  "Format the footnotes section.
INFO is a plist used as a communication channel."
  (let* ((fn-alist (org-export-collect-footnote-definitions info))
         (has-headline (plist-get info :huguito-footnotes-headline))
         (headline-style (plist-get info :md-headline-style))
         (section-title (org-html--translate "Footnotes" info)))
    (when fn-alist
      (format (plist-get info :md-footnotes-section)
              (if has-headline
                  (org-md--headline-title headline-style (plist-get info :md-toplevel-hlevel) section-title)
                "")
              (mapconcat (lambda (fn) (org-huguito--footnote-formatted fn info))
                         fn-alist
                         "\n")))))

(defun org-huguito--format-list-item (contents type checkbox term counter info)
  "Format a list item into Markdown.
CONTENTS is the item contents.  TYPE is one of symbols `ordered',
`unordered', or `descriptive'.  CHECKBOX is nil or one of
symbols `on', `off', or `trans'.  TERM is nil or a string.  COUNTER is
a number.  INFO is a plist used as a communication channel."
  (let* ((contents (and contents
                        (org-trim (replace-regexp-in-string "^" "    " contents))))
         (checkbox (pcase checkbox
                     (`on "[X] ")
                     (`off "[ ] ")
                     (`trans "[-] ")))
         (term (or term "(no term)"))
         (bullet (pcase type
                   (`ordered (concat counter "."))
                   (`unordered "-")
                   (`descriptive ":")))
         (bullet-filler (make-string (max 1 (- 4 (length bullet))) ? )))
    (concat (if (eq type 'descriptive) (concat term "\n") "")
            bullet
            bullet-filler
            checkbox
            contents)))

(defun org-huguito--front-matter-title (info)
  "Return title to be used in the front-matter.
INFO is a plist used as a communication channel."
  (let ((title (when (plist-get info :with-title)
                 (plist-get info :title))))
    (when title
      (format "%s" (org-export-data-with-backend
                    title
                    (org-huguito-title-backend 'huguito)
                    info)))))

(defun org-huguito--front-matter-date (property info)
  "Return date PROPERTY to be used in the front-matter.
INFO is a plist used as a communication channel."
  (let ((date (when (plist-get info :with-date)
                (org-huguito--get-date property info))))
    (when date
      (org-huguito--fix-timezone-in-date
       (format "%s" (org-export-data
                     date
                     info))))))

(defun org-huguito--front-matter-tags (info)
  "Return title to be used in the front-matter.
INFO is a plist used as a communication channel."
  (let ((tags (when (plist-get info :with-tags)
                org-file-tags)))
    tags))

(defun org-huguito--front-matter (info)
  "Return a plist with all front-matter data.
INFO is a plist used as a communication channel."
  `(:title ,(org-huguito--front-matter-title info)
    :date ,(org-huguito--front-matter-date :date info)
    :lastmod ,(org-huguito--front-matter-date :huguito-last-modified info)
    :publishDate ,(org-huguito--front-matter-date :huguito-publish-date info)
    :expiryDate ,(org-huguito--front-matter-date :huguito-expiry-date info)
    :tags ,(org-huguito--front-matter-tags info)))

(defun org-huguito--front-matter-encoded (info)
  "Encode front-matter data in TOML format.
INFO is a plist used as a communication channel."
  (let ((tomelr-indent-multi-line-strings t))
    (format "+++\n%s\n+++\n" (tomelr-encode
                              (org-huguito--front-matter info)))))



;;; Transcode functions

;;;; Footnote reference

(defun org-huguito-footnote-reference (footnote-reference _contents info)
  "Transcode a FOOTNOTE-REFERENCE element from Org to Markdown.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (concat
   ;; Insert separator between two footnotes in a row.
   (let ((prev (org-export-get-previous-element footnote-reference info)))
     (when (org-element-type-p prev 'footnote-reference)
       (plist-get info :huguito-footnote-separator)))
   (let* ((n (org-export-get-footnote-number footnote-reference info))
          (label (org-huguito--footnote-label (org-element-property :label footnote-reference))))
     (format
      (plist-get info :huguito-footnote-format)
      (or label n)))))

;;;; Item

(defun org-huguito-item (item contents info)
  "Transcode ITEM element into Markdown format.
CONTENTS is the item contents.  INFO is a plist used as
a communication channel."
  (let* ((plain-list (org-element-parent item))
         (type (org-element-property :type plain-list))
         (checkbox (org-element-property :checkbox item))
         (tag (let ((tag (org-element-property :tag item)))
                (and tag (org-export-data tag info))))
         (counter (let ((struct (org-element-property :structure item)))
                    (number-to-string
                     (car (last (org-list-get-item-number
                                 (org-element-property :begin item)
                                 struct
                                 (org-list-prevs-alist struct)
                                 (org-list-parents-alist struct))))))))
    (org-huguito--format-list-item
     contents type checkbox tag counter info)))

;;;; LaTeX fragment

(defun org-huguito-latex-fragment (latex-fragment _contents info)
  "Transcode a LATEX-FRAGMENT object from Org to Markdown.
CONTENTS is nil.  INFO is a plist holding contextual information."
  (when (plist-get info :with-latex)
    (let ((frag (org-element-property :value latex-fragment)))
      (cond
       ((string-match-p "^\\$\\$" frag)
        (concat "\\[" (substring frag 2 -2) "\\]"))
       ((string-match-p "^\\$" frag)
        (concat "\\( " (substring frag 1 -1) " \\)"))
       (t frag)))))

;;;; Src block

(defun org-huguito-src-block (src-block _contents info)
  "Transcode SRC-BLOCK element into Markdown format.
CONTENTS is nil.  INFO is a plist used as a communication channel."
  (let* ((code (org-remove-indentation
                (org-export-format-code-default src-block info)))
         (lang-map (plist-get info :huguito-src-block-languages))
         (lang (org-element-property :language src-block))
         (mapped-lang (or (cdr (assoc lang lang-map)) lang)))
    (format "```%s\n%s```\n" (or mapped-lang "") code)))

;;;; Template

(defun org-huguito-inner-template (contents info)
  "Return body of document after converting it to Markdown syntax.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  ;; Make sure CONTENTS is separated from table of contents and
  ;; footnotes with at least a blank line.
  (concat
   ;; Table of contents.
   (let ((depth (plist-get info :with-toc)))
     (when depth
       (concat (org-md--build-toc info (and (wholenump depth) depth)) "\n")))
   ;; Document contents.
   contents
   "\n"
   ;; Footnotes section.
   (org-huguito--footnotes-section info)))

(defun org-huguito-template (contents info)
  "Return complete document string after Markdown conversion.
CONTENTS is the transcoded contents string.  INFO is a plist used as a
communication channel."
  (concat
   ;; Front matter.
   (org-huguito--front-matter-encoded info)
   "\n\n"
   ;; Contents.
   contents))

;;;; Verbatim

(defun org-huguito-verbatim (verbatim contents info)
  "Transcode VERBATIM object into Markdown format.

If `org-huguito-with-verbatim' is non-nil, wrap in the corresponding
tags.

CONTENTS is nil.  INFO is a plist used as a communication channel."
  (let ((tag (plist-get info :with-verbatim)))
    (if tag
        (format "<%s>%s</%s>"
                tag
                (org-element-property :value verbatim)
                tag)
      (org-md-verbatim verbatim contents info))))



;;; Interactive functions

;;;###autoload
(defun org-huguito-export-as-md (&optional async subtreep visible-only)
  "Export current buffer to a Hugo Markdown buffer.

If narrowing is active in the current buffer, only export its narrowed
part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting buffer should be accessible through the
`org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree at
point, extracting information from the headline properties first.

When optional argument VISIBLE-ONLY is non-nil, don't export contents of
hidden elements.

Export is done in a buffer named \"*Org Hugo Markdown Export*\", which
will be displayed when `org-export-show-temporary-export-buffer' is
non-nil."
  (interactive)
  (org-export-to-buffer 'huguito "*Org Huguito Markdown Export*"
    async subtreep visible-only nil nil (lambda () (text-mode))))

;;;###autoload
(defun org-huguito-convert-region-to-md ()
  "Assume the current region has Org syntax, and convert it to Hugo
Markdown.

This can be used in any buffer.  For example, you can write an itemized
list in Org syntax in a Markdown buffer and use this command to convert
it."
  (interactive)
  (org-export-replace-region-by 'huguito))

;;;###autoload
(defun org-huguito-export-to-md (&optional async subtreep visible-only)
  "Export current buffer to a Hugo Markdown file.

If narrowing is active in the current buffer, only export its narrowed
part.

If a region is active, export that region.

A non-nil optional argument ASYNC means the process should happen
asynchronously.  The resulting file should be accessible through the
`org-export-stack' interface.

When optional argument SUBTREEP is non-nil, export the sub-tree at
point, extracting information from the headline properties first.

When optional argument VISIBLE-ONLY is non-nil, don't export contents of
hidden elements.

Return output file's name."
  (interactive)
  (let ((outfile (org-export-output-file-name ".md" subtreep)))
    (org-export-to-file 'huguito outfile async subtreep visible-only)))

;;;###autoload
(defun org-huguito-publish-to-md (plist filename pub-dir)
  "Publish an Org file to Hugo Markdown.

FILENAME is the filename of the Org file to be published.  PLIST is the
property list for the given project.  PUB-DIR is the publishing
directory.

Return output file name."
  (org-publish-org-to 'huguito filename ".md" plist pub-dir))


(provide 'ox-huguito)

;;; ox-huguito.el ends here
