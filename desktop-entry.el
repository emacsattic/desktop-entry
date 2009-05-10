;;; desktop-entry.el --- Parse .desktop files for MIME information

;; Copyright (C) 2005  Alan Shutko

;; Author: Alan Shutko <ats@acm.org>
;; Keywords: news, mail, multimedia

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; 

;;; Code:

(defun desktop-entry-parse-desktop (file)
  "Parse a .desktop file, returning a list of mailcap-mime-data entry."
  (save-excursion 
    (with-temp-buffer
      (let ((mime-types)
	    (viewer))
	(insert-file-contents file)
	(goto-char (point-min))
	(while (re-search-forward "^\\(Exec\\|MimeType\\)=\\(.*\\)$" nil t)
	  (let ((key (match-string 1))
		(value (match-string 2)))
	    (cond ((equal key "Exec")
		   (setf viewer (desktop-entry-translate-parameters value)))
		  ((equal key "MimeType")
		   (setf mime-types (desktop-entry-parse-mimetypes value))))))
	(mapc (lambda (type)
		(if (not (string= "" type))
		    (mailcap-add type viewer '(getenv "DISPLAY"))))
	      mime-types)))))

(defun desktop-entry-translate-parameters (exec-string)
  (replace-regexp-in-string "[%]." "%s" exec-string t))

(defun desktop-entry-parse-mimetypes (mime-string)
  "Parse a ;-delimited list of mime-types"
  (split-string mime-string ";"))

(defun desktop-entry-add-entries (directory)
  "Add mailcap entries for all .desktop files in a directory"
  (mapc 'desktop-entry-parse-desktop
	(directory-files directory t "\\.desktop\\'")))

(provide 'desktop-entry)
;;; desktop-entry.el ends here

