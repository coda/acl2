; CUTIL - Centaur Basic Utilities
; Copyright (C) 2008-2012 Centaur Technology
;
; Contact:
;   Centaur Technology Formal Verification Group
;   7600-C N. Capital of Texas Highway, Suite 300, Austin, TX 78731, USA.
;   http://www.centtech.com/
;
; This program is free software; you can redistribute it and/or modify it under
; the terms of the GNU General Public License as published by the Free Software
; Foundation; either version 2 of the License, or (at your option) any later
; version.  This program is distributed in the hope that it will be useful but
; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
; more details.  You should have received a copy of the GNU General Public
; License along with this program; if not, write to the Free Software
; Foundation, Inc., 51 Franklin Street, Suite 500, Boston, MA 02110-1335, USA.
;
; Original author: Jared Davis <jared@centtech.com>
; Modified by David Rager <ragerdl@cs.utexas.edu> to add :assert option
; Modified by Sol Swords <sswords@centtech.com> to add untranslate support

(in-package "CUTIL")
(include-book "formals")
(include-book "returnspecs")
(include-book "xdoc-impl/fmt-to-str" :dir :system)
(include-book "tools/mv-nth" :dir :system)
(include-book "str/cat" :dir :system)
(set-state-ok t)
(program)

(include-book "misc/assert" :dir :system)

