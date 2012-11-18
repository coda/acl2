; Arithmetic-5 Library
; Copyright (C) 2009 Robert Krug <rkrug@cs.utexas.edu>
;
; This program is free software; you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free Software
; Foundation; either version 2 of the License, or (at your option) any later
; version.
;
; This program is distributed in the hope that it will be useful but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
; details.
;
; You should have received a copy of the GNU General Public License along with
; this program; if not, write to the Free Software Foundation, Inc., 51
; Franklin Street, Suite 500, Boston, MA 02110-1335, USA.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; building-blocks-helper.lisp
;;;
;;; This book contains some messy proofs which I want to hide.
;;; There is probably nothing to be gained by looking at it.
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(in-package "ACL2")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local
 (include-book "../../support/top"))

(local
 (defun rationalp-guard-fn (args)
   (if (endp (cdr args))
       `((rationalp ,(car args)))
     (cons `(rationalp ,(car args))
	   (rationalp-guard-fn (cdr args))))))

(local
 (defmacro rationalp-guard (&rest args)
   (if (endp (cdr args))
       `(rationalp ,(car args))
     (cons 'and
	   (rationalp-guard-fn args)))))


(local
 (defthm niq-bounds
   (implies (and (integerp i)
		 (<= 0 i)
		 (integerp j)
		 (< 0 j))
	    (and (<= (nonnegative-integer-quotient i j)
		     (/ i j))
		 (< (+ (/ i j) -1)
		    (nonnegative-integer-quotient i j))))
   :hints (("Subgoal *1/1''" :use (:instance NORMALIZE-<-/-TO-*-3-3
					     (X 1)
					     (Z J)
					     (Y I))))
   :rule-classes ((:linear
		   :trigger-terms ((nonnegative-integer-quotient i j))))))

(local
 (defthm floor-bounds-1
   (implies (rationalp-guard x y)
	    (and (< (+ (/ x y) -1)
		    (floor x y))
		 (<= (floor x y)
		     (/ x y))))
   :rule-classes ((:generalize) 
		  (:linear :trigger-terms ((floor x y))))))

(local
 (defthm floor-bounds-2
   (implies (and (rationalp-guard x y)
		 (integerp (/ x y)))
	    (equal (floor x y)
		   (/ x y)))
   :rule-classes ((:generalize) 
		  (:linear :trigger-terms ((floor x y))))))

(local
 (defthm floor-bounds-3
   (implies (and (rationalp-guard x y)
		 (not (integerp (/ x y))))
	    (< (floor x y)
	       (/ x y)))
   :rule-classes ((:generalize) 
		  (:linear :trigger-terms ((floor x y))))))

(local
 (in-theory (disable floor)))

(defthm one
  (IMPLIES (AND (INTEGERP x)
		(integerp y)
		(<= 0 y))
	   (<= 0
	       (LOGAND x y)))
  :rule-classes :linear)

(defthm two
  (IMPLIES (AND (INTEGERP x)
		(integerp y)
		(<= 0 y))
	   (<= (LOGAND x y)
	       y))
  :rule-classes :linear)

(defthm rewrite-floor-x*y-z-left
  (implies (and (rationalp x)
		(rationalp y)
		(rationalp z)
		(not (equal z 0)))
	   (equal (floor (* x y) z)
		  (floor y (/ z x)))))

(defun power-of-2-measure (x)
  (declare (xargs :guard (and (rationalp x) (not (equal x 0)))))
  (cond ((or (not (rationalp x))
             (<= x 0)) 0)
	((< x 1) (cons (cons 1 1) (floor (/ x) 1)))
	(t (floor x 1))))

(defun power-of-2-helper (x)
  (declare (xargs :guard t
                  :measure (power-of-2-measure x)
		  :hints (("Subgoal 2.2'" :use (:instance
						(:theorem 
						 (IMPLIES (AND (RATIONALP X)
							       (< 2 X))
							  (< (FLOOR X 2) (FLOOR X 1))))
						(x (/ x)))
			                  :in-theory (enable NORMALIZE-<-/-TO-*-1)))))
  (cond ((or (not (rationalp x))
             (<= x 0))
         0)
        ((< x 1) (+ -1 (power-of-2-helper (* 2 x))))
        ((<= 2 x) (+ 1 (power-of-2-helper (* 1/2 x))))
        ((equal x 1) 0)
        (t 0) ;got a number in the doubly-open interval (1,2)
        ))