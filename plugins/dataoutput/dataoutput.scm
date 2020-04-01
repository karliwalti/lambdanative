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

;; output plugin for data matrix

(define dataoutput:debuglevel 0)
(define (dataoutput:log level . x) (if (>= dataoutput:debuglevel level) (apply log-system (append (list "dataoutput: ") x))))
(define (dataoutput:stop store instance)
  (let ((fh (instance-refvar store instance "Handle"))
        (casefile (instance-refvar store instance "FilePath")))
    (if (port? fh) (begin
      (close-output-port fh)
      (if (fx= (file-info-size (file-info casefile)) 0) (delete-file casefile))
      (if (and casefile (function-exists? "timestamp-gettimestamp"))
        ((eval 'timestamp-gettimestamp) casefile)
      )
    ))
    (instance-setvar! store instance "Handle" #f)
    (dataoutput:log 2 "stop")
  ))

(define (dataoutput:start store instance)
  (let* ((casepath (instance-refvar store instance "CasePath" ""))
         (namesuffix (instance-refvar store instance "NameSuffix" #f))
         (source (instance-refvar store instance "Source" ""))
         (id (instance-refvar store instance "CaseID" ""))
         (casefile (string-append casepath (system-pathseparator) id "-"
           source "-" (seconds->string ##now "%Y%m%d_%H%M%S")
           (if (string? namesuffix) namesuffix "") ".csv"))
         (parameters (instance-refvar store instance "Parameters" '()))
         (fh (open-output-file casefile)))
    (log-status "dataoutput:start " casefile)
   (instance-setvar! store instance "Handle" fh)
   (instance-setvar! store instance "FilePath" casefile)
   (dataoutput:log 2 "start fh=" fh)
   (if fh (begin
     (display (number->string ##now) fh) (display "," fh) (display id fh)  (display "," fh) (display source fh) (display "," fh)
     (display (system-appname) fh) (display "," fh) (display (system-builddatetime) fh) (display "," fh)
     (display (system-buildhash) fh) (display "," fh) (display (system-platform) fh) (display "\n" fh)
     ;;(display "Time" fh)
     (for-each (lambda (t) (display  t fh)(display "," fh) ) parameters)
     (display "\n" fh)
     (force-output fh)
   )
       (log-error "dataoutput:start failed to open file for writing"))
 ))

(define (dataoutput:run store instance)
  (let* ((fh (instance-refvar store instance "Handle"))
         (src (instance-refvar store instance "Source" '()))
    	 (data (if src (store-ref store src '()) '())))
         (dataoutput:log 2 "run src=" src " [" (length data) "]")
         (if (and fh (fx> (length data) 0)) 
            (begin     
                    (for-each (lambda (s) 
                                (for-each (lambda (p) (display  p fh) (display "," fh)) s)
                                (display "\n" fh)) data );;                             
          (force-output fh)))
  ))

(define (dataoutput:init store instance)
  (instance-setvar! store instance "Handle" #f)
  ;;(log-status "Start dataoutput Init " instance)
  #t)

(define (dataoutput:caseinit store instance)
  (log-status "dataoutput:caseinit " instance)
  (if (store-ref store "CaseID" #f) (begin
    (let* ((opath (instance-refvar store instance "OutputPath" scheduler:outputpath))
           (casepath (string-append opath (system-pathseparator) (store-ref store "CaseID" #f))))
      (if (not (file-exists? opath)) (create-directory opath))
      (if (not (file-exists? casepath)) (create-directory casepath))
      (instance-setvar! store instance "CasePath" casepath)
    )
    (dataoutput:start store instance)) (log-warning "dataoutput:caseinit: No CaseID found!" )
  ))

(define (dataoutput:caserun store instance)
  (if (and (store-ref store "CaseID" #f)
           ;; forget disk space for now
           #t ;; (> (store-ref store "DiskSpace" 0) 0)
      )
    (dataoutput:run store instance)
      (log-status "dataoutput:caserun")
  )
  #t)

(define (dataoutput:caseend store instance)
  (if (instance-refvar store instance "Handle" #f) (dataoutput:run store instance))
  (dataoutput:stop store instance)
  (log-status "dataoutput:caseend")
  #t)

(define (dataoutput:end store instance)
  (if (instance-refvar store instance "Handle" #f) (dataoutput:stop store instance))
  (log-status "dataoutput:end")
  #t)

(plugin-register "dataoutput" dataoutput:init dataoutput:caseinit dataoutput:caserun
                 dataoutput:caseend dataoutput:end 'output)

;; eof
