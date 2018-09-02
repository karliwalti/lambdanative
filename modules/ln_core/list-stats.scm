#|
LambdaNative - a cross-platform Scheme framework
Copyright (c) 2009-2013, University of British Columbia
All rights reserved.

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the
following conditions are met:

* Redistributions of source code must retain the above
copyright notice, this list of conditions and the following
disclaimer.

* Redistributions in binary form must reproduce the above
copyright notice, this list of conditions and the following
disclaimer in the documentation and/or other materials
provided with the distribution.

* Neither the name of the University of British Columbia nor
the names of its contributors may be used to endorse or
promote products derived from this software without specific
prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
|#
;; various statistics on lists

;; fold right - auxillary
(define (foldr f base lst)
  (let loop ((acc base)
             (l   (reverse lst)))
    (if (null? l)  acc
        (loop (f (car l) acc)
              (cdr l)))))

;; misc list operations 
(define (scale lst k) (map (lambda (x) (* k x)) lst))

(define (offset lst k) (map (lambda (x) (+ k x)) lst))

(define (sum-of-squares lst) (sum (map square lst)))

(define (sum lst) (foldr + 0 lst))

(define (product lst) (foldr * 1 lst))

(define (mean lst)  (/ (sum lst) (length lst)))

(define (median lst) (percentile lst 50))

(define (first-quartile lst) (percentile lst 25))

(define (third-quartile lst) (percentile lst 75))

(define (interquartile lst)
  (let ((first (first-quartile lst))
        (third (third-quartile lst)))
    (- third first)))

(define (percentile lst prc0)
  (let* ((sorted (sort lst <))
         (len (- (length lst) 1))
         (pos (max 0 (min len (/ (* len prc0) 100)))))
    (if (= (exact-floor pos) pos)
      (list-ref sorted (exact-floor pos))
      (+ (* (list-ref sorted (exact-ceiling pos)) (- pos (floor pos)))
         (* (list-ref sorted (exact-floor pos)) (- (ceiling pos) pos)))  
    )
  ))

(define (variance lst)
  (let ((m (mean lst)))
    (mean (map (lambda (x) (square (- x m))) lst))))

(define (std lst) (sqrt (variance lst)))
(define (rms lst) (sqrt (sum-of-squares lst)))

(define (list-normalize lst)
  (if (fx= (length lst) 0) lst
    (let* ((mn (apply min lst))
           (mx (apply max lst))
           (d  (- mx mn)))
      (if (= d 0) (make-list (length lst) 0.5)
        (map (lambda (x) (/ (- x mn) d)) lst)))))

;; Return the smallest element of list lst
(define (list-min lst)
  (car (sort lst <)))

;; Return the largest element of list lst
(define (list-max lst)
  (car (sort lst >)))

;; Diff of list
(define (list-diff lst)
  (map - (cdr lst) (list-head lst (fx- (length lst) 1))))

;; Inner product of lists
(define (list-dot lst1 lst2)
  (apply + (map * lst1 lst2)))
(define (list-fldot lst1 lst2)
  (apply fl+ (map fl* lst1 lst2)))

;; Get index of element in list that is closest to val
(define (list-closest lst v)
  (let* ((mlst (map (lambda (x) (abs (- x v))) lst))
         (min (list-min mlst)))
    (list-pos mlst min))
)

;; eof
