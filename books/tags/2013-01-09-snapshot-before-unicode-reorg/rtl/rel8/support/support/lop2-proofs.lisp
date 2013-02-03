(in-package "ACL2")

(include-book "lop1")
(include-book "lior0")
(local (include-book "../../arithmetic/top"))
(local (include-book "bitn"))
(local (include-book "bits"))

(local (defun lop2-induct (n a b)
  (if (and (integerp n) (>= n 0))
      (if (> n 0)
	  (lop2-induct (1- n) a (mod b (expt 2 (1- n))))
	a)
    b)))

(local (defthm lop2-1
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (= (bitn a (1- k)) 0)
		  (= (bitn b (1- k)) 1)
		  (IMPLIES (AND (INTEGERP A)
				(<= 0 A)
				(INTEGERP (MOD B (EXPT 2 (+ -1 K))))
				(<= 0 (MOD B (EXPT 2 (+ -1 K))))
				(INTEGERP (+ -1 K))
				(<= 0 (+ -1 K))
				(< A (EXPT 2 (+ -1 K)))
				(< (MOD B (EXPT 2 (+ -1 K)))
				   (EXPT 2 (+ -1 K))))
			   (= (LOP A (MOD B (EXPT 2 (+ -1 K)))
				   1 (+ -1 K))
			      (EXPO (LOGIOR (* 2 A)
					    (LNOT (* 2 (MOD B (EXPT 2 (+ -1 K))))
						   (+ 1 -1 K))))))
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (LOP A 
		     (MOD B (EXPT 2 (+ -1 K)))
		     1 (1- K))
		(EXPO (LOGIOR (* 2 A)
			      (LNOT (* 2 (MOD B (EXPT 2 (+ -1 K))))
				     k)))))
  :rule-classes ()
  :hints (("Goal" :use ((:instance mod-bnd-1 (m b) (n (expt 2 (1- k))))
;			(:instance mod>=0 (m b) (n (expt 2 (1- k))))
			(:instance bit-expo-b (x a) (n (1- k))))))))

(local (defthm lop2-2
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (= (bitn a (1- k)) 0)
		  (= (bitn b (1- k)) 1)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (LOP A b 1 k)
		(lop a b 1 (1- k))))
    :hints (("Goal" :in-theory (enable lop)))
  :rule-classes ()))

(local (defthm lop2-3
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (= (bitn a (1- k)) 0)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K)))
	     (= (mod a (expt 2 (1- k)))
		a))
  :rule-classes ()
  :hints (("Goal" :use ((:instance mod-does-nothing (m a) (n (expt 2 (1- k))))
;			(:instance expt-pos (x (1- k)))
			(:instance bit-expo-b (x a) (n (- k 1))))))))

(local (defthm lop2-4
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (= (bitn a (1- k)) 0)
		  (= (bitn b (1- k)) 1)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (LOP A b 1 k)
		(lop a (mod b (expt 2 (1- k))) 1 (1- k))))
  :rule-classes ()
  :hints (("Goal" :use (lop2-3
			lop2-2
			(:instance lop-mod (d 1) (j (1- k)) (k (1- k))))))))

(local (defthm lop2-5
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (= (bitn a (1- k)) 0)
		  (= (bitn b (1- k)) 1)
		  (IMPLIES (AND (INTEGERP A)
				(<= 0 A)
				(INTEGERP (MOD B (EXPT 2 (+ -1 K))))
				(<= 0 (MOD B (EXPT 2 (+ -1 K))))
				(INTEGERP (+ -1 K))
				(<= 0 (+ -1 K))
				(< A (EXPT 2 (+ -1 K)))
				(< (MOD B (EXPT 2 (+ -1 K)))
				   (EXPT 2 (+ -1 K))))
			   (= (LOP A (MOD B (EXPT 2 (+ -1 K)))
				   1 (+ -1 K))
			      (EXPO (LOGIOR (* 2 A)
					    (LNOT (* 2 (MOD B (EXPT 2 (+ -1 K))))
						   (+ 1 -1 K))))))
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (LOP A b 1 k)
		(EXPO (LOGIOR (* 2 A)
			      (LNOT (* 2 (MOD B (EXPT 2 (+ -1 K))))
				     k)))))
  :rule-classes ()
  :hints (("Goal" :use (lop2-1 lop2-4)))))

