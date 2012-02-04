;;; -*- Mode: Scheme; character-encoding: utf-8; -*-

;;; Copyright (C) 2012 Ken Haase.  All rights reserved.

(use-module '{texttools fdweb xhtml extdb mysql crypto
	      updatefile xhtml/include})

(define waiting.html (get-component "waiting.html"))
(define enter.html (get-component "enter.html"))

(define-init sql/typemap #[])

(define sql-cert (get-component "sqlcert.pem"))

(define sqldb
  (mysql/open (config 'ww:sqlhost "localhost")
	      (config 'ww:sqldb "ww")
	      sql/typemap
	      (config 'ww:sqluser "sbooks")
	      (config 'ww:sqlpass "bibliophile")
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

(define sql/getministers
  (extdb/proc sqldb
    "SELECT minister FROM ministers WHERE space=?"
    `(%MERGE . ,sql/typemap)))
(define (getministers space) (sql/getministers (get space 'uuid)))

(define sql/getmessage
  (extdb/proc sqldb
    "SELECT message
      FROM messages
     WHERE space=?
      AND moment>?
 ORDER BY moment DESC
    LIMIT 1"
    `(%MERGE . ,sql/typemap)))
(define (getmessage space (interval 1200))
  (sql/getmessage (get space 'uuid)
		  (if (timestamp? interval) interval
		      (timestamp+ (- interval)))))



