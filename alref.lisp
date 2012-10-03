(defpackage #:alref
  (:use :cl)
  (:export :alref
           :*default-alref-test*
           :*default-alref-key*
           :*default-alref-value*))
(in-package :alref)
(defvar *default-alref-test* #'eql)
(defvar *default-alref-key* #'identity)
(defvar *default-alref-value* nil)
(defmacro with-gensyms (vars &body body)
  `(let ,(loop for x in vars collect `(,x (gensym)))
     ,@body))
(defun alref (item alist &key
              (test *default-alref-test*)
              (key *default-alref-key*)
              (default *default-alref-value*))
  "Retreive the value corresponding to ITEM in ALIST."
  (or (cdr (assoc item alist :test test :key key))
      default))
(define-setf-expander alref (item alist
                             &key (test '*default-alref-test*)
                                  (key  '*default-alref-key* unsafe)
                             &environment env)
  "Set the value corresponding to ITEM in ALIST."
  (multiple-value-bind (orig-temps orig-vals stores setter)
      (get-setf-expansion alist env)
    (with-gensyms (it g-item g-alist g-test g-key new)
      (values (append (list g-item g-alist g-test g-key it)
                      orig-temps)
              (append (list item alist test key
                            `(assoc ,item ,alist :test ,test :key ,key))
                      orig-vals)
              `(,new)
              `(cond ((eq ,new nil)
                      (let ((,(car stores)
                             (delete ,g-item ,g-alist :test ,g-test
                                     :count 1 :key
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
                          ,setter)))
              `(cdr ,it)))))
