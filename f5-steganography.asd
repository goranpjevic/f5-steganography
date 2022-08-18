;;;; f5-steganography.asd

(asdf:defsystem #:f5-steganography
  :description "implementation of the f5 steganography algorithm."
  :author "goran pjević"
  :license  "mit license"
  :serial t
  :depends-on (#:april #:opticl)
  :components ((:file "package")
               (:file "f5-steganography")))
