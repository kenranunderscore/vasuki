(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload '(:croatoan-ncurses :slynk)))

(defpackage #:vasuki
  (:use :cl))

(in-package #:vasuki)

(defun init-ncurses ()
  (ncurses:initscr)
  (ncurses:cbreak)
  (ncurses:noecho)
  (ncurses:clear))

(defun main ()
  (init-ncurses)
  ;; draw a Sierpinski triangle: https://www.linuxjournal.com/content/getting-started-ncurses
  (let* ((maxlines (- ncurses:lines 1))
         (maxcols (- ncurses:cols 1))
         (x (list 0 (truncate maxcols 2) maxcols))
         (y (list 0 maxlines 0))
         (xi (mod (random 10000) maxcols))
         (yi (mod (random 10000) maxlines)))
    (ncurses:mvaddstr (car y) (car x) "0")
    (ncurses:mvaddstr (cadr y) (cadr x) "1")
    (ncurses:mvaddstr (caddr y) (caddr x) "2")
    (ncurses:mvaddstr yi xi ".")
    (dotimes (i 1000)
      (progn
        (let ((index (mod (random 10000) 3)))
          (setf yi (truncate (+ yi (nth index y)) 2))
          (setf xi (truncate (+ xi (nth index x)) 2))
          (ncurses:mvaddstr yi xi "*")
          (ncurses:refresh))))
    (ncurses:mvaddstr maxlines 0 "Press any key to quit.")
    (ncurses:refresh)
    (ncurses:getch)
    (ncurses:endwin)))

(slynk:create-server :port 4321
                     :dont-close t)

(main)