(defxdoc define
  :parents (cutil)
  :short "A very fine alternative to @(see defun)."

  :long "<h3>Introduction</h3>

<p>@('define') is an extension of @('defun')/@('defun') with:</p>

<ul>

<li>Richer @('formals') lists that permit keyword/optional arguments, embedded
guards and documentation, automatically infer @(see stobj) declarations,
etc.</li>

<li>A more concise @(see xargs) syntax that also adds control over other
settings like @(see set-ignore-ok), @(see set-irrelevant-formals-ok), and
inlining.</li>

<li>A concise syntax for naming return values, documenting them, and proving
basic theorems (e.g., type-like theorems) about them.</li>

<li>Integration with @(see xdoc) with function signatures derived and a @(see
defsection)-like ability to associate related theorems with your function.</li>

<li>Automatic binding of @('__function__') to the name of the function, which
can be useful in error messages (see, e.g., @(see raise)) and, on CCL at least,
appears to produce identical compiled output when @('__function__') isn't used
in the body.</li>

</ul>

<p>The general form of @('define') is:</p>

@({
 (define name formals
   main-stuff
   [/// other-events])     ;; optional, starts with the symbol ///
})

<p>There's nothing special about the @('name'), it's just the name of the new
function to be defined, as in @(see defun).  The other parts all have their own
syntax and features to cover, and we address them in turn.</p>

<p>The formal have many features; see @(see extended-formals).</p>

<h3>The Main Stuff</h3>

<p>After the formals we get to the main part of the definition.  This section
is a mixed list that may contain:</p>

<ul>
<li><i>Extended options</i> of the form @(':name value')</li>
<li>Declarations of the form @('(declare ...)')</li>
<li>Traditional documentation strings, i.e., @('\"...\"')</li>
<li>The function's body, a term</li>
</ul>

<p>Except for the extended options, this is just like @('defun').</p>

<p>Extended options can go <b>anywhere</b> between the formals and the special
separator @('///') (if any) or the end of the @('define').  Here is a contrived
example:</p>

@({
 (define parse-foo (channel n &optional (state 'state))

   :parents (parser) ;; extended option

   ;; declarations/docstrings must come before body, as in defun
   (declare (type integer n))
   (declare (ignorable channel))
   \"Traditional doc string.  Boo.\"
   (declare (xargs :normalize nil))

   :guard (< 17 n) ;; extended option

   (b* ((next (peek-char channel state))  ;; function's body
        ...)
      (mv result state))

   :measure (file-measure channel state)  ;; more extended opts.
   :hints ((\"Goal\" ...))
   :guard-debug t)
})

<p>How does this work, exactly?  Ordinarily, @('defun') distinguishes the
function's body from documentation strings and declarations using a simple
rule: the last item is the function's body, and everything before it must be a
declaration or documentation string.  For @('define'), we simply add a
preprocessing step:</p>

<ul>
<li>First, all of the extended options are extracted.</li>
<li>Then, the remaining parts are handled using the ordinary @('defun') rule.</li>
</ul>

<p>There is one special case where this approach is <b>incompatible</b> with
@('defun'): if your function's body is nothing more than a keyword symbol,
e.g.,</p>

@({
 (defun returns-foo (x)
   (declare (ignore x))
   :foo)
})

<p>then it cannot be converted into a @('define') since the body looks like
a (malformed) extended option.  I considered workarounds to avoid this, but
decided that it is better to just live with not being able to define these
kinds of functions.  They are very weird, anyway.</p>

<h4>Basic Extended Options</h4>

<p>All @(see xargs) are available as extended options.  In practice this just
makes things more concise and better looking, e.g., compare:</p>

@({
 (defun strpos-fast (x y n xl yl)
   (declare (xargs :guard (and ...)
                   :measure (nfix ...)))
   ...)
 vs.
 (define strpos-fast (x y n xl yl)
   :guard (and ...)
   :measure (nfix ...)
   ...)
})

<p>Some additional minor options include:</p>

<dl>

<dt>@(':enabled val')</dt>

<dd>By default the function will be disabled after the @('other-events') are
processed.  If @(':enabled t') is provided, we will leave it enabled,
instead.</dd>

<dt>@(':ignore-ok val')</dt>

<dd>Submits @('(set-ignore-ok val)') before the definition.  This option is
local to the @('define') only and does not affect the @('other-events').</dd>

<dt>@(':irrelevant-formals-ok val')</dt>

<dd>Submits @('(set-irrelevant-formals-ok val)') before the definition; local
to this @('define') only and not to any @('other-events').</dd>

<dt>@(':inline val')</dt>

<dd>Generates an inline function instead of an ordinary function, in a manner
similar to @(see defun-inline).</dd>

<dt>@(':parents parent-list')</dt>
<dt>@(':short str')</dt>
<dt>@(':long str')</dt>

<dd>These are @(see defxdoc)-style options for documenting the function.  They
are passed to a @('defsection') for this definition.</dd>

<dt>@(':prepwork events')</dt>

<dd>These are any arbitrary events you want to put before the definition
itself, for instance it might include @('-aux') functions or local lemmas
needed for termination.</dd>

</dl>

<h4>@('Returns') Specifications</h4>

<p>See @(see returns-specifiers)</p>

<h4>@('Assert') Specification</h4>

<p>It can be convenient when testing code to check that the arguments of a
function meet certain criteria, and ACL2 implements that check with a @(see
guard).  In order to take this idea one step further, @('define') provides a
way to check the return value of the defined function at run-time, through the
@(':assert') keyword argument.</p>

<p>The @(':assert') keyword accepts either a symbol or a list of symbols.  In
the event that a symbol or a list containing exactly one symbol is provided, a
check will be added near the end of the defined function's body that checks
that the return value passes the predicate associated with that symbol.
Sometimes the defined function will return multiple-values.  In this case, the
argument given to @(':assert') should be a list of symbols, of length equal to
the number of return values.  @('Define') will then take each symbol and use
its associated function to check that the <i>i</i>'th return value passes the
<i>i</i>'th predicate symbol's test (where <i>i</i> ranges from 1 to the number
of values returned by the defined function).</p>

<p>In the long-term, we would like @('define') to only require a Boolean value
as the argument to @(':assert') and to infer the requirements of the return
values from the @(':returns') specifications.  If any user wishes to make this
change to @('define'), they should feel free to do so.</p>

<p>Another problem of the current implementation of @(':assert') is that if the
same predicate is used twice, the @('define') will break.  A workaround for
this is to define a second predicate that is simply a wrapper for the desired
predicate.  The user can then use that second predicate in the second place it
is needed.</p>

<p>BOZO assert is probably orthogonal to define and should just be turned into
some kind of tracing/advise mechanism.</p>


<h3>The Other Events</h3>

<p>The final part of a @('define') is an area for any arbitrary events to be
put.  These events will follow the function's definition, but will be submitted
<b>before</b> disabling the function.</p>

<p>Any event can be included here, but this space is generally intended for
theorems that are \"about\" the function that has just been defined.  The
events in this area will be included in the @(see xdoc), if applicable, as if
they were part of the same @(see defsection).</p>

<p>To distinguish the @('other-events') from the @('main-stuff'), we use the
special symbol @('///') to separate the two.</p>

<p>Why do we use this goofy symbol?  In Common Lisp, @('///') has a special
meaning and is used by the Lisp read-eval-print loop.  Because of that, ACL2
does not allow you to bind it in @(see let) statements or use it as a formal in
a definition.  Because of <i>that</i>, we can be sure that @('///') is not the
body of any function definition, so it can be reliably used to separate the
rest-events.  As bonus features, @('///') is already imported by any <see
topic='@(url defpkg)'>package</see> that imports
@('*common-lisp-symbols-from-main-lisp-package*'), and even sort of looks like
some kind of separator!</p>


")






; -------------- Assertion Specifications -------------------------------------

(defun parse-assert-tests (assertion ctx)
  (declare (xargs :guard (symbol-listp assertion)))
  (cond ((atom assertion)
         nil)

; Predicate's symbol is also the local variable name.  It would be good to call
; gensym, along with a call of check-vars-not-free so that the same predicate
; could be used twice.  I'm not fixing this for now, because really we should
; be using the returns specifications, and doing so will obviate this issue.

        (t (cons `(if (,(car assertion) ,(car assertion))
                      t
                    (er hard? ',ctx
                        "Assertion failure.  The following was supposed to ~
                           be of type ~x0: ~x1"
                        ',(car assertion)
                        ,(car assertion)))
                 (parse-assert-tests (cdr assertion) ctx)))))


; -------------- Main Stuff Parsing -------------------------------------------

(defun get-xargs-from-kwd-alist (kwd-alist)
  "Returns (mv xarg-stuff rest-of-kwd-alist)"
  (declare (xargs :guard (alistp kwd-alist)))
  (b* (((when (atom kwd-alist))
        (mv nil nil))
       ((cons (cons key1 val1) rest) kwd-alist)
       ((mv xarg-stuff kwd-alist)
        (get-xargs-from-kwd-alist rest))
       ((when (member key1 acl2::*xargs-keywords*))
        (mv (list* key1 val1 xarg-stuff) kwd-alist)))
    (mv xarg-stuff (acons key1 val1 kwd-alist))))

(defun get-before-events-from-kwd-alist (kwd-alist)
  "Returns (mv events rest-of-kwd-alist)"
  (declare (xargs :guard (alistp kwd-alist)))
  (b* (((when (atom kwd-alist))
        (mv nil nil))
       ((cons (cons key1 val1) rest) kwd-alist)
       ((mv events kwd-alist)
        (get-before-events-from-kwd-alist rest))
       ((when (eq key1 :ignore-ok))
        (mv (cons `(set-ignore-ok ,val1) events) kwd-alist))
       ((when (eq key1 :irrelevant-formals-ok))
        (mv (cons `(set-irrelevant-formals-ok ,val1) events) kwd-alist)))
    (mv events (acons key1 val1 kwd-alist))))

(defun get-xdoc-stuff (kwd-alist)
  "Returns (mv parents short long rest-of-kwd-alist)"
  (declare (xargs :guard (alistp kwd-alist)))
  (b* ((parents (cdr (assoc :parents kwd-alist)))
       (short   (cdr (assoc :short kwd-alist)))
       (long    (cdr (assoc :long kwd-alist)))
       (kwd-alist (delete-assoc :parents kwd-alist))
       (kwd-alist (delete-assoc :short kwd-alist))
       (kwd-alist (delete-assoc :long kwd-alist)))
    (mv parents short long kwd-alist)))

(defun get-defun-params (kwd-alist)
  "Returns (mv enabled-p inline-p prepwork rest-of-kwd-alist)"
  (declare (xargs :guard (alistp kwd-alist)))
  (b* ((enabled-p (cdr (assoc :enabled kwd-alist)))
       (inline-p  (cdr (assoc :inline kwd-alist)))
       (prepwork  (cdr (assoc :prepwork kwd-alist)))
       (kwd-alist (delete-assoc :enabled kwd-alist))
       (kwd-alist (delete-assoc :inline kwd-alist))
       (kwd-alist (delete-assoc :prepwork kwd-alist)))
    (mv enabled-p inline-p prepwork kwd-alist)))

(defun get-assertion (kwd-alist)
  "Returns (mv assertion rest-of-kwd-alist)"
  (declare (xargs :guard (alistp kwd-alist)))
  (b* ((assertion (cdr (assoc :assert kwd-alist)))
       (assertion (if (and (atom assertion) (not (null assertion)))
                      (list assertion)
                    assertion))
       (kwd-alist (delete-assoc :assert kwd-alist)))
    (mv assertion kwd-alist)))

(defun get-returns (kwd-alist)
  "Returns (mv returns rest-of-kwd-alist)"
  (declare (xargs :guard (alistp kwd-alist)))
  (b* ((returns   (cdr (assoc :returns kwd-alist)))
       (kwd-alist (delete-assoc :returns kwd-alist)))
    (mv returns kwd-alist)))


(defconst *define-keywords*
  (append '(:ignore-ok
            :irrelevant-formals-ok
            :parents
            :short
            :long
            :inline
            :enabled
            :returns
            :assert
            :prepwork
            )
          acl2::*xargs-keywords*))



; -------------- XDOC Signatures ----------------------------------------------

; The idea here is to write out a signature that shows the names of the formals
; and return values, and then provides the documentation for any documented
; formals/returns.
;
; The formals always have names, but the return values will only have names if
; someone has named them with :returns.  If we don't have return-value names,
; we can at least look up the stobjs-out property and see how many return
; values there are, and if any of them are stobj names they'll have names.
; This will also let us double-check the return value arities.

(defun nils-to-stars (x)
  (declare (xargs :guard t))
  (cond ((atom x)
         nil)
        ((eq (car x) nil)
         (cons '* (nils-to-stars (cdr x))))
        (t
         (cons (car x) (nils-to-stars (cdr x))))))

(defun return-value-names (fnname returnspecs world)
  (declare (xargs :guard (and (symbolp fnname)
                              (returnspeclist-p returnspecs)
                              (plist-worldp world))))
  (b* ((stobjs-out (look-up-return-vals fnname world))
       ((when (atom returnspecs))
        ;; Fine, the user just didn't name/document the return values...
        (nils-to-stars stobjs-out))
       ((unless (equal (len stobjs-out) (len returnspecs)))
        (er hard? 'return-value-names
            "Error in ~x0: ACL2 thinks this function has ~x0 return ~
             values, but :returns has ~x1 entries!"
            (len stobjs-out)
            (len returnspecs))))
    ;; Else the user documented things, so everything has a name and we should
    ;; be just fine.
    (returnspeclist->names returnspecs)))

(defun make-xdoc-signature
  (wrapper            ; name of wrapper function, a symbol
   return-value-names ; names of return values, a symbol list
   base-pkg           ; base package for printing
   acc                ; accumulator for chars in reverse order
   state)
  "Returns (mv acc state)"
  (b* ((args (look-up-wrapper-args wrapper (w state)))
       (call-sexpr (cons wrapper args))
       (ret-sexpr (cond ((atom return-value-names)
                         (er hard? 'make-xdoc-signature
                             "Expected at least one return value name."))
                        ((atom (cdr return-value-names))
                         ;; Just one return value, don't do any MV stuff.
                         (car return-value-names))
                        (t
                         (cons 'mv return-value-names))))

       ((mv call-str state) (xdoc::fmt-to-str call-sexpr base-pkg state))
       ((mv ret-str state)  (xdoc::fmt-to-str ret-sexpr base-pkg state))
       (call-len (length call-str)) ;; sensible since not yet encoded
       (ret-len  (length ret-str))  ;; sensible since not yet encoded
       (acc (str::revappend-chars "<dt>Signature</dt><dt>" acc))
       (acc (if (< (+ call-len ret-len) 60)
                ;; Short signature, so put it all on the same line.  I'm still
                ;; going to use <code> instead of <tt>, for consistency.
                (b* ((acc (str::revappend-chars "<code>" acc))
                     (acc (xdoc::simple-html-encode-str call-str 0 call-len acc))
                     (acc (str::revappend-chars " &rarr; " acc))
                     (acc (xdoc::simple-html-encode-str ret-str 0 ret-len acc))
                     (acc (str::revappend-chars "</code>" acc)))
                  acc)
              ;; Long signature, so split it across lines.  Using <code> here
              ;; means it's basically okay if there are line breaks in call-str
              ;; or ret-str.
              (b* ((acc (str::revappend-chars "<code>" acc))
                   (acc (xdoc::simple-html-encode-str call-str 0 call-len acc))
                   (acc (cons #\Newline acc))
                   (acc (str::revappend-chars "  &rarr;" acc))
                   (acc (cons #\Newline acc))
                   (acc (xdoc::simple-html-encode-str ret-str 0 ret-len acc))
                   (acc (str::revappend-chars "</code>" acc)))
                acc)))
       (acc (str::revappend-chars "</dt>" acc)))
    (mv acc state)))


(defun formal-can-generate-doc-p (x)
  (declare (xargs :guard (formal-p x)))
  (b* (((formal x) x))
    (or (not (equal x.doc ""))
        (not (eq x.guard t)))))

(defun formals-can-generate-doc-p (x)
  (declare (xargs :guard (formallist-p x)))
  (if (atom x)
      nil
    (or (formal-can-generate-doc-p (car x))
        (formals-can-generate-doc-p (cdr x)))))

(defun doc-from-formal (x acc base-pkg state)
  (declare (xargs :guard (formal-p x)))
  (b* (((formal x) x)

       ((unless (formal-can-generate-doc-p x))
        (mv acc state))

       (acc (str::revappend-chars "<dd>" acc))
       ((mv name-str state) (xdoc::fmt-to-str x.name base-pkg state))
       (acc (str::revappend-chars "<tt>" acc))
       (acc (xdoc::simple-html-encode-str name-str 0 (length name-str) acc))
       (acc (str::revappend-chars "</tt>" acc))
       (acc (str::revappend-chars " &mdash; " acc))

       (acc (if (equal x.doc "")
                acc
              (b* ((acc (str::revappend-chars x.doc acc))
                   (acc (if (ends-with-period-p x.doc)
                            acc
                          (cons #\. acc))))
                acc)))

       ((when (eq x.guard t))
        (b* ((acc (str::revappend-chars "</dd>" acc))
             (acc (cons #\Newline acc)))
          (mv acc state)))

       (acc (if (equal x.doc "")
                acc
              (str::revappend-chars "<br/>&nbsp;&nbsp;&nbsp;&nbsp;" acc)))
       (acc (str::revappend-chars "<color rgb='#606060'>" acc))
       ((mv guard-str state) (xdoc::fmt-to-str x.guard base-pkg state))
       ;; Using @('...') here isn't necessarily correct.  If the sexpr has
       ;; something in it that can lead to '), we are hosed.  BOZO eventually
       ;; check for this and make sure we use <code> tags instead, if it
       ;; happens.
       (acc (str::revappend-chars "Guard @('" acc))
       (acc (str::revappend-chars guard-str acc))
       (acc (str::revappend-chars "').</color></dd>" acc))
       (acc (cons #\Newline acc)))
    (mv acc state)))

(defun doc-from-formals-aux (x acc base-pkg state)
  (declare (xargs :guard (formallist-p x)))
  (b* (((when (atom x))
        (mv acc state))
       ((mv acc state)
        (doc-from-formal (car x) acc base-pkg state)))
    (doc-from-formals-aux (cdr x) acc base-pkg state)))

(defun doc-from-formals (x acc base-pkg state)
  (declare (xargs :guard (formallist-p x)))
  (b* (((unless (formals-can-generate-doc-p x))
        (mv acc state))
       (acc (str::revappend-chars "<dt>Arguments</dt>" acc))
       ((mv acc state) (doc-from-formals-aux x acc base-pkg state)))
    (mv acc state)))


(defun returnspec-can-generate-doc-p (x)
  (declare (xargs :guard (returnspec-p x)))
  (b* (((returnspec x) x))
    (or (not (equal x.doc ""))
        (not (eq x.return-type t)))))

(defun returnspecs-can-generate-doc-p (x)
  (declare (xargs :guard (returnspeclist-p x)))
  (if (atom x)
      nil
    (or (returnspec-can-generate-doc-p (car x))
        (returnspecs-can-generate-doc-p (cdr x)))))

(defun doc-from-returnspec (x acc base-pkg state)
  (declare (xargs :guard (returnspec-p x)))
  (b* (((returnspec x) x)

       ((unless (returnspec-can-generate-doc-p x))
        (mv acc state))

       (acc (str::revappend-chars "<dd>" acc))
       ((mv name-str state) (xdoc::fmt-to-str x.name base-pkg state))
       (acc (str::revappend-chars "<tt>" acc))
       (acc (xdoc::simple-html-encode-str name-str 0 (length name-str) acc))
       (acc (str::revappend-chars "</tt>" acc))
       (acc (str::revappend-chars " &mdash; " acc))

       (acc (if (equal x.doc "")
                acc
              (b* ((acc (str::revappend-chars x.doc acc))
                   (acc (if (ends-with-period-p x.doc)
                            acc
                          (cons #\. acc))))
                acc)))

       ((when (eq x.return-type t))
        (b* ((acc (str::revappend-chars "</dd>" acc))
             (acc (cons #\Newline acc)))
          (mv acc state)))

       (acc (if (equal x.doc "")
                acc
              (str::revappend-chars "<br/>&nbsp;&nbsp;&nbsp;&nbsp;" acc)))
       (acc (str::revappend-chars "<color rgb='#606060'>" acc))
       ((mv type-str state) (xdoc::fmt-to-str x.return-type base-pkg state))
       ;; Using @('...') here isn't necessarily correct.  If the sexpr has
       ;; something in it that can lead to '), we are hosed.  BOZO eventually
       ;; check for this and make sure we use <code> tags instead, if it
       ;; happens.
       (acc (str::revappend-chars "Type @('" acc))
       (acc (str::revappend-chars type-str acc))
       (acc (str::revappend-chars "')" acc))
       ((mv acc state)
        (cond ((eq x.hyp t)
               (mv (cons #\. acc) state))
              ((or (eq x.hyp :guard)
                   (eq x.hyp :fguard))
               (mv (str::revappend-chars ", given the @(see guard)." acc)
                   state))
              (t
               (b* ((acc (str::revappend-chars ", given @('" acc))
                    ((mv hyp-str state)
                     (xdoc::fmt-to-str x.hyp base-pkg state))
                    (acc (str::revappend-chars hyp-str acc))
                    (acc (str::revappend-chars "')." acc)))
                 (mv acc state)))))
       (acc (str::revappend-chars "</color>" acc))
       (acc (str::revappend-chars "</dd>" acc))
       (acc (cons #\Newline acc)))

    (mv acc state)))

(defun doc-from-returnspecs-aux (x acc base-pkg state)
  (declare (xargs :guard (returnspeclist-p x)))
  (b* (((when (atom x))
        (mv acc state))
       ((mv acc state)
        (doc-from-returnspec (car x) acc base-pkg state)))
    (doc-from-returnspecs-aux (cdr x) acc base-pkg state)))

(defun doc-from-returnspecs (x acc base-pkg state)
  (declare (xargs :guard (returnspeclist-p x)))
  (b* (((unless (returnspecs-can-generate-doc-p x))
        (mv acc state))
       (acc (str::revappend-chars "<dt>Returns</dt>" acc))
       ((mv acc state) (doc-from-returnspecs-aux x acc base-pkg state)))
    (mv acc state)))

(defun make-xdoc-top (wrapper fnname formals returnspecs base-pkg state)
  "Returns (mv str state)"
  (b* ((world (w state))
       (acc nil)
       (acc (str::revappend-chars "<box><dl>" acc))
       (acc (cons #\Newline acc))
       (return-value-names (return-value-names fnname returnspecs world))
       ((mv acc state) (make-xdoc-signature wrapper return-value-names base-pkg acc state))
       ((mv acc state) (doc-from-formals formals acc base-pkg state))
       ((mv acc state) (doc-from-returnspecs returnspecs acc base-pkg state))
       (acc (str::revappend-chars "</dl></box>" acc))
       (acc (cons #\Newline acc))
       (str (str::rchars-to-string acc)))
    (mv str state)))


; -------------- Top-Level Macro ----------------------------------------------

(defun define-fn (fnname formals args world)
  (declare (xargs :guard (plist-worldp world)))
  (b* (((unless (symbolp fnname))
        (er hard? 'define-fn
            "Expected function names to be symbols, but found ~x0."
            fnname))

       ((mv main-stuff rest-events) (split-/// fnname args))
       ((mv kwd-alist normal-defun-stuff)
        (extract-keywords fnname *define-keywords* main-stuff nil))
       (traditional-decls/docs (butlast normal-defun-stuff 1))
       (body          (car (last normal-defun-stuff)))
       (extended-body `(let ((__function__ ',fnname))
                         ;; CCL's compiler seems to be smart enough to not
                         ;; generate code for this binding when it's not
                         ;; needed.
                         (declare (ignorable __function__))
                         ,body))

       ((mv xargs kwd-alist)              (get-xargs-from-kwd-alist kwd-alist))
       ((mv returns kwd-alist)            (get-returns kwd-alist))
       ((mv before-events kwd-alist)      (get-before-events-from-kwd-alist kwd-alist))
       ((mv parents short long kwd-alist) (get-xdoc-stuff kwd-alist))
       ((mv enabled-p inline-p prepwork kwd-alist)
        (get-defun-params kwd-alist))
       ((mv assertion kwd-alist)          (get-assertion kwd-alist))
       ((unless (symbol-listp assertion))
        (er hard? 'define-fn
            "Error in ~x0: expected :assert to be either a symbol or a ~
             symbol-listp, but found ~x1."
            fnname assertion))
       (ruler-extenders (if assertion :all nil))

       ((unless (true-listp prepwork))
        (er hard? 'define-fn
            "Error in ~x0: expected :prepwork to be a true-listp, but found ~x1."
            fnname prepwork))

       ((when kwd-alist)
        (er hard? 'define-fn
            "Error in ~x0: expected all keywords to be accounted for, but ~
             still have ~x1 after extracting everything we know about."
            fnname (strip-cars kwd-alist)))

       (need-macrop   (or inline-p (has-macro-args formals)))
       (fnname-fn     (cond (inline-p
                             (intern-in-package-of-symbol
                              (concatenate 'string (symbol-name fnname) "$INLINE")
                              fnname))
                            (need-macrop
                             (intern-in-package-of-symbol
                              (concatenate 'string (symbol-name fnname) "-FN")
                              fnname))
                            (t
                             fnname)))

       (macro         (and need-macrop
                           (make-wrapper-macro fnname fnname-fn formals)))
       (formals       (remove-macro-args fnname formals nil))
       (formals       (parse-formals fnname formals nil))
       (formal-names  (formallist->names formals))
       (formal-guards (remove t (formallist->guards formals)))
       (stobj-names   (formallist->names (formallist-collect-stobjs formals world)))

       (assert-mv-let-bindings assertion)
       (assert-tests (parse-assert-tests assertion fnname-fn))

       (returnspecs   (parse-returnspecs fnname returns world))
       (defun-sym     (if enabled-p 'defun 'defund))

       (main-def
        `(,defun-sym ,fnname-fn ,formal-names
           ,@(cond ((atom formal-guards)
                    ;; Design decision: I prefer to put in a declaration here
                    ;; instead of leaving it out.  This makes define trigger
                    ;; guard verification even with eagerness 1.  I think I
                    ;; much more frequently have guards of T than want to not
                    ;; verify guards.
                    `((declare (xargs :guard t))))
                   ((atom (cdr formal-guards))
                    `((declare (xargs :guard ,(car formal-guards)))))
                   (t
                    `((declare (xargs :guard (and . ,formal-guards))))))
           ,@(and stobj-names `((declare (xargs :stobjs ,stobj-names))))
           ,@(and xargs       `((declare (xargs . ,xargs))))

;; Bozo (that only applies in the :assert case), we should merge the
;; ruler-extenders or figure out a way to do the assertions without them.

           ,@(and ruler-extenders `((declare (xargs :ruler-extenders
                                                    ,ruler-extenders))))
           ,@traditional-decls/docs
           ,(if assertion
                `(mv?-let ,assert-mv-let-bindings
                          ,extended-body
                          (prog2$ (and ,@assert-tests)
                                  (mv? ,@assert-mv-let-bindings)))
                extended-body))))

    `(progn
       (defsection ,fnname
         ,@(and parents `(:parents ,parents))
         ,@(and short   `(:short ,short))
         ,@(and long    `(:long ,long))

         ;; Define the macro first, so that it can be used in recursive calls,
         ;; e.g., to take advantage of nicer optional/keyword args.
         ,@(and need-macrop `(,macro))

         ,@prepwork

         ,@(if before-events
               `((encapsulate ()
                   ,@before-events
                   ,main-def))
             `(,main-def))

         ,@(and need-macrop `((add-macro-alias ,fnname ,fnname-fn)
                              (table define-macro-fns ',fnname-fn ',fnname)))

         (local (in-theory (enable ,fnname)))

         (make-event
          (let* ((world (w state))
                 (events (returnspec-thms ',fnname-fn ',returnspecs world)))
            (value `(progn . ,events))))

         . ,rest-events)

       ;; Now that the section has been submitted, its xdoc exists, so we can
       ;; do the doc generation and prepend it to the xdoc.
       ,(if (not (or parents long short))
            '(value-triple :invisible)
          `(make-event
            (b* ((current-pkg (acl2::f-get-global 'acl2::current-package state))
                 (base-pkg    (pkg-witness current-pkg))
                 (fnname      ',fnname)
                 ((mv str state)
                  (make-xdoc-top fnname ',fnname-fn
                                 ',formals ',returnspecs
                                 base-pkg state))
                 (event (list 'xdoc::xdoc-prepend fnname str)))
              (value event))))
       )))

(defmacro define (name formals &rest args)
  `(make-event (b* ((world (w state))
                    (event (define-fn ',name ',formals ',args world)))
                 (value event))))

#!ACL2
(progn
  ;; Returns (mv successp arglist).
  ;; If DEFINE has created a macro wrapper for a function, which may have
  ;; optional or keyword args, we'd terms involving the function to untranslate
  ;; to a correct call of the macro.  This tries to do that.  Args are the
  ;; arguments provided to the function, macro-args is the lambda-list of the
  ;; macro.
  (defun untrans-macro-args (args macro-args opt/key)
    (cond ((endp macro-args)
           (mv (endp args) nil))
          ((endp args) (mv nil nil))
          ((member-eq (car args) '(&whole &body &rest &allow-other-keys))
           ;; unsupported macro arg type
           (mv nil nil))
          ((member (car macro-args) '(&key &optional))
           (untrans-macro-args args (cdr macro-args) (car macro-args)))
          ((not opt/key)
           ;; just variables, no default
           (mv-let (ok rest)
             (untrans-macro-args (cdr args) (cdr macro-args) opt/key)
             (if ok
                 (mv t (cons (car args) rest))
               (mv nil nil))))
          (t (let* ((default (and (< 1 (len (car macro-args)))
                                  ;; unquote of the second element
                                  (cadr (cadr (car macro-args)))))
                    (key (and (eq opt/key '&key)
                              (cond ((symbolp (car macro-args))
                                     (intern (symbol-name (car macro-args)) "KEYWORD"))
                                    ((symbolp (caar macro-args))
                                     (intern (symbol-name (car macro-args)) "KEYWORD"))
                                    (t (caaar macro-args)))))
                    (presentp (< 2 (len (car macro-args)))))
               (if (and (not (equal (car args) default))
                        presentp
                        (not (cadr args)))
                   ;; Looks like presentp is nil but the value is not the
                   ;; default, so things must not be of the expected form.
                   (mv nil nil)
                 (mv-let (ok rest)
                   (untrans-macro-args
                    (if presentp (cddr args) (cdr args))
                    (cdr macro-args) opt/key)
                   (if (not ok)
                       (mv nil nil)
                     (let ((args-out
                            (cond ((and (or (eq opt/key '&key) (not rest))
                                        (equal default (car args))
                                        (or (not presentp)
                                            (not (cadr args))))
                                   ;; default value and not supposed to be present, leave out
                                   rest)
                                  (key (list* key (car args) rest))
                                  (t (cons (car args) rest)))))
                       (mv t args-out)))))))))


  (defun untranslate-preproc-for-define (term world)
    (and (consp term)
         (not (eq (car term) 'quote))
         (symbolp (car term))
         (let* ((macro (cdr (assoc (car term) (table-alist 'define-macro-fns world)))))
           (and macro
                (let ((macro-args
                       (getprop macro 'macro-args nil
                                'current-acl2-world world)))
                  (and macro-args
                       (mv-let (ok newargs)
                         (untrans-macro-args (cdr term) macro-args nil)
                         (and ok
                              (cons macro newargs)))))))))


  (table user-defined-functions-table
         'untranslate-preprocess
         'untranslate-preproc-for-define))



