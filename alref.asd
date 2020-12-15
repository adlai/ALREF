;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 36 -*-

(cl:defsystem "alref"                   ; lowercase improper noun
  :name "Adlai's Utility ALREF"         ; "NEVER: GO FULL-RETARD"
  :version "#.(/ 2/5)"                  ; yes, it crashes garbage
  :maintainer "Adlai"                   ; Whom? Why'd I make this
  :author #."Adlai"                     ; garbage, you made this!
  :license "README"                     ; no pointers, only text;
  :description "Case study: Common Lisp's generalized references"
  :components ((:file "alref")))        ; and macro-writing macro
