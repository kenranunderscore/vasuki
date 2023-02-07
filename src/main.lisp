(eval-when (:compile-toplevel :execute :load-toplevel)
  (ql:quickload '(:croatoan :croatoan-ncurses :slynk)))

(defpackage #:vasuki
  (:use :cl))

(in-package #:vasuki)

(defun init-ncurses ()
  (let ((scr (ncurses:initscr)))
    (ncurses:cbreak)
    (ncurses:noecho)
    (ncurses:keypad scr t)
    (ncurses:clear)))

(defclass buffer ()
  ((content :initarg :content
            :accessor content)
   (cursor-x :initform 0
             :accessor cursor-x)
   (cursor-y :initform 0
             :accessor cursor-y)))

(defun make-buffer (content)
  (make-instance 'buffer :content content))

(defun int->key (k)
  (cond
    ((equalp k (char-int #\q))
     :quit)
    ((equalp (crt:key-code-to-name k) :left)
     :left)
    ((equalp (crt:key-code-to-name k) :right)
     :right)
    ((equalp (crt:key-code-to-name k) :up)
     :up)
    ((equalp (crt:key-code-to-name k) :down)
     :down)))

(defun move-cursor (buf dir)
  (case dir
    (:left (decf (cursor-x buf)))
    (:right (incf (cursor-x buf)))
    (:up (decf (cursor-y buf)))
    (:down (incf (cursor-y buf)))))

(defun print-buffer (buf)
  (loop
    for line in (content buf)
    for y from 0
    do (ncurses:mvaddstr y 0 line))
  (ncurses:move (cursor-y buf) (cursor-x buf))
  (ncurses:refresh))

(defun load-file (path)
  (let* ((lines (uiop:read-file-lines path))
         (buf (make-buffer lines)))
    (print-buffer buf)
    buf))

(defun movement? (key)
  (member key '(:left :right :up :down)))

(defun handle-input (buf)
  (let ((key (int->key (ncurses:getch))))
    (when (not (equalp key :quit))
      (when (movement? key)
        (move-cursor buf key))
      (progn
        (print-buffer buf)
        (handle-input buf)))))

(defun main ()
  (init-ncurses)
  (let ((buf (load-file "flake.nix")))
    (handle-input buf))
  (ncurses:endwin))

(slynk:create-server :port 4321
                     :dont-close t)

(main)
