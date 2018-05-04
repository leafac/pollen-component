#lang racket
(require pollen-component)

(provide (all-defined-out))

(components-output-types #:dynamic html atom #:static css)

(define-component (tag val)
  #:html `(div ((id ,val)))
  #:atom `(some-tag "@" ,val))