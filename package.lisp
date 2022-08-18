;;;; package.lisp

(defpackage #:f5-steganography
  (:export #:main)
  (:use #:cl))

(april:april-load (pathname "f5-steganography.apl"))
