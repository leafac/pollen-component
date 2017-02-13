#lang info

(define collection "pollen-component")
(define version "0.0.3")
(define deps '("base" "pollen" "sugar"))
(define build-deps '("scribble-lib" "racket-doc"))
(define scribblings '(("documentation/pollen-component.scrbl" ())))
(define compile-omit-paths '("examples" "tests"))
(define pkg-desc "Component-based development for Pollen")
(define pkg-authors '(leafac))
