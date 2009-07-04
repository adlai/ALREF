;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; Base: 10 -*-

(defpackage #:alref-asd
  (:use :cl :asdf))
(in-package :alref-asd)

(defsystem alref
  :name "ALREF Utility"
  :version "2.3.2"
  :maintainer "Adlai"
  :author "Adlai"
  :license "MIT-style; See README"
  :description "A utility for ALIST manipulation."
  :long-description
  "This package exports the ALREF symbol, along with two bits of
behavior: a function #'alref, and a setf expansion. These work
quite intuitively. See README for documentation and options."
  :serial T
  :components ((:file "alref")))
