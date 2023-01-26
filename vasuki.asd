(asdf:defsystem "vasuki"
  :depends-on (#:croatoan)
  :components ((:module "src"
                :components ((:file "main"))))
  :entry-point "vasuki::main")
