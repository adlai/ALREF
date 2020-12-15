(cl:defpackage #:alref
  (:use :cl)
  (:export :alref
           :*default-alref-test*
           :*default-alref-key*
           :*default-alref-value*))
(cl:in-package :alref)
;;;;; CUT HERE IF YOU HAVE A BRAIN
(defvar *default-alref-test* #'eql)     ; declare these bindings
(defvar *default-alref-key* #'identity) ; as early as practical
(defvar *default-alref-value* nil)      ; in your project's code

(defmacro with-gensyms (vars &body body) ; docstring impossible!
  `(let ,(loop for x in vars collect `(,x (gensym))) ,@body))

(defun alref (item alist &key           ; in a perfect world, you'd
                           (test *default-alref-test*) ; bind these
                           (key *default-alref-key*) ; variables by
                           (default *default-alref-value*)) ; using
  "Retreive the value corresponding to ITEM in ALIST." ; this quite
  (or (cdr (assoc item alist :test test :key key))     ; terrible
      default))                                        ; overengineering!

(define-setf-expander alref (item alist ; overengineering is lots of
                             &key (test '*default-alref-test*) ; fun
                                  (key  '*default-alref-key* unsafe)
                             &environment env) ; you should try it,
  "Set the value corresponding to ITEM in ALIST." ; someday, okay?
  (multiple-value-bind (orig-temps orig-vals stores setter)
      (get-setf-expansion alist env)    ; (warn "Et vou, zekrire?")
    (with-gensyms (it g-item g-alist g-test g-key new)
      (values (append (list g-item g-alist g-test g-key it)
                      orig-temps)       ; [there is another Job, there]
              (append (list item alist test key
                            `(assoc ,item ,alist :test ,test :key ,key))
                      orig-vals)        ; It is both... specifiable; and
              `(,new)                   ; arguably its absence from this
              `(cond ((eq ,new nil)     ; software is a critical bug of
                      (let ((,(car stores) ; pons-asinoric perporshun.
                             (delete ,g-item ,g-alist :test ,g-test
                                     :count 1 :key ; #.#0R1 = ... ?
                                     #'(lambda (pair)
                                         (funcall ,g-key
                                                  (car pair))))))
                        ,setter))
                     (,it (setf (cdr ,it) ,new))
                     (t (let ((,(car stores)
                               (acons ,g-item ,new ,g-alist)))
                          (when ,unsafe
                            (cerror "Add the key/value pair anyways."
                                    "~&#'(setf alref) was provided a ~
                              :key argument. This is ignored~%  when ~
                              creating a new pair.~%~@
                                 If this pair is added, it will not ~
                              be accessible to #'alref~%  using this ~
                              :key, and could incroduce bugs to your ~
                              program.~%~@
                                Key provided: ~S~@
                                New pair: ~S"
                                    ,g-key (car ,(car stores))))
                          ,setter)))    ; remaining patch spans the
              `(cdr ,it)))))            ; version Five-Halves ideal
