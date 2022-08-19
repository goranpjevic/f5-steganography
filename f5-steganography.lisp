;;;; f5-steganography.lisp

(in-package #:f5-steganography)

(defun print-usage ()
  (format t "args:  [input_filename] [option] [message_filename] [N] [M] [output_filename]~%")
  (format t "  input_filename : path to input file~%")
  (format t "  option :~%")
  (format t "    h : hide message~%")
  (format t "    e : unhide message~%")
  (format t "  message_filename : path to file containing the message to hide or unhide to~%")
  (format t "  N : compression threshold~%")
  (format t "  M : number of unique coefficient triples used in f5 steganography~%")
  (format t "  output_filename : path to the output file~%"))

(defun number-to-list-of-bits (byte-to-convert &optional (size 8))
  ; convert a byte to a list of bits
  (let ((bits '()))
    (dotimes (index size bits)
      (push (if (logbitp index byte-to-convert) 1 0) bits))))

(defun list-of-bits-to-number (list-of-bits &optional (index 0) (number 0))
  ; convert a list of bits to a number
  (if (null list-of-bits)
    number
    (list-of-bits-to-number
      (butlast list-of-bits)
      (1+ index)
      (+ number
         (if (= 1 (car (last list-of-bits)))
           (expt 2 index)
           0)))))

(defun read-list-of-bits-from-file (input-file-stream &optional (lst '()))
  ; return list of bits from the input file
  (let ((byte-read (read-byte input-file-stream nil)))
    (if byte-read
      (read-list-of-bits-from-file
        input-file-stream
        (append lst (number-to-list-of-bits byte-read)))
      lst)))

(defun write-bits-to-file (output-file-stream list-of-bits)
  ; output list of bits to an output file
  (if (not (null list-of-bits))
    (progn
      ; write byte to the output file
      (let ((new-list-of-bits
              (if (> 0 (- 8 (length list-of-bits)))
                list-of-bits
                (append list-of-bits (make-list (- 8 (length list-of-bits))
                                                :initial-element 0)))))
        (write-byte (list-of-bits-to-number (subseq new-list-of-bits 0 8))
                    output-file-stream)
        (write-bits-to-file output-file-stream (subseq new-list-of-bits 8))))))

(defun hide (input-filename message-filename N M output-filename)
  ; hide message in the message-file in an image from the input-file
  (with-open-file (message-file message-filename
				:direction :input
				:element-type 'unsigned-byte)
    (with-open-file (output-file output-filename
				 :direction :output
				 :if-exists :overwrite
				 :if-does-not-exist :create
				 :element-type 'unsigned-byte)
      (write-bits-to-file
	output-file
	(coerce
	  (april:april-c
	    "f5sh"
	    (make-array 4 :initial-contents
			(list (opticl:read-png-file input-filename)
			      (coerce (read-list-of-bits-from-file message-file)
				      '(vector fixnum))
			      (parse-integer N)
			      (parse-integer M))))
	  'list)))))

(defun unhide (input-filename message-filename N M output-filename)
  ; extract message from the input-file to the message-file
  (with-open-file (input-file input-filename
			      :direction :input
			      :element-type 'unsigned-byte)
    (with-open-file (message-file message-filename
				  :direction :output
				  :if-exists :overwrite
				  :if-does-not-exist :create
				  :element-type 'unsigned-byte)
      (let ((f5se-output (april:april-c "f5se"
					(make-array
					  3 :initial-contents
					  (list (coerce (read-list-of-bits-from-file input-file)
							'(vector fixnum))
						(parse-integer N)
						(parse-integer M))))))
	(write-bits-to-file message-file (coerce (elt f5se-output 0) 'list))
	(opticl:write-png-file output-filename (elt f5se-output 1))))))

(defun main (argv)
  (if (/= 6 (length argv))
    (print-usage)
    (let* ((input-filename (car argv))
	   (option (second argv))
	   (message-filename (third argv))
	   (N (fourth argv))
	   (M (fifth argv))
	   (output-filename (sixth argv)))
      (cond
	((string= option "h") (hide input-filename message-filename N M output-filename))
	((string= option "e") (unhide input-filename message-filename N M output-filename))
	(t (print-usage))))))
