(defpackage #:alref
  (:use :cl)
  (:export :alref))
(in-package :alref)
(defmacro with-gensyms (vars &body body)
  `(let ,(loop for x in vars collect `(,x (gensym)))
     ,@body))
(defun alref (item alist &key (test #'eql) (key #'identity))
  "Retreive the value corresponding to ITEM in ALIST."
  (cdr (assoc item alist :test test :key key)))
(define-setf-expander alref (item alist
                             &key (test #'eql) (key #'identity)
                             &environment env)
  "Set the value corresponding to ITEM in ALIST."
  (multiple-value-bind (foo foo stores setter)
      (get-setf-expansion alist env)
    (declare (ignore foo))
    (with-gensyms (it g-item g-alist g-test g-key new)
      (values (list g-item g-alist g-test g-key it)
              (list item alist test key
                    `(assoc ,item ,alist :test ,test :key ,key))
              `(,new)
              `(cond ((eq ,new NIL)
                      (let ((,(car stores)
                             (delete ,g-item ,g-alist :test ,g-test
                                     :count 1 :key
                                     #'(lambda (pair)
                                         (funcall ,g-key
                                                  (car pair))))))
                        ,setter))
                     (,it (setf (cdr ,it) ,new))
                     (T (let ((,(car stores)
                               (acons ,g-item ,new ,g-alist)))
                          ,setter)))
              `(cdr ,it)))))
