; Matt Kaufmann

; This book provides a test for the correct implementation of step-limits.

(in-package "ACL2")

(include-book "misc/eval" :dir :system)

(must-succeed
; 380 steps exactly in a version between ACL2 4.2 and 4.3
 (with-prover-step-limit 
  380
  (thm
   (equal (append x (append y z)) 
          (append (append x y) z)))))

(must-fail
; 380 steps exactly in a version between ACL2 4.2 and 4.3
 (with-prover-step-limit 
  379
  (thm
   (equal (append x (append y z)) 
          (append (append x y) z)))))

(must-fail
; 380 steps exactly in a version between ACL2 4.2 and 4.3
 (with-prover-step-limit 
  200 ; we thus expect 201 steps used; "more than 200" reported for the thm
  (thm
   (equal (append x (append y z)) 
          (append (append x y) z)))))

(set-prover-step-limit 300)

; The following fails without inner with-prover-step-limit, which just have an
; extra argument of t, because otherwise more than the allocated 300 steps are
; charged to the must-fail form (i.e., to the make-event form generated by the
; call of must-fail).
(must-fail
 (with-prover-step-limit
  :start
  t
  (thm
   (equal (append x (append y z)) 
          (append (append x y) z)))))

; The following fails unless the extra argument of t is given to the inner
; with-prover-step-limit, because otherwise more than the allocated 300 steps
; are charged to the must-succeed form (i.e., to the make-event form generated
; by the call of must-succeed).
(must-succeed
 (with-prover-step-limit
  500
  t
  (thm
   (equal (append x (append y z)) 
          (append (append x y) z)))))

(with-prover-step-limit
 200
 (must-fail
  (with-prover-step-limit
   :start
   t
   (thm
    (equal (append x (append y z)) 
           (append (append x y) z))))))

(set-prover-step-limit 500)

(must-succeed
 (thm
  (equal (append x (append y z)) 
         (append (append x y) z))))

(must-fail
 (with-prover-step-limit 
  300
  (thm
   (equal (append x (append y z)) 
          (append (append x y) z)))))

; See long comments "The following fails ...." above for why we need the call
; of with-prover-step-limit just below, with third argument t.
(must-fail
 (with-prover-step-limit
  :start
  t
  (encapsulate
   ()
   (defthm test1
     (equal (append x (append y z)) 
            (append (append x y) z))
     :rule-classes nil)
   (defthm test2
     (equal (append x (append y z)) 
            (append (append x y) z))
     :rule-classes nil))))

; As above:
(with-prover-step-limit
 500
 (must-fail
  (with-prover-step-limit
   :start
   t
   (encapsulate
    ()
    (defthm test1
      (equal (append x (append y z)) 
             (append (append x y) z))
      :rule-classes nil)
    (defthm test2
      (equal (append x (append y z)) 
             (append (append x y) z))
      :rule-classes nil)))))

; See long comments "The following fails ...." above for why we need the call
; of with-prover-step-limit just below, with third argument t.
(must-fail ; fails at the very end
 (with-prover-step-limit
  :start
  t
  (encapsulate
   ()
   (defthm test1
     (equal (append x (append y z)) 
            (append (append x y) z))
     :rule-classes nil)
   (with-prover-step-limit 
    500
    (defthm test2
      (equal (append x (append y z)) 
             (append (append x y) z))
      :rule-classes nil)))))

; As above:
(with-prover-step-limit
 500
 (must-fail ; fails at the very end
  (with-prover-step-limit
   :start
   t
   (encapsulate
    ()
    (defthm test1
      (equal (append x (append y z)) 
             (append (append x y) z))
      :rule-classes nil)
    (with-prover-step-limit 
     500
     (defthm test2
       (equal (append x (append y z)) 
              (append (append x y) z))
       :rule-classes nil))))))

(must-succeed
 (with-prover-step-limit
  1000
  t
  (encapsulate
   ()
   (defthm test1
     (equal (append x (append y z)) 
            (append (append x y) z))
     :rule-classes nil)
   (with-prover-step-limit 
    500
    (defthm test2
      (equal (append x (append y z)) 
             (append (append x y) z))
      :rule-classes nil)))))

; Extra argument of t is needed as usual, because we exceed the global limit of
; 500.
(must-fail
 (with-prover-step-limit
  1000
  t
  (encapsulate
   ()
   (defthm test1
     (equal (append x (append y z)) 
            (append (append x y) z))
     :rule-classes nil)
   (with-prover-step-limit 
    200
    (defthm test2
      (equal (append x (append y z)) 
             (append (append x y) z))
      :rule-classes nil)))))

(must-succeed
 (encapsulate
  ()
  (with-prover-step-limit
   500
   t ; Don't charge for this first defthm
   (defthm test1
     (equal (append x (append y z)) 
            (append (append x y) z))
     :rule-classes nil))
  (defthm test2
    (equal (append x (append y z)) 
           (append (append x y) z))
    :rule-classes nil)))

; Essentially the same as just above.
(must-succeed
 (with-prover-step-limit
  500
  (encapsulate
   ()
   (with-prover-step-limit
    500
    t ; Don't charge for this first defthm
    (defthm test1
      (equal (append x (append y z)) 
             (append (append x y) z))
      :rule-classes nil))
   (defthm test2
     (equal (append x (append y z)) 
            (append (append x y) z))
     :rule-classes nil))))

(set-prover-step-limit 200)

; As usual, we need the extra argument t below in order to avoid having the
; entire must-fail form exceed the limit of 200 steps.
(must-fail
 (with-prover-step-limit
  :start
  t
  (progn
    (set-prover-step-limit 500)
    (defthm test3
      (equal (append x (append y z)) 
             (append (append x y) z))))))

; Setting an explicit limit (even nil, for "unlimited") overrides the global
; default step limit from set-prover-step-limit.
(with-prover-step-limit
 nil
 (progn
   (set-prover-step-limit 500)
   (local ; avoid adding test3 to database upon include-book
    (defthm test3
      (equal (append x (append y z)) 
             (append (append x y) z))))))