(local (defthm lop2-6
    (IMPLIES (AND (INTEGERP k)
		  (< 0 k)
		  (= (bitn b (- k 1)) 1)
		  (INTEGERP b)
		  (INTEGERP k)
		  (<= 0 b)
		  (< b (EXPT 2 k)))
	     (= (mod b (expt 2 (- k 1)))
		(- b (expt 2 (- k 1)))))
  :rule-classes ()
  :hints (("Goal" :in-theory (enable expt-split)
           :use ((:instance mod-does-nothing (m (- b (expt 2 (- k 1)))) (n (expt 2 (- k 1))))
;			(:instance expt-pos (x (- k 1)))
			(:instance expt-split (r 2) (i (- k 1)) (j 1))
			(:instance bit-expo-a (x b) (n (- k 1)))
;			(:instance mod+-thm (m (- b (expt 2 (- k 1)))) (a 1) (n (expt 2 (- k 1))))
                        )))))

(local (defthm lop2-7
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (= (bitn a (1- k)) 0)
		  (= (bitn b (1- k)) 1)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (lnot (* 2 (mod b (expt 2 (1- k))))
		       k)
		(lnot (* 2 b) (1+ k))))		
  :rule-classes ()
  :hints (("Goal" :in-theory (set-difference-theories
                              (enable lnot expt bits-reduce)
                              '())
           :use (lop2-6)))))

(local (defthm lop2-8
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (= (bitn a (1- k)) 0)
		  (= (bitn b (1- k)) 1)
		  (IMPLIES (AND (INTEGERP A)
				(<= 0 A)
				(INTEGERP (MOD B (EXPT 2 (+ -1 K))))
				(<= 0 (MOD B (EXPT 2 (+ -1 K))))
				(INTEGERP (+ -1 K))
				(<= 0 (+ -1 K))
				(< A (EXPT 2 (+ -1 K)))
				(< (MOD B (EXPT 2 (+ -1 K)))
				   (EXPT 2 (+ -1 K))))
			   (= (LOP A (MOD B (EXPT 2 (+ -1 K)))
				   1 (+ -1 K))
			      (EXPO (LOGIOR (* 2 A)
					    (LNOT (* 2 (MOD B (EXPT 2 (+ -1 K))))
						   (+ 1 -1 K))))))
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (LOP A b 1 k)
		(EXPO (LOGIOR (* 2 A)
			      (LNOT (* 2 b) (1+ k))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable lnot lop)
		  :use (lop2-5 lop2-7)))))

(local (defthm lop2-9
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (not (and (= (bitn a (1- k)) 0)
			    (= (bitn b (1- k)) 1)))
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (LOP A b 1 k) k))
  :rule-classes ()
  :hints (("Goal" :in-theory (enable lop)
           :use ((:instance bitn-0-1 (x a) (n (1- k)))
                 (:instance bitn-0-1 (x b) (n (1- k))))))))

(local (defthm lop2-10
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (< (* 2 a) (expt 2 (1+ k))))
  :rule-classes ()
  :hints (("Goal" :in-theory (set-difference-theories
                              (enable expt)
                              '(a15))
                              :use ((:instance *-strongly-monotonic (x 2) (y a) (y+ (expt 2 k))))))))

(local (defthm lop2-11
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (< (LNOT (* 2 b) (1+ k))
		(expt 2 (1+ k))))
    :hints (("Goal"  :in-theory (set-difference-theories
                              (enable expt lnot)
                              '(a15))))
  :rule-classes ()))

(local (defthm lop2-12
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (< (logior (* 2 a)
			(LNOT (* 2 b) (1+ k)))
		(expt 2 (1+ k))))
  :rule-classes ()
  :hints (("Goal" :use (lop2-10
			lop2-11
;			(:instance or-dist-a
	;			   (x (* 2 a))
		;		   (y (lnot (* 2 b) (1+ k)))
			;	   (n (1+ k)))
                        )))))

(local (defthm lop2-13
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (<= (expo (logior (* 2 a)
			       (LNOT (* 2 b) (1+ k))))
		 k))
  :rule-classes ()
  :hints (("Goal" :use (lop2-12
			(:instance expo<= (x (logior (* 2 a) (LNOT (* 2 b) (1+ k)))) (n k)))))))

(local (include-book "logior")) ;remove if log includes logior

(local (defthm lop2-14
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (= (bitn a (1- k)) 1)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (bitn (logior (* 2 a) (LNOT (* 2 b) (1+ k)))
		      k)
		1))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable BITN-KNOWN-NOT-0-REPLACE-WITH-1)
		  :use ((:instance bitn-shift (x a) (k 1) (n (1- k)))
			(:instance bitn-0-1 (x (LNOT (* 2 b) (1+ k))) (n k)))))))

(local (defthm lop2-15
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (= (bitn b (1- k)) 0)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (bitn (logior (* 2 a) (LNOT (* 2 b) (1+ k)))
		      k)
		1))
  :rule-classes ()
  :hints (("Goal"  :in-theory (set-difference-theories
                              (enable bits-reduce)
                              '(a15  BITN-KNOWN-NOT-0-REPLACE-WITH-1))
		  :use ((:instance bitn-shift (x b) (k 1) (n (1- k)))
			(:instance bitn-0-1 (x (LNOT (* 2 b) (1+ k))) (n k))
			(:instance bitn-0-1 (x (* 2 a)) (n k))
			(:instance bitn-lnot-not-equal
				   (x (* 2 b))
				   (n (1+ k))))))))

