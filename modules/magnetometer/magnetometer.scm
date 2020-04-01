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

;; get magnetometer data from devices (only android; iOS todo)

(c-declare  #<<end-of-c-declare

#ifdef IOS
  double ios_mag_getx(void);
  double ios_mag_gety(void);
  double ios_mag_getz(void);
#endif

#ifdef ANDROID
  double android_mag_getx(void);
  double android_mag_gety(void);
  double android_mag_getz(void);
#endif


static double mag_x(void) {
#ifdef ANDROID
  return android_mag_getx();
#elif IOS
  return 0; //ios_mag_getx();
#else
  return 0;
#endif
}

static double mag_y(void) {
#ifdef ANDROID
  return android_mag_gety();
#elif IOS
  return 0; //ios_mag_gety();
#else
  return 0;
#endif
}

static double mag_z(void) {
#ifdef ANDROID
  return android_mag_getz();
#elif IOS
  return 0; //ios_mag_getz();
#else
  return 0;
#endif
}

end-of-c-declare
)

(define mag-x (c-lambda () double "mag_x"))
(define mag-y (c-lambda () double "mag_y"))
(define mag-z (c-lambda () double "mag_z"))

;; eof
