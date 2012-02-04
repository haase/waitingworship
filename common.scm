;;; -*- Mode: Scheme; character-encoding: utf-8; -*-

;;; Copyright (C) 2012 Ken Haase.  All rights reserved.

(use-module '{texttools fdweb xhtml extdb mysql crypto
	      updatefile xhtml/include})

(define waiting.html (get-component "waiting.html"))
(define enter.html (get-component "enter.html"))
(define prepare.html (get-component "prepare.html"))

(define-init sql/typemap #[])

(define sql-cert (get-component "sqlcert.pem"))

(define sqldb
  (mysql/open (config 'ww:sqlhost "localhost")
	      (config 'ww:sqldb "ww")
	      sql/typemap
	      (config 'ww:sqluser "root")
	      (config 'ww:sqlpass "")
	      (if (config 'WW:SSLDB #t)
		  `#[SSLCA ,sql-cert]
		  #[])))

(define sql/getspace
  (extdb/proc sqldb "SELECT * FROM spaces WHERE uuid=?" sql/typemap))
(define (getspace input)
  (if (string? input)
      (if (string-strings-with? input "/")
	  (sql/getspace (getuuid (subseq input 1)))
	  (sql/getspace (getuuid input)))
      (if (uuid? input) (sql/getspace input)
	  (error "Bad space identifier"))))

(define sql/newspace
  (extdb/proc sqldb
    "INSERT INTO SPACES (uuid,name,about) VALUES (?,?,?)"
    sql/typemap))
(define sql/newspace+mural
  (extdb/proc sqldb
    "INSERT INTO SPACES (name,uuid,about,mural) VALUES (?,?,?,?)"
    sql/typemap))
(define (newspace name (uuid (getuuid)) (about #f) (mural #f))
  (if mural
      (sql/newspace+mural name uuid (qc (or about {})) mural)
      (sql/newspace name uuid (qc (or about {}))))
  uuid)

(define sql/getministers
  (extdb/proc sqldb
    "SELECT minister FROM ministers WHERE space=?"
    (cons #[%merge #t] sql/typemap)))
(define (getministers space)
  (sql/getministers (if (uuid? space) space (get space 'uuid))))

(define sql/addminister
  (extdb/proc sqldb
    "INSERT INTO ministers (space,minister,joined) VALUES (?,?,?)"
    sql/typemap))
(define sql/dropminister
  (extdb/proc sqldb
    "DELETE FROM ministers WHERE space=? and minister=?"
    sql/typemap))

(define (enter space minister (uid #f))
  (sql/addminister (if (uuid? space) space (get space 'uuid))
		   minister
		   (gmtimestamp 'seconds)))
(define (leave space minister (uid #f))
  (sql/dropminister (if (uuid? space) space (get space 'uuid))
		    minister))

(define sql/addmessage
  (extdb/proc sqldb
    "INSERT INTO messages
                 (msgid,space,content,minister,spoken)
          VALUES (?,?,?,?,?)"
    sql/typemap))
(define (addmessage space content minister
		    (uuid (getuuid)) (tstamp (gmtimestamp 'seconds)))
  (sql/addmessage uuid space content minister tstamp))

(define sql/lastmessage
  (extdb/proc sqldb
    "SELECT * FROM messages
      WHERE space=?
        AND shared IS NOT NULL
   ORDER BY shared DESC
      LIMIT 1"
    sql/typemap))
(define sql/nextmessage
  (extdb/proc sqldb
    "SELECT * FROM messages
      WHERE space=?
        AND shared IS NULL
   ORDER BY spoken ASC
      LIMIT 1"
    sql/typemap))
(define sql/lastmessage/since
  (extdb/proc sqldb
    "SELECT * FROM messages
      WHERE space=?
        AND shared IS NOT NULL
        AND shared>?
   ORDER BY shared DESC
      LIMIT 1"
    sql/typemap))

(define sql/sharemessage
  (extdb/proc sqldb
    "UPDATE messages SET shared=? WHERE msgid=?"
    sql/typemap))

(define (getmessage space (interval 60))
  (let ((tstamp (if (timestamp? interval) interval
		    (timestamp+ (- interval)))))
    (try (sql/lastmessage/since
	  (if (uuid? space) space (get space 'uuid))
	  tstamp)
	 (let* ((uuid (if (uuid? space) space (get space 'uuid)))
		(next (sql/nextmessage uuid)))
	   (sql/sharemessage (gmtimestamp 'seconds) (get next 'msgid))
	   (try next (sql/lastmessage/since uuid tstamp))))))