(local (defthm lop2-16
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (not (and (= (bitn a (1- k)) 0)
			    (= (bitn b (1- k)) 1)))
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (bitn (logior (* 2 a) (LNOT (* 2 b) (1+ k)))
		      k)
		1))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable logior)
		  :use (lop2-14
			lop2-15
			(:instance bitn-0-1 (x a) (n (1- k)))
			(:instance bitn-0-1 (x b) (n (1- k))))))))

(local (defthm lop2-17
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (not (and (= (bitn a (1- k)) 0)
			    (= (bitn b (1- k)) 1)))
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (>= (logior (* 2 a) (LNOT (* 2 b) (1+ k)))
		 (expt 2 k)))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable logior)
		  :use (lop2-16
			(:instance bit-expo-a (x (logior (* 2 a) (LNOT (* 2 b) (1+ k)))) (n k)))))))

(local (defthm lop2-18
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (not (and (= (bitn a (1- k)) 0)
			    (= (bitn b (1- k)) 1)))
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (>= (expo (logior (* 2 a) (LNOT (* 2 b) (1+ k))))
		 k))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable logior)
		  :use (lop2-17
			(:instance expo>= (x (logior (* 2 a) (LNOT (* 2 b) (1+ k)))) (n k)))))))

(local (defthm lop2-19
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (not (and (= (bitn a (1- k)) 0)
			    (= (bitn b (1- k)) 1)))
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (expo (logior (* 2 a) (LNOT (* 2 b) (1+ k))))
		k))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable logior)
		  :use (lop2-13 lop2-18)))))

(local (defthm lop2-20
    (IMPLIES (AND (INTEGERP K)
		  (< 0 K)
		  (IMPLIES (AND (INTEGERP A)
				(<= 0 A)
				(INTEGERP (MOD B (EXPT 2 (+ -1 K))))
				(<= 0 (MOD B (EXPT 2 (+ -1 K))))
				(INTEGERP (+ -1 K))
				(<= 0 (+ -1 K))
				(< A (EXPT 2 (+ -1 K)))
				(< (MOD B (EXPT 2 (+ -1 K)))
				   (EXPT 2 (+ -1 K))))
			   (= (LOP A (MOD B (EXPT 2 (+ -1 K)))
				   1 (+ -1 K))
			      (EXPO (LOGIOR (* 2 A)
					    (LNOT (* 2 (MOD B (EXPT 2 (+ -1 K))))
						   (+ 1 -1 K))))))
		  (INTEGERP A)
		  (<= 0 A)
		  (INTEGERP B)
		  (<= 0 B)
		  (INTEGERP K)
		  (<= 0 K)
		  (< A (EXPT 2 K))
		  (< B (EXPT 2 K)))
	     (= (LOP A b 1 k)
		(EXPO (LOGIOR (* 2 A)
			      (LNOT (* 2 b) (1+ k))))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable lnot logior lop)
		  :use (lop2-8 lop2-19 lop2-9)))))

(local (defthm lop2-21
    (implies (and (integerp a)
		  (>= a 0)
		  (integerp b)
		  (>= b 0)
		  (integerp k)
		  (>= k 0)
		  (< a (expt 2 k))
		  (< b (expt 2 k)))
	     (= (lop a b 1 k)
		(expo (logior (* 2 a) (lnot (* 2 b) (1+ k))))))
  :rule-classes ()
  :hints (("Goal" :induct (lop2-induct k a b))
	  ("Subgoal *1/1" :use (lop2-20)))))

(local (defthm lop2-22
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e))
	     (= (bitn a e) 1))
  :rule-classes ()
  :hints (("Goal" :use ((:instance expo-upper-bound (x a))
			(:instance expo-monotone (x 1) (y a))
			(:instance expo-lower-bound (x a))
			(:instance bit-expo-b (x a) (n e)))))))

;move?
(local (defthm lop2-23
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e))
	     (= (bitn b e) 0))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable EXPO-COMPARISON-REWRITE-TO-BOUND
                                      EXPO-BOUND-ERIC
                                      expt-compare
                                       EXPO-COMPARISON-REWRITE-TO-BOUND-2)
           :use ((:instance expo-upper-bound (x b))
			(:instance expo-monotone (x 1) (y a))
			(:instance expt-weak-monotone (n (1+ (expo b))) (m e))
			(:instance bit-expo-a (x b) (n e)))))))

(local (defthm lop2-24
         (implies (and (integerp a)
                       (> a 0)
                       (integerp b)
                       (> b 0)
                       (= e (expo a))
                       (< (expo b) e))
                  (= (lop a b 0 (1+ e))
                     (lop a b 1 e)))
         :rule-classes ()
         :hints (("Goal" :in-theory (enable lop)
                  :use (lop2-22 
			lop2-23
			(:instance expo-monotone (x 1) (y a)))))))

(local (defthm lop2-25
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e)
		  (= lambda
		     (logior (* 2 (mod a (expt 2 e)))
			     (lnot (* 2 b) (1+ e)))))
	     (= (lop (mod a (expt 2 e)) b 1 e)
		(expo lambda)))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable EXPO-COMPARISON-REWRITE-TO-BOUND
                                      EXPO-BOUND-ERIC
                                      expt-compare
                                       EXPO-COMPARISON-REWRITE-TO-BOUND-2)
           :use ((:instance lop2-21 (a (mod a (expt 2 e))) (k e))
			(:instance expo-upper-bound (x b))
			(:instance expo-monotone (x 1) (y a))
			(:instance expt-weak-monotone (n (1+ (expo b))) (m e))
;			(:instance mod>=0 (m a) (n (expt 2 e)))
			(:instance mod-bnd-1 (m a) (n (expt 2 e))))))) )

(local (defthm lop2-26
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e)
		  (= lambda
		     (logior (* 2 (mod a (expt 2 e)))
			     (lnot (* 2 b) (1+ e)))))
	     (= (lop (mod a (expt 2 e)) b 1 e)
		(lop a b 1 e)))
  :rule-classes ()
  :hints (("Goal"  :in-theory (disable EXPO-COMPARISON-REWRITE-TO-BOUND
                                      EXPO-BOUND-ERIC
                                      expt-compare
                                       EXPO-COMPARISON-REWRITE-TO-BOUND-2)
           :use ((:instance lop-mod (d 1) (j e) (k e))
			(:instance mod-does-nothing (m b) (n (expt 2 e)))
			(:instance expo-upper-bound (x b))
			(:instance expo-monotone (x 1) (y a))
			(:instance expt-weak-monotone (n (1+ (expo b))) (m e)))))))

(local (defthm lop2-27
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e)
		  (= lambda
		     (logior (* 2 (mod a (expt 2 e)))
			     (lnot (* 2 b) (1+ e)))))
	     (= (lop a b 0 (1+ e))
		(expo lambda)))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable logior lop)
		  :use (lop2-24 lop2-25 lop2-26)))))

(defthm olop-thm-1
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e)
		  (= lambda
		     (logior (* 2 (mod a (expt 2 e)))
			     (lnot (* 2 b) (1+ e)))))
	     (or (= (expo (- a b)) (expo lambda))
		 (= (expo (- a b)) (1- (expo lambda)))))
  :rule-classes ()
  :hints (("Goal" :in-theory (disable logior lop)
		  :use (lop2-27
			(:instance expo-upper-bound (x b))
			(:instance expo-monotone (x 1) (y a))
			(:instance expt-weak-monotone (n (1+ (expo b))) (m e))
			(:instance expo-upper-bound (x a))
			(:instance lop-bnds (n (1+ e)))))))



(local (defthm hack-1
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e))
	     (bvecp (* 2 (mod a (expt 2 e)))
		    (1+ e)))
  :rule-classes ()
  :hints (("Goal" :in-theory (enable lior0 bvecp bits-tail)
		  :expand ((EXPT 2 (+ 1 (EXPO A))))
		  :use ((:instance mod-bnd-1 (m a) (n (expt 2 e)))
			(:instance expo-monotone (x 1) (y a))))))			)

(local (defthm hack-2
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e))
	     (bvecp (lnot (* 2 b) (1+ e))
		    (1+ e)))
  :rule-classes ()
  :hints (("Goal" :in-theory (union-theories (disable bits-bvecp) '(lnot bvecp))
		  :use ((:instance expo-monotone (x 1) (y a))
			(:instance bits-bvecp (x (* 2 b)) (i e) (j 0) (k (1+ e)))
			(:instance expo-upper-bound (x b)))))))

(defthm lop-thm-1-original
    (implies (and (integerp a)
		  (> a 0)
		  (integerp b)
		  (> b 0)
		  (= e (expo a))
		  (< (expo b) e)
		  (= lambda
		     (lior0 (* 2 (mod a (expt 2 e)))
			   (lnot (* 2 b) (1+ e))
			   (1+ e))))
	     (or (= (expo (- a b)) (expo lambda))
		 (= (expo (- a b)) (1- (expo lambda)))))
  :rule-classes ()
  :hints (("Goal" :in-theory (enable lior0 bits-tail)
		  :use (olop-thm-1
			hack-1
			hack-2))